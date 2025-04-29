//
//  ChatViewModel.swift
// 
//  Created by Ilja Malakhov on 21.11.2024.
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
    case onContentHeightChange(Bool)
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
    @Published var lastSeenMessageId: String?
    
    // MARK: - State Publishers
    
    @Published  var isDownButtonHidden = true
    @Published var isBottomSheetHidden = true
    @Published var unreadCount = 0 {
        didSet {
            if unreadCount <= 0 || isChatTabBadgeHidden {
                notificationService.postBadgeRemove()
            } else if !isChatTabBadgeHidden && unreadCount > 0 {
                notificationService.postBadgeNotification(badgeCount: unreadCount)
            }
        }
    }
    
    @Published private(set) var isNeedScroll = false
    @Published private(set) var state = ChatState.loading
    @Published private(set) var isRefreshing = false
    @Published private(set) var isContentOutOfListBounds = false
    @Published private(set) var isOperatorTyping = false
    
    // MARK: - Properties
    
    var utils: FAChatUtils {
        serviceContainer.resolveUtils()
    }
    
    var messageIds = Set<String>()
    
    private var connectionTask: Task<Void, Never>?
    private var historyLoadTask: Task<Void, Never>?
    private var readConfirmationTask: Task<Void, Never>?
    
    private let serviceContainer: ChatServiceContainer
    private var isConnected = false
    private var pendingMessages = [String]()
    
    private var isChatTabBadgeHidden = false {
        didSet {
            if !isChatTabBadgeHidden && unreadCount > 0 {
                notificationService.postBadgeNotification(badgeCount: unreadCount)
            } else if unreadCount <= 0 || isChatTabBadgeHidden {
                notificationService.postBadgeRemove()
            }
        }
    }
    
    private var notificationService: FAChatNotificationService {
        serviceContainer.resolveNotificationService()
    }
    
    private var loader: ChatLoader {
        serviceContainer.resolveLoader()
    }
    
    // MARK: - Init
    
    init(serviceContainer: ChatServiceContainer) {
        self.serviceContainer = serviceContainer
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
        case let .onContentHeightChange(isContentOutOfListBounds):
            onContentHeightChange(isContentOutOfListBounds)
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
        connect()
        tryToLoadAbsentMessages()
    }
    
    private func tryToLoadAbsentMessages() {
        guard let timeZone = TimeZone(identifier: "UTC") else { return }
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: .now)!
        let zeroPoint = Date.now.timeIntervalSince1970 + tomorrow.timeIntervalSinceNow
        loader.loadHistory(with: Int(zeroPoint))
    }
    
    private func connect() {
        if !isConnected {
            connectionTask?.cancel()
            connectionTask = Task.detached(priority: .userInitiated) { [weak self] in
                guard let self = self else { return }
                do {
                    try await self.loader.connect()
                } catch {
                    self.update(state: .error)
                }
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
        loader.sendMessage(content: currentUserText, repliedMessage: quoted)
        currentUserText = ""
        quoted = nil
    }
    
    private func loadHistory() {
        historyLoadTask?.cancel()
        isRefreshing = true
        historyLoadTask = Task.detached(priority: .userInitiated) { [weak self] in
            guard let self = self else { return }
            let timestamp = self.getEarliestTimestamp()
            self.loader.loadHistory(with: timestamp)
        }
    }
    
    private func sendReadingConfirmation() {
        readConfirmationTask?.cancel()
        readConfirmationTask = Task.detached(priority: .background) {
            await withTaskGroup(of: Void.self) { [weak self] group in
                guard let self = self else { return }
                for message in self.getOperatorMessages() {
                    self.loader.sendReadingConfirmation(for: message.id)
                }
            }
        }
    }
    
    private func onQuote(_ messageId: String) {
        let message = getAllMessages().first {
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
        Task(priority: .userInitiated) { [weak self] in
            guard let self = self else { return }
            self.loader.sendMessage(content: action.content, repliedMessage: nil)
        }
    }
    
    private func onRefresh() {
        if isConnected {
            guard !isRefreshing else { return }
            loadHistory()
        } else {
            connect()
        }
    }
    
    private func onContentHeightChange(_ isContentOutOfListBounds: Bool) {
        if self.isContentOutOfListBounds != isContentOutOfListBounds {
            self.isContentOutOfListBounds = isContentOutOfListBounds
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
        
        Task.detached(priority: .background) { [weak loader = self.loader] in
            loader?.sendReadingConfirmation(for: messageId)
        }
    }
    
    private func setReadStatusForUnreadMessages() {
        let unread = getOperatorMessages()
            .filter { message in message.readStatus == .unread }
            .compactMap { $0.id }
        Task.detached(priority: .background) { [weak self] in
            unread.forEach { self?.sendReadConfirmation(for: $0) }
        }
    }
    
    private func updateUnreadCounter() {
        Task.detached { @MainActor [weak self] in
            guard let self = self else { return }
            self.unreadCount = self.getOperatorMessages().filter { $0.readStatus == .unread }.count
        }
    }
    
    private func sendOperatorScore(_ operatorScore: Int) {
        Task(priority: .userInitiated) {
            loader.sendOperator(score: operatorScore)
        }
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
}

// MARK: - Event handling

extension ChatViewModel: FAChatEventDelegate {
    
    func didConnect() {
        print("önConnect")
        isConnected = true
        update(state: .content)
    }
    
    func didAuthorize() {
        print("onAuthorize")
        loader.startDialog()
        if !pendingMessages.isEmpty {
            pendingMessages.forEach { sendMessage($0) }
            pendingMessages.removeAll()
        }
        let zeroPoint = 0
        loader.loadHistory(with: zeroPoint)
    }
    
    func didReconnect() {
        print("onReconnectTry")
        isConnected = false
    }
    
    func onReceive(message: FAChatMessage) {
        print("onReceive(message:")
        lastSeenMessageId = nil
        guard message.text?.isEmpty == false else { return }
        let chatMessage = ChatMessage(
            message: message,
            messageContent: message.text ?? ""
        )
        chatMessage.readStatus = .unread
        append(newMessages: [chatMessage])
        setOperator(isTyping: false)
        updateUnreadCounter()
    }
    
    func onOperatorConnect(message: FAChatMessage) {
        print("onOperatorConnect")
        guard case .systemMessage = message.author else {
            return
        }
        let messageContent = String.localizedStringWithFormat(
            "chat_operator_connected".localized,
            message.operatorName ?? ""
        )
        let operatorConnectedMessage = ChatMessage(message: message, messageContent: messageContent)
        append(systemMessage: operatorConnectedMessage)
    }
    
    func didReceiveHistoryMessages(_ messages: [FAChatMessage]) {
        print("onReceive(historyMessages")
        if isRefreshing && isContentOutOfListBounds && !isDownButtonHidden {
            Task.detached { @MainActor [weak self] in
                self?.lastSeenMessageId = self?.dateMessageGroups.last?.id ?? ""
            }
        }
        isRefreshing = false
        guard !messages.isEmpty else { return }
        self.append(historyMessages: messages)
    }
    
    func didReceiveError(_ error: Error?, _ data: Any?) {
        print("onReceive(error")
        if error != nil {
            update(state: .error)
        }
    }
    
    func didReceiveMessage(_ message: FAChatMessage) {
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
    
    func onReadingConfirmation(message: FAChatMessage) {
        print(#function)
        guard let parentId = message.parentMessageId else { return }
        setMessageStatus(with: parentId, .read)
    }
    
    func onFinishDialog() {
        print("onFinishDialog")
        isBottomSheetHidden = false
    }
    
    func didDisconnect() {
        print("onDisconnect")
        isRefreshing = false
        isConnected = false
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
    
    private func onReceiveVisitor(_ message: FAChatMessage) {
        onReceive(message: message)
    }
    
    private func onFinishDialog(_ message: FAChatMessage) {
        onReceive(message: message)
        onFinishDialog()
    }
    
    private func onOperatorConnect(_ message: FAChatMessage) {
        onOperatorConnect(message: message)
    }
    
    private func onReadingConfirmation(_ message: FAChatMessage) {
        onReadingConfirmation(message: message)
    }
}
