//
//  ChatViewModelV2.swift
//  MyChat
//
//  Created by Илья Малахов on 09.05.2025.
//

import Combine
import Foundation

enum ChatAction {
    case onAppear
    case onDisappear
    case onScrolling
    case onMessageSend
    case onQuote(id: String)
    case onBotAction(ChatBotAction)
    case onRefresh
    case onQuoteCloseTap
    case onRetry
    case onDownButtonTap
    case onAnchorChange(Double)
    case onMessageAppear(ChatMessage)
    case onSendOperatorScore(Int)
    case onCloseTap
}

enum ChatState {
    case loading
    case content
    case error
}

@MainActor
final class ChatViewModel: ObservableObject {
    
    // MARK: - Message Publishers
    
    @Published var dateMessageGroups = [DateMessageGroup]()
    @Published var botActions = [ChatBotAction]()
    @Published var quoted: ChatMessage?
    @Published var currentUserText = ""
    
    // MARK: - State Publishers
    
    @Published  var isDownButtonHidden = true
    @Published var isBottomSheetHidden = true
    @Published var unreadCount = 0 {
        didSet {
            if unreadCount <= 0 || isChatTabBadgeHidden {
                badgeUseCase.removeBadge()
            } else if !isChatTabBadgeHidden && unreadCount > 0 {
                badgeUseCase.showBadge(badgeCount: unreadCount)
            }
        }
    }
    
    @Published private(set) var isNeedScroll = false
    @Published private(set) var state = ChatState.loading
    @Published private(set) var isRefreshing = false
    @Published private(set) var isOperatorTyping = false
    
    // MARK: - Use cases
    
    private let badgeUseCase: BadgeUseCaseProtocol
    
    private let connectUseCase: ConnectionUseCaseProtocol
    private var connectionStateTask: Task<Void, Never>?
    
    private let authorizationUseCase: AuthorizationUseCaseProtocol
    private var authorizationObserverTask: Task<Void, Never>?
    
    private let loadHistoryUseCase: LoadHistoryUseCaseProtocol
    private var receiveHistoryMessagesTask: Task<Void, Never>?

    private let receiveMessageUseCase: ReceiveMessageUseCaseProtocol
    private var receiveMessageTask: Task<Void, Never>?
    
    private let receiveErrorUseCase: ReceiveErrorUseCaseProtocol
    private var receiveErrorTask: Task<Void, Never>?

    private let sendConfirmationUseCase: SendConfirmationUseCaseProtocol
    private let sendMessageUseCase: SendMessageUseCaseProtocol
    private let sendActionUseCase: SendActionUseCaseProtocol
    private let sendOperatorScoreUseCase: SendOperatorScoreUseCaseProtocol

    private let startDialogUseCase: StartDialogUseCaseProtocol
    
    // MARK: - List Manager
    
    private let listManager = ChatListManager()
    
    // MARK: - Inner states
    
    private var isConnected: Bool = false
    private var pendingMessages = [String]()
    
    private var isChatTabBadgeHidden = false {
        didSet {
            if !isChatTabBadgeHidden && unreadCount > 0 {
                badgeUseCase.showBadge(badgeCount: unreadCount)
            } else if unreadCount <= 0 || isChatTabBadgeHidden {
                badgeUseCase.removeBadge()
            }
        }
    }
    
    // MARK: - Init
    
