//
//  SendActionUseCase.swift
//  FAChat
//
//  Created by Илья Малахов on 08.05.2025.
//

protocol SendActionUseCaseProtocol {
    func execute(actionId: String)
}

final class SendActionUseCase: SendActionUseCaseProtocol {
    
    private let chatRepository: ChatRepositoryProtocol
    
    init(chatRepository: ChatRepositoryProtocol) {
        self.chatRepository = chatRepository
    }
    
    func execute(actionId: String) {
        chatRepository.sendAction(with: actionId)
    }
}
