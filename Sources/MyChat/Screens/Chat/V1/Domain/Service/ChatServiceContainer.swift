//
//  ChatServiceContainer.swift
//  
//
//  Created by Илья Малахов on 05.03.2025.
//

protocol ChatServiceContainer {
    func resolveLoader() -> ChatLoader
    func resolveNotificationService() -> MyChatNotificationService
}

final class ChatServices: ChatServiceContainer {
    
    private let loader: ChatLoader
    private let notificationService: MyChatNotificationService
    
    init(
        loader: ChatLoader,
        notificationService: MyChatNotificationService
    ) {
        self.loader = loader
        self.notificationService = notificationService
    }
    
    func resolveLoader() -> ChatLoader {
        return loader
    }
    
    func resolveNotificationService() -> MyChatNotificationService {
        return notificationService
    }
}
