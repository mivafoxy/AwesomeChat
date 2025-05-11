//
//  ChatMessageLeftBubble.swift
//  
//
//  Created by Илья Малахов on 13.10.2024.
//

import SwiftUI

struct ChatMessageLeftBubble: View {
    
    @State private var textSize: CGSize = .zero
    let radiusSet: RadiusSet
    let message: ChatLeftMessage
    
    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            ChatMessageBubble(
                size: $textSize,
                radiusSet: radiusSet,
                text: message.text,
                statusSubtitle: message.statusSubtitle,
                background: .cyan,
                quote: message.quote,
                menuActions: message.contextActions.compactMap { action in
                    UIAction(title: action.title, image: action.icon) { _ in
                        action.action(message.text, nil)
                    }
                }
            )
        }
        .frame(maxWidth: textSize.width, minHeight: textSize.height)
        .fixedSize(horizontal: false, vertical: true)
    }
}
