//
//  ChatBubbleRightV2.swift
//  
//
//  Created by Илья Малахов on 14.02.2025.
//

import SwiftUI

public struct ChatBubbleRight: View {
    
    public let message: ChatRightMessage
    public let cornerRadiusSet: RadiusSet
    
    public init(
        message: ChatRightMessage,
        cornerRadiusSet: RadiusSet
    ) {
        self.message = message
        self.cornerRadiusSet = cornerRadiusSet
    }
    
    public var body: some View {
        bubble
            .padding(.bottom, 4.0)
            .padding(.trailing, 12.0)
            .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    @ViewBuilder private var bubble: some View {
        HStack(alignment: .bottom, spacing: 0) {
            VStack(alignment: .trailing, spacing: .zero) {
                ChatMessageRightBubble(
                    radiusSet: cornerRadiusSet,
                    message: message
                )
            }
        }
    }
}
