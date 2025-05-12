//
//  ChatRepositoryProtocol.swift
//  MyChat
//
//  Created by Илья Малахов on 05.05.2025.
//

// MARK: - ConnectionState

enum ConnectionState {
    case connected
    case disconnected(error: Error? = nil)
    case reconnect
}

// MARK: - AuthorizationState

enum AuthorizationState {
    case unauthorized
    case authorized
}

// MARK: - ErrorState

struct ErrorState {
    let error: Error?
    let data: Any?
}

// MARK: - ChatRepositoryProtocol

protocol ChatRepositoryProtocol {
    func connect() async throws
    func observeConnection() -> AsyncStream<ConnectionState>
    
    func startDialog()
    
    func loadHistory(with timestamp: Int)
    func observeHistoryMessages() -> AsyncStream<[MyChatMessage]>
    
    func send(content: String, _ repliedMessage: MyChatMessage?)
    func observeMessageArrival() -> AsyncStream<MyChatMessage>
    
    func sendAction(with id: String)
    func sendReadConfirmation(messageId: String)
    func send(operatorScore: Int)
    
    func disconnect()

    func observeAuthorize() -> AsyncStream<AuthorizationState>
    func observeErrors() -> AsyncStream<ErrorState>
}
