//
//  MyChatNotificationService.swift
//  
//
//  Created by Илья Малахов on 25.02.2025.
//

public protocol MyChatNotificationService {
    func postBadgeNotification(badgeCount: Int)
    func postBadgeRemove()
}
