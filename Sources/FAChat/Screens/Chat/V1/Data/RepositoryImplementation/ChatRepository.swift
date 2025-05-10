//
//  ChatRepository.swift
//  FAChat
//
//  Created by Илья Малахов on 05.05.2025.
//

class ChatRepository: ChatRepositoryProtocol {
    
    // MARK: - Privates
    
    private let eventProvider: ChatEventProvider
    
    // MARK: - Init
    
    init(eventProvider: ChatEventProvider) {
        self.eventProvider = eventProvider
    }
    
    // MARK: - ChatDataSource
    
    func connect() async throws {
        try await eventProvider.chatService.connect()
    }
    
    func observeConnection() -> AsyncStream<ConnectionState> {
        eventProvider.connectionStream()
    }
    
    func startDialog() {
        eventProvider.chatService.startDialog()
    }
    
    func loadHistory(with timestamp: Int) {
        eventProvider.chatService.loadHistory(with: timestamp)
    }
    
    func observeHistoryMessages() -> AsyncStream<[FAChatMessage]> {
        eventProvider.receiveHistoryMessagesStream()
    }
    
    func send(content: String, _ repliedMessage: (any FAChatMessage)?) {
        eventProvider.chatService.send(content: content, repliedMessage)
    }
    
    func observeMessageArrival() -> AsyncStream<FAChatMessage> {
        eventProvider.receiveMessageStream()
    }
    
    func sendAction(with id: String) {
        eventProvider.chatService.sendAction(with: id)
    }
    
    func sendReadConfirmation(messageId: String) {
        eventProvider.chatService.sendReadConfirmation(messageId: messageId)
    }
    
    func send(operatorScore: Int) {
        eventProvider.chatService.send(operatorScore: operatorScore)
    }
    
    func disconnect() {
        eventProvider.chatService.disconnect()
    }
    
    func observeAuthorize() -> AsyncStream<AuthorizationState> {
        eventProvider.authorizeStream()
    }
    
    func observeErrors() -> AsyncStream<ErrorState> {
        eventProvider.errorStream()
    }
}
