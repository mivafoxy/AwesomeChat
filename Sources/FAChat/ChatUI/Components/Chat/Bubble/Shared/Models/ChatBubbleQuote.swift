//
//  ChatMessage.swift
//  
//
//  Created by Илья Малахов on 23.10.2024.
//

import MRDSKit

public struct ChatBubbleQuote {
    
    public let title: String
    public let content: String
    public let image: MRImage?
    public let fileImage: MRImage?
    
    public init(
        title: String,
        content: String,
        image: MRImage? = nil,
        fileImage: MRImage? = nil
    ) {
        self.title = title
        self.content = content
        self.image = image
        self.fileImage = fileImage
    }
}
