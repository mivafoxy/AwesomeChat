//
//  BadgeAppearingUseCase.swift
//  FAChat
//
//  Created by Илья Малахов on 09.05.2025.
//

protocol BadgeUseCaseProtocol {
    func showBadge(badgeCount: Int)
    func removeBadge()
}

final class BadgeUseCase: BadgeUseCaseProtocol {
    
    private let notificationService: FAChatNotificationService
    
    init(notificationService: FAChatNotificationService) {
        self.notificationService = notificationService
    }
    
    func showBadge(badgeCount: Int) {
        notificationService.postBadgeNotification(badgeCount: badgeCount)
    }
    
    func removeBadge() {
        notificationService.postBadgeRemove()
    }
}
