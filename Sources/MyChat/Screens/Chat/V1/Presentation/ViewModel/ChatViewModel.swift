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
    private var authorizationObserverTast: Task<Void, Never>?
    
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
        switch event {
        case .onAppear:
            onAppear()
        case .onDisappear:
            onDisappear()
        case .onScrolling:
            onScrolling()
        case .onMessageSend:
            onMessageSend()
        case let .onQuote(id):
            onQuote(id)
        case let .onBotAction(action):
            onChatBotAction(action: action)
        case .onRefresh:
            onRefresh()
        case .onQuoteCloseTap:
            quoted = nil
        case .onRetry:
            onRetry()
        case .onDownButtonTap:
            onDownButtonTap()
        case let .onAnchorChange(offset):
            onAnchorChange(offset)
        case let .onMessageAppear(message):
            onMessageAppear(message)
        case let .onSendOperatorScore(score):
            onSendOperatorScore(score)
        case .onCloseTap:
            onCloseTap()
        }
    }
    
    // MARK: - Action event handling
    
    private func onAppear() {
        isChatTabBadgeHidden = true
        listen()
        connect()
        tryToLoadAbsentMessages()
    }
    
    private func tryToLoadAbsentMessages() {
        loadHistoryUseCase.loadHistoryAfterReconnect()
    }
    
    private func connect() {
        if !isConnected {
            do {
                try connectUseCase.connect()
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
    
    private func onMessageSend() {
        if !isConnected {
            pendingMessages.append(currentUserText)
        } else {
            sendMessage(currentUserText)
        }
        currentUserText = ""
    }
    
    private func sendMessage(_ content: String) {
        isNeedScroll = true
        sendReadingConfirmation()
        sendMessageUseCase.sendMessage(messageContent: currentUserText, repliedMessage: quoted?.message)
        currentUserText = ""
        quoted = nil
    }
    
    private func loadHistory() {
        let timestamp = listManager.getEarliestTimestamp(from: dateMessageGroups)
        loadHistoryUseCase.loadHistory(timespan: timestamp)
    }
    
    private func sendReadingConfirmation() {
        let operatorMessageIds = listManager.getOperatorMessages(from: dateMessageGroups).map { $0.id }
        sendConfirmationUseCase.sendConfirmation(for: operatorMessageIds)
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
    
    private func onRefresh() {
        if isConnected {
            guard !isRefreshing else { return }
            loadHistory()
        } else {
            connect()
        }
    }
    
    private func onRetry() {
        update(state: .loading)
        connect()
    }
    
    private func onDownButtonTap() {
        isNeedScroll.toggle()
        setReadStatusForUnreadMessages()
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
    
    private func setReadStatusForUnreadMessages() {
        let unread = listManager.getOperatorMessages(from: dateMessageGroups)
            .filter { message in message.readStatus == .unread }
            .compactMap { $0.id }
        Task.detached(priority: .background) { [weak self] in
            unread.forEach { self?.sendReadConfirmation(for: $0) }
        }
    }
    
    private func updateUnreadCounter() {
        Task.detached { @MainActor [weak self] in
            guard let self = self else { return }
            self.unreadCount = self
                .listManager
                .getOperatorMessages(from: self.dateMessageGroups)
                .filter { $0.readStatus == .unread }
                .count
        }
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
        Task { @MainActor [weak self] in
            self?.state = state
        }
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
        connectionStateTask = Task.detached { [weak self] in
            guard let self else { return }
            print(#function)
            for await state in connectUseCase.observeConnection() {
                switch state {
                case .connected:
                    isConnected = true
                case let .disconnected(error):
                    if error != nil {
                        self.state = .error
                    }
                    isConnected = false
                case .reconnect:
                    isConnected = false
                }
            }
        }
    }
    
    // MARK: - Observing authorization state
    
    private func receiveAuthorizationState() {
        authorizationObserverTast?.cancel()
        authorizationObserverTast = Task.detached { [weak self] in
            guard let self else { return }
            for await state in authorizationUseCase.observeAuthorization() {
                switch state {
                case .unauthorized:
                    connectUseCase.disconnect()
                case .authorized:
                    startDialogUseCase.execute()
                    if !pendingMessages.isEmpty {
                        pendingMessages.forEach { self.sendMessage($0) }
                        pendingMessages.removeAll()
                    }
                    let zeroPoint = 0
                    loadHistoryUseCase.loadHistory(timespan: zeroPoint)
                    await MainActor.run { [weak self] in
                        self?.state = .content
                    }
                }
            }
        }
    }
    
    // MARK: - Observing messages
    
    private func receiveMessages() {
        receiveMessageTask?.cancel()
        receiveMessageTask = Task.detached { [weak self] in
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
        receiveHistoryMessagesTask = Task.detached { [weak self] in
            guard let self else { return }
            for await messages in loadHistoryUseCase.observeHistoryMessages() {
                await MainActor.run { [weak self] in
                    self?.didReceiveHistoryMessages(messages)
                }
                
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
        receiveErrorTask = Task.detached { [weak self] in
            guard let self else { return }
            for await error in receiveErrorUseCase.observeErrors() {
                if error.error != nil {
                    self.state = .error
                }
            }
        }
    }
}
