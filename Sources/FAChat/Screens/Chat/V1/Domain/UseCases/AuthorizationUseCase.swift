//
//  AuthorizationUseCase.swift
//  FAChat
//
//  Created by Илья Малахов on 09.05.2025.
//

protocol AuthorizationUseCaseProtocol {
    func observeAuthorization() -> AsyncStream<AuthorizationState>
}

final class AuthorizationUseCase: AuthorizationUseCaseProtocol {
    
    private let repository: ChatRepository
    
    init(repository: ChatRepository) {
        self.repository = repository
    }
    
    func observeAuthorization() -> AsyncStream<AuthorizationState> {
        repository.observeAuthorize()
    }
}
