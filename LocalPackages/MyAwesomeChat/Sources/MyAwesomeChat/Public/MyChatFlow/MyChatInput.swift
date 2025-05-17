//
//  MyChatInput.swift
//  
//
//  Created by Илья Малахов on 21.11.2024.
//

import Foundation

public protocol MyChatInput {
    var notificationService: MyChatNotificationService { get }
    var webApi: MyChatWebApi { get }
}
