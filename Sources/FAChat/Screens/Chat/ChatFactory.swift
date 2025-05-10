//
//  ChatFactory.swift
//  
//  Created by Ilja Malakhov on 21.11.2024.
//

import UIKit
import SwiftUI
import MCChatAPI

protocol ChatFactory {
    static func makeChat(input: FAChatInput) -> UIViewController
}

extension ChatFactory {
    static func makeChat(input: FAChatInput) -> UIViewController {
        makeChatV1(input)
    }
    
    private static func makeChatV1(_ input: FAChatInput) -> UIViewController {
                
        let badgeUseCase = BadgeUseCase(notificationService: input.notificationService)
        
        let eventProvider = ChatEventProvider(chatService: input.webApi)
        let repository = ChatRepository(eventProvider: eventProvider)
        
        let connectUseCase = ConnectionUseCase(chatRepository: repository)
        let authorizationUseCase = AuthorizationUseCase(repository: repository)
        let loadHistoryUseCase = LoadHistoryUseCase(repository: repository)
        let receiveMessageUseCase = ReceiveMessageUseCase(repository: repository)
        let receiveErrorUseCase = ReceiveErrorUseCase(repository: repository)
        let sendConfirmationUseCase = SendConfirmationUseCase(repository: repository)
        let sendMessageUseCase = SendMessageUseCase(chatRepository: repository)
        let sendActionUseCase = SendActionUseCase(chatRepository: repository)
        let sendOperatorScoreUseCase = SendOperatorScoreUseCase(chatRepository: repository)
        let startDialogUseCase = StartDialogUseCase(repository: repository)
        
        let viewModel = ChatViewModel(
            badgeUseCase: badgeUseCase,
            connectUseCase: connectUseCase,
            authorizationUseCase: authorizationUseCase,
            loadHistoryUseCase: loadHistoryUseCase,
            receiveMessageUseCase: receiveMessageUseCase,
            receiveErrorUseCase: receiveErrorUseCase,
            sendConfirmationUseCase: sendConfirmationUseCase,
            sendMessageUseCase: sendMessageUseCase,
            sendActionUseCase: sendActionUseCase,
            sendOperatorScoreUseCase: sendOperatorScoreUseCase,
            startDialogUseCase: startDialogUseCase
        )
        
        let screen = ChatScreen(viewModel: viewModel)
        
        let viewController = UIHostingController(rootView: screen)
        return viewController
    }
}
