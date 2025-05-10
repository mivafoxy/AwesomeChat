//
//  SendOperatorScoreUseCase.swift
//  FAChat
//
//  Created by Илья Малахов on 08.05.2025.
//

protocol SendOperatorScoreUseCaseProtocol {
    func execute(operatorScore: Int)
}

final class SendOperatorScoreUseCase: SendOperatorScoreUseCaseProtocol {
    
    private let chatRepository: ChatRepositoryProtocol
    
    init(chatRepository: ChatRepositoryProtocol) {
        self.chatRepository = chatRepository
    }
    
    func execute(operatorScore: Int) {
        chatRepository.send(operatorScore: operatorScore)
    }
}
