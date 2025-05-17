//
//  ReceiveMessageUseCase.swift
//  MyChat
//
//  Created by Илья Малахов on 08.05.2025.
//

protocol ReceiveMessageUseCaseProtocol: Sendable {
    func execute() -> AsyncStream<MyChatMessage>
}

final class ReceiveMessageUseCase: ReceiveMessageUseCaseProtocol {
    
    private let repository: ChatRepositoryProtocol

    init(repository: ChatRepositoryProtocol) {
        self.repository = repository
    }

    func execute() -> AsyncStream<MyChatMessage> {
        repository.observeMessageArrival()
    }
}
