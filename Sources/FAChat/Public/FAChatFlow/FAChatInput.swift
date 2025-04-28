//
//  FAChatInput.swift
//  
//
//  Created by Илья Малахов on 21.11.2024.
//

import Foundation

public protocol FAChatInput {
    var utils: FAChatUtils { get }
    var notificationService: FAChatNotificationService { get }
    var webApi: FAChatWebApi { get }
}
