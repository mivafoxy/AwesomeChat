//
//  ChatQuote.swift
//  
//
//  Created by Илья Малахов on 05.11.2024.
//

import SwiftUI
import MRDSKit

public struct ChatQuote: View {
    
    public let title: String
    public let content: String
    public let image: MRImage?
    public let fileImage: MRImage?
    public let onCloseTap: (() -> Void)?
    
    public init(
        title: String,
        content: String,
        image: MRImage? = nil,
        fileImage: MRImage? = nil,
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
        ImageView(
            mrImage: Asset.Size16.UI.SmallCloseFilled.with(
                tintColor: nil,
                andBackground: .fillColor(MRBackgroundColor.colorOnBackgroundFourth))
        )
            .frame(
                width: 16.0,
                height: 16.0
            )
    }
}
