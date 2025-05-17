//
//  ConnectionUseCase.swift
//  MyChat
//
//  Created by Илья Малахов on 08.05.2025.
//

protocol ConnectionUseCaseProtocol: Sendable {
    func connect() async throws
    func disconnect()
    func observeConnection() -> AsyncStream<ConnectionState>
    func observeAuthorization() -> AsyncStream<AuthorizationState>
}

final class ConnectionUseCase: ConnectionUseCaseProtocol {
    
    private let chatRepository: ChatRepositoryProtocol
    private let connectionTask: TaskHolder<Void, Error>
    
    init(chatRepository: ChatRepositoryProtocol) {
        self.chatRepository = chatRepository
        self.connectionTask = TaskHolder()
    }
    
    func connect() async throws {
        await connectionTask.cancelTask()
        let task = Task.detached { [chatRepository = self.chatRepository] in
            try await chatRepository.connect()
        }
        await connectionTask.set(task: task)
    }
    
    func disconnect() {
        chatRepository.disconnect()
    }
    
    func observeConnection() -> AsyncStream<ConnectionState> {
        chatRepository.observeConnection()
    }
    
    func observeAuthorization() -> AsyncStream<AuthorizationState> {
        chatRepository.observeAuthorize()
    }
}
