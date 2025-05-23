//
//  SendMessageUseCase.swift
//  MyChat
//
//  Created by Илья Малахов on 08.05.2025.
//

protocol SendMessageUseCaseProtocol {
    func sendMessage(messageContent: String, repliedMessage: MyChatMessage?)
}

final class SendMessageUseCase: SendMessageUseCaseProtocol {
    
    private let chatRepository: ChatRepositoryProtocol
    
    init(chatRepository: ChatRepositoryProtocol) {
        self.chatRepository = chatRepository
    }
    
    func sendMessage(messageContent: String, repliedMessage: MyChatMessage?) {
        chatRepository.send(content: messageContent, repliedMessage)
    }
}
