//
//  ReceiveMessageUseCase.swift
//  FAChat
//
//  Created by Илья Малахов on 08.05.2025.
//

protocol ReceiveMessageUseCaseProtocol {
    func execute() -> AsyncStream<FAChatMessage>
}

final class ReceiveMessageUseCase: ReceiveMessageUseCaseProtocol {
    
    private let repository: ChatRepositoryProtocol

    init(repository: ChatRepositoryProtocol) {
        self.repository = repository
    }

    func execute() -> AsyncStream<FAChatMessage> {
        repository.observeMessageArrival()
    }
}
