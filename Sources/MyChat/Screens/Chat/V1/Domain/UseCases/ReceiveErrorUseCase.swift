//
//  ReceiveErrorUseCase.swift
//  MyChat
//
//  Created by Илья Малахов on 08.05.2025.
//

protocol ReceiveErrorUseCaseProtocol {
    func observeErrors() -> AsyncStream<ErrorState>
}

final class ReceiveErrorUseCase: ReceiveErrorUseCaseProtocol {
    
    private let repository: ChatRepositoryProtocol
    
    init(repository: ChatRepositoryProtocol) {
        self.repository = repository
    }
    
    func observeErrors() -> AsyncStream<ErrorState> {
        repository.observeErrors()
    }
}