    init(
        badgeUseCase: BadgeUseCaseProtocol,
        connectUseCase: ConnectionUseCaseProtocol,
        authorizationUseCase: AuthorizationUseCaseProtocol,
        loadHistoryUseCase: LoadHistoryUseCaseProtocol,
        receiveMessageUseCase: ReceiveMessageUseCaseProtocol,
        receiveErrorUseCase: ReceiveErrorUseCaseProtocol,
        sendConfirmationUseCase: SendConfirmationUseCaseProtocol,
        sendMessageUseCase: SendMessageUseCaseProtocol,
        sendActionUseCase: SendActionUseCaseProtocol,
        sendOperatorScoreUseCase: SendOperatorScoreUseCaseProtocol,
        startDialogUseCase: StartDialogUseCaseProtocol
    ) {
        self.badgeUseCase = badgeUseCase
        self.connectUseCase = connectUseCase
        self.authorizationUseCase = authorizationUseCase
        self.loadHistoryUseCase = loadHistoryUseCase
        self.receiveMessageUseCase = receiveMessageUseCase
        self.receiveErrorUseCase = receiveErrorUseCase
        self.sendConfirmationUseCase = sendConfirmationUseCase
        self.sendMessageUseCase = sendMessageUseCase
        self.sendActionUseCase = sendActionUseCase
        self.sendOperatorScoreUseCase = sendOperatorScoreUseCase
        self.startDialogUseCase = startDialogUseCase
    }
    
    // MARK: - Events
    
    func send(_ event: ChatAction) {
        Task {
            switch event {
            case .onAppear:
                await self.onAppear()
            case .onDisappear:
                self.onDisappear()
            case .onScrolling:
                self.onScrolling()
            case .onMessageSend:
                await self.onMessageSend()
            case let .onQuote(id):
                self.onQuote(id)
            case let .onBotAction(action):
                self.onChatBotAction(action: action)
            case .onRefresh:
                await self.onRefresh()
            case .onQuoteCloseTap:
                self.quoted = nil
            case .onRetry:
                await self.onRetry()
            case .onDownButtonTap:
                await self.onDownButtonTap()
            case let .onAnchorChange(offset):
                self.onAnchorChange(offset)
            case let .onMessageAppear(message):
                self.onMessageAppear(message)
            case let .onSendOperatorScore(score):
                self.onSendOperatorScore(score)
            case .onCloseTap:
                self.onCloseTap()
            }
        }
    }
    
    // MARK: - Action event handling
    
    private func onAppear() async {
        isChatTabBadgeHidden = true
        listen()
        await connect()
        await tryToLoadAbsentMessages()
    }
    
    private func tryToLoadAbsentMessages() async {
        await loadHistoryUseCase.loadHistoryAfterReconnect()
    }
    
    private func connect() async {
        if !isConnected {
            do {
                try await connectUseCase.connect()
            } catch {
                update(state: .error)
            }
        }
    }
    
    private func onDisappear() {
        isChatTabBadgeHidden = false
    }
    
    private func onScrolling() {
        isNeedScroll = false
    }
    
    private func onMessageSend() async {
        if !isConnected {
            pendingMessages.append(currentUserText)
        } else {
            await sendMessage(currentUserText)
        }
        currentUserText = ""
    }
    
    private func sendMessage(_ content: String) async {
        isNeedScroll = true
        await sendReadingConfirmation()
        sendMessageUseCase.sendMessage(messageContent: currentUserText, repliedMessage: quoted?.message)
        currentUserText = ""
        quoted = nil
    }
    
    private func loadHistory() async  {
        let timestamp = listManager.getEarliestTimestamp(from: dateMessageGroups)
        await loadHistoryUseCase.loadHistory(timespan: timestamp)
    }
    
    private func sendReadingConfirmation() async {
        let operatorMessageIds = listManager.getOperatorMessages(from: dateMessageGroups).map { $0.id }
        await sendConfirmationUseCase.sendConfirmation(for: operatorMessageIds)
    }
    
    private func onQuote(_ messageId: String) {
        let message = listManager.getAllMessages(from: dateMessageGroups).first {
            $0.id == messageId
        }
        guard let message = message else { return }
        self.quoted = message
    }
    
