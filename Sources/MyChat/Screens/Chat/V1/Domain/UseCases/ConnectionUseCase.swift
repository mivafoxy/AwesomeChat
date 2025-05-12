//
//  ConnectionUseCase.swift
//  MyChat
//
//  Created by Илья Малахов on 08.05.2025.
//

protocol ConnectionUseCaseProtocol {
    func connect() throws
    func disconnect()
    func observeConnection() -> AsyncStream<ConnectionState>
    func observeAuthorization() -> AsyncStream<AuthorizationState>
}

final class ConnectionUseCase: ConnectionUseCaseProtocol {
    
    private let chatRepository: ChatRepositoryProtocol
    private var connectionTask: Task<Void, Error>?
    
    init(chatRepository: ChatRepositoryProtocol) {
        self.chatRepository = chatRepository
    }
    
    func connect() throws {
        connectionTask?.cancel()
        connectionTask = Task.detached { [weak self] in
            try await self?.chatRepository.connect()
        }
    }
    
    func disconnect() {
        Task.detached { [weak self] in
            self?.chatRepository.disconnect()
        }
    }
    
    func observeConnection() -> AsyncStream<ConnectionState> {
        chatRepository.observeConnection()
    }
    
    func observeAuthorization() -> AsyncStream<AuthorizationState> {
        chatRepository.observeAuthorize()
    }
}
