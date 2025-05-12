//
//  ChatBubbleLeftV2.swift
//  
//
//  Created by Илья Малахов on 14.02.2025.
//

import SwiftUI

public struct ChatBubbleLeft: View {
    
    public let title: String?
    public let userName: String?
    public let message: ChatLeftMessage
    public let avatar: Image?
    public let cornerRadiusSet: RadiusSet
    
    public init(
        title: String? = nil,
        userName: String? = nil,
        message: ChatLeftMessage,
        avatar: Image? = nil,
        cornerRadiusSet: RadiusSet
    ) {
        self.title = title
        self.userName = userName
        self.message = message
        self.avatar = avatar
        self.cornerRadiusSet = cornerRadiusSet
    }
    
    @ViewBuilder public var body: some View {
        VStack(spacing: .zero) {
            userNameLabel
            HStack(alignment: .bottom, spacing: 4.0) {
                avatarView
                messageBubble
                Spacer(minLength: 64.0)
            }
            Spacer().frame(height: 4.0)
        }
        .padding(.leading, 8.0)
    }
    
    @ViewBuilder private var userNameLabel: some View {
        if let title = title {
            VStack {
                Spacer().frame(height: 8.0)
                HStack {
                    ChatUserNameLabel(userName: title)
                        .padding(.leading, 32.0)
                    Spacer()
                }
                Spacer().frame(height: 4.0)
            }
        }
    }
    
    @ViewBuilder private var avatarView: some View {
        if let avatar = avatar {
            avatar
                .resizable()
                .frame(width: 20, height: 20)
        } else if let userName = userName {
            ChatAvatarLetter(userName: userName)
        } else {
            Rectangle()
                .foregroundStyle(.clear)
                .frame(width: 20, height: 20)
        }
    }
    
    @ViewBuilder private var messageBubble: some View {
        ChatMessageLeftBubble(
            radiusSet: cornerRadiusSet,
            message: message
        )
    }
}

#Preview {
    ChatBubbleLeft(
        title: "Title",
        userName: "UserName",
        message: .init(text: "sdfsdfsfsdffdsfdffsdfsfddfsfs", statusSubtitle: "21:00"), avatar: nil,
        cornerRadiusSet: .init(allRadius: 6)
    )
}