    private func onChatBotAction(action: ChatBotAction) {
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            self.currentUserText = ""
            self.botActions.removeAll()
        }
        sendMessageUseCase.sendMessage(messageContent: action.content, repliedMessage: nil)
    }
    
    private func onRefresh() async {
        if isConnected {
            guard !isRefreshing else { return }
            await loadHistory()
        } else {
            await connect()
        }
    }
    
    private func onRetry() async {
        update(state: .loading)
        await connect()
    }
    
    private func onDownButtonTap() async {
        isNeedScroll.toggle()
        await setReadStatusForUnreadMessages()
    }
    
    private func onAnchorChange(_ offset: Double) {
        let minOffset = 100.0
        let isHidden = offset < minOffset
        if isDownButtonHidden != isHidden {
            isDownButtonHidden = isHidden
            updateUnreadCounter()
        }
    }
    
    private func onMessageAppear(_ message: ChatMessage) {
        guard message.readStatus == .unread else { return }
        sendReadConfirmation(for: message.id)
    }
    
    private func onSendOperatorScore(_ score: Int) {
        guard score != 0 else { return }
        sendOperatorScore(score)
    }
    
    private func onCloseTap() {
        isBottomSheetHidden = true
    }
    
    private func sendReadConfirmation(for messageId: String) {
        setMessageStatus(with: messageId, .read)
        updateUnreadCounter()
        sendConfirmationUseCase.sendConfirmation(for: messageId)
    }
    
    private func setMessageStatus(with id: String, _ status: MessageReadStatus) {
        guard let indices = listManager.getIndiciesForMessage(with: id, dateMessageGroups: dateMessageGroups) else {
            return
        }
        let oldMessage = dateMessageGroups[indices.dateGroup]
            .userMessageGroups[indices.userGroup]
            .messages[indices.message]
        let newMessage = ChatMessage(
            message: oldMessage.message,
            messageContent: oldMessage.content
        )
        newMessage.readStatus = status
        dateMessageGroups[indices.dateGroup]
            .userMessageGroups[indices.userGroup]
            .messages[indices.message] = newMessage
    }
    
    private func setReadStatusForUnreadMessages() async {
        let unread = listManager.getOperatorMessages(from: dateMessageGroups)
            .filter { message in message.readStatus == .unread }
            .compactMap { $0.id }
        await unread.forEachAsync { @Sendable [weak self] in
            await self?.sendReadConfirmation(for: $0)
        }
    }
    
    private func updateUnreadCounter() {
        unreadCount = listManager.getOperatorMessages(from: dateMessageGroups)
            .filter { $0.readStatus == .unread }
            .count
    }
    
    private func sendOperatorScore(_ operatorScore: Int) {
        sendOperatorScoreUseCase.execute(operatorScore: operatorScore)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let self = self else { return }
            self.isBottomSheetHidden = true
        }
    }
    
    fileprivate func update(state: ChatState) {
        guard self.state != state else { return }
        self.state = state
    }
    
    // MARK: - OBserve events from lib
    
    private func listen() {
        receiveConnectionState()
        receiveAuthorizationState()
        receiveErrors()
        receiveMessages()
        receiveHistoryMessages()
    }
    
    // MARK: - Observing connection state
    
    private func receiveConnectionState() {
        connectionStateTask?.cancel()
        connectionStateTask = Task { [weak self] in
            guard let self else { return }
            for await state in self.connectUseCase.observeConnection() {
                switch state {
                case .connected:
                    self.isConnected = true
                case let .disconnected(error):
                    if error != nil {
                        self.state = .error
                    }
                    self.isConnected = false
                case .reconnect:
                    self.isConnected = false
                }
            }
        }
    }
    
    // MARK: - Observing authorization state
    
    private func receiveAuthorizationState() {
        authorizationObserverTask?.cancel()
        authorizationObserverTask = Task { [weak self] in
            guard let self else { return }
            for await state in authorizationUseCase.observeAuthorization() {
                switch state {
                case .unauthorized:
                    connectUseCase.disconnect()
                case .authorized:
                    startDialogUseCase.execute()
                    await sendPendingMessages()
                    let zeroPoint = 0
                    await loadHistoryUseCase.loadHistory(timespan: zeroPoint)
                    self.state = .content
                }
            }
        }
    }
    
    private func sendPendingMessages() async {
        if !pendingMessages.isEmpty {
            await pendingMessages.forEachAsync { @Sendable [weak self] in
                await self?.sendMessage($0)
            }
            pendingMessages.removeAll()
        }
    }
    
    // MARK: - Observing messages
    
    private func receiveMessages() {
        receiveMessageTask?.cancel()
        receiveMessageTask = Task { [weak self] in
            guard let self else { return }
            for await message in receiveMessageUseCase.execute() {
                await MainActor.run { [weak self] in
                    self?.didReceiveMessage(message)
                }
            }
        }
    }
    
    private func didReceiveMessage(_ message: MyChatMessage) {
        switch message.messageType {
        case .visitorMessage:
            onReceiveVisitor(message)
        case .finishDialog:
            onFinishDialog(message)
        case .connectedOperator:
            onOperatorConnect(message)
        case .receivedByMediator, .receivedByOperator:
            onReadingConfirmation(message)
        case .operatorIsTyping:
            onOperatorTyping()
        case .operatorStoppedTyping:
            onOperatorStopTyping()
        case .sentConfirmation,
                .readingConfirmation,
                .updateDialogScore,
                .closeDialogIntention,
                .clientHold,
                .unknown,
                .updateNegativeReason:
            break
        }
    }
    
    private func onReceiveVisitor(_ message: MyChatMessage) {
        onReceive(message: message)
    }
    
    func onReceive(message: MyChatMessage) {
        print("onReceive(message:")
        guard message.text?.isEmpty == false else { return }
        let chatMessage = ChatMessage(
            message: message,
            messageContent: message.text ?? ""
        )
        chatMessage.readStatus = .unread
        listManager.append(newMessages: [chatMessage], dateMessageGroups: &dateMessageGroups, botActions: &botActions)
        setOperator(isTyping: false)
        updateUnreadCounter()
    }
    
    private func onFinishDialog(_ message: MyChatMessage) {
        onReceive(message: message)
        isBottomSheetHidden = false
    }
    
    private func onOperatorConnect(_ message: MyChatMessage) {
        guard case .systemMessage = message.author else {
            return
        }
        let messageContent = String.localizedStringWithFormat(
            "chat_operator_connected".localized,
            message.operatorName ?? ""
        )
        let operatorConnectedMessage = ChatMessage(message: message, messageContent: messageContent)
        listManager.append(systemMessage: operatorConnectedMessage, dateMessageGroups: &dateMessageGroups)
    }
    
    private func onReadingConfirmation(_ message: MyChatMessage) {
        onReadingConfirmation(message: message)
    }
    
    func onReadingConfirmation(message: MyChatMessage) {
        print(#function)
        guard let parentId = message.parentMessageId else { return }
        setMessageStatus(with: parentId, .read)
    }
    
    func onOperatorTyping() {
        print(#function)
        setOperator(isTyping: true)
    }
    
    func onOperatorStopTyping() {
        print(#function)
        setOperator(isTyping: false)
    }
    
    private func setOperator(isTyping: Bool) {
        if isOperatorTyping != isTyping {
            isOperatorTyping = isTyping
        }
    }
    
    // MARK: - Observing history messages
    
    private func receiveHistoryMessages() {
        receiveHistoryMessagesTask?.cancel()
        receiveHistoryMessagesTask = Task { [weak self] in
            guard let self else { return }
            for await messages in loadHistoryUseCase.observeHistoryMessages() {
                self.didReceiveHistoryMessages(messages)
            }
        }
    }
    
    func didReceiveHistoryMessages(_ messages: [MyChatMessage]) {
        print("onReceive(historyMessages")
        isRefreshing = false
        guard !messages.isEmpty else { return }
        listManager.append(historyMessages: messages, dateMessageGroups: &dateMessageGroups)
    }
    
    // MARK: - Observing errors
    
    private func receiveErrors() {
        receiveErrorTask?.cancel()
        receiveErrorTask = Task { [weak self] in
            guard let self else { return }
            for await error in receiveErrorUseCase.observeErrors() {
                if error.error != nil {
                    self.state = .error
                }
            }
        }
    }
}
