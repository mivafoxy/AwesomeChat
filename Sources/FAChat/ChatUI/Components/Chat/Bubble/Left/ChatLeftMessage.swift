//
//  ChatLeftMessage.swift
//  
//
//  Created by Илья Малахов on 25.10.2024.
//

import Foundation

public struct ChatLeftMessage: Identifiable {
    
    public let id: String
    
    public let text: String
    public let statusSubtitle: String
    public let quote: ChatBubbleQuote?
    public let contextActions: [ChatContextAction]
    
    public init(
        id: String = UUID().uuidString,
        text: String,
        statusSubtitle: String,
        quote: ChatBubbleQuote? = nil,
        contextActions: [ChatContextAction] = []
    ) {
        self.text = text
        self.statusSubtitle = statusSubtitle
        self.quote = quote
        self.id = id
        self.contextActions = contextActions
    }
}
