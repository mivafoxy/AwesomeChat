//
//  ChatQuote.swift
//  
//
//  Created by Илья Малахов on 05.11.2024.
//

import SwiftUI

public struct ChatQuote: View {
    
    public let title: String
    public let content: String
    public let image: Image?
    public let fileImage: Image?
    public let onCloseTap: (() -> Void)?
    
    public init(
        title: String,
        content: String,
        image: Image? = nil,
        fileImage: Image? = nil,
        onCloseTap: (() -> Void)? = nil
    ) {
        self.title = title
        self.content = content
        self.image = image
        self.fileImage = fileImage
        self.onCloseTap = onCloseTap
    }
    
    public var body: some View {
        HStack(spacing: .zero) {
            ChatQuoteContent(
                image: image,
                fileImage: fileImage,
                title: title,
                content: content
            )
            Spacer(minLength: 8.0)
            close
                .onTapGesture {
                    onCloseTap?()
                }
        }
        .padding(.all, 10.0)
    }
    
    private var close: some View {
        Image("xmark.app")
            .frame(
                width: 16.0,
                height: 16.0
            )
    }
}

#Preview {
    ChatQuote(
        title: "Оператор",
        content: "Жили были не тужили",
        image: Image(systemName: "xbox.logo"),
        fileImage: Image(systemName: "arrow.down.document"),
        onCloseTap: nil
    )
}
