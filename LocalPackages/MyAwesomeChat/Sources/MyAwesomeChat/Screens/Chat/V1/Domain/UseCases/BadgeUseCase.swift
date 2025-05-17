//
//  BadgeAppearingUseCase.swift
//  MyChat
//
//  Created by Илья Малахов on 09.05.2025.
//

protocol BadgeUseCaseProtocol {
    func showBadge(badgeCount: Int)
    func removeBadge()
}

final class BadgeUseCase: BadgeUseCaseProtocol {
    
    private let notificationService: MyChatNotificationService
    
    init(notificationService: MyChatNotificationService) {
        self.notificationService = notificationService
    }
    
    func showBadge(badgeCount: Int) {
        notificationService.postBadgeNotification(badgeCount: badgeCount)
    }
    
    func removeBadge() {
        notificationService.postBadgeRemove()
    }
}
