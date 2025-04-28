//
//  ChatRightMessage.swift
//  
//
//  Created by Илья Малахов on 23.10.2024.
//

import Combine
import SwiftUI
import MRDSKit

public struct ChatRightMessage: Identifiable {
    
    public let id: String
    
    public let text: String
    public let statusSubtitle: String
    public let statusIcon: MRImage?
    public let quote: ChatBubbleQuote?
    public let contextActions: [ChatContextAction]
    
    public init(
        id: String = UUID().uuidString,
        text: String,
        statusSubtitle: String,
        statusIcon: MRImage? = nil,
        quote: ChatBubbleQuote? = nil,
        contextActions: [ChatContextAction] = []
    ) {
        self.id = id
        self.text = text
        self.statusSubtitle = statusSubtitle
        self.statusIcon = statusIcon
        self.quote = quote
        self.contextActions = contextActions
    }
}
