//
//  ChatMessageRightBubble.swift
//  
//
//  Created by Илья Малахов on 16.01.2025.
//

import SwiftUI

struct ChatMessageRightBubble: View {
    
    let radiusSet: RadiusSet
    let message: ChatRightMessage
    @State private var textSize: CGSize = .zero
    
    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            ChatMessageBubble(
                size: $textSize,
                statusIcon: message.statusIcon?.getUIImage(newSize: CGSize(width: 16, height: 16)),
                radiusSet: radiusSet,
                text: message.text,
                statusSubtitle: message.statusSubtitle,
                background: UIColor(.teal),
                quote: message.quote,
                menuActions: message.contextActions.compactMap { action in
                    UIAction(title: action.title, image: action.icon) { _ in
                        action.action(message.text, nil)
                    }
                }
            )
        }
        .frame(maxWidth: textSize.width, minHeight: textSize.height, alignment: .center)
        .fixedSize(horizontal: false, vertical: true)
    }
}
