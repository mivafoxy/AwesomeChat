//
//  ChatServiceContainer.swift
//  
//
//  Created by Илья Малахов on 05.03.2025.
//

protocol ChatServiceContainer {
    func resolveLoader() -> ChatLoader
    func resolveNotificationService() -> FAChatNotificationService
    func resolveUtils() -> FAChatUtils
}

final class ChatServices: ChatServiceContainer {
    
    private let loader: ChatLoader
    private let notificationService: FAChatNotificationService
    private let utils: FAChatUtils
    
    init(
        loader: ChatLoader,
        notificationService: FAChatNotificationService,
        utils: FAChatUtils
    ) {
        self.loader = loader
        self.notificationService = notificationService
        self.utils = utils
    }
    
    func resolveLoader() -> ChatLoader {
        return loader
    }
    
    func resolveNotificationService() -> FAChatNotificationService {
        return notificationService
    }
    
    func resolveUtils() -> FAChatUtils {
        return utils
    }
}
