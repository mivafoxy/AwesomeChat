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
        
        let loader: ChatLoader = ChatApiLoader(chatApi: input.webApi)
        
        let serviceContainer = ChatServices(
            loader: loader,
            notificationService: input.notificationService,
            utils: input.utils
        )
        
        let viewModel = ChatViewModel(serviceContainer: serviceContainer)
        loader.setup(eventDelegate: viewModel)
        
        let screen = ChatScreen(viewModel: viewModel)
        
        let viewController = UIHostingController(rootView: screen)
        return viewController
    }
}
