//
//  ChatMessage.swift
//  
//
//  Created by Илья Малахов on 23.10.2024.
//

import SwiftUI

public struct ChatBubbleQuote {
    
    public let title: String
    public let content: String
    public let image: Image?
    public let fileImage: Image?
    
    public init(
        title: String,
        content: String,
        image: Image? = nil,
        fileImage: Image? = nil
    ) {
        self.title = title
        self.content = content
        self.image = image
        self.fileImage = fileImage
    }
}
