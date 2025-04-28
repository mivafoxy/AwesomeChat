//
//  ChatUserBubblesView.swift
//  
//
//  Created by Илья Малахов on 05.03.2025.
//

import SwiftUI
import MRDSKit

struct UserBubbleView: View {
    
    let message: UserMessage
    let offset: Int
    
    var body: some View {
        ChatBubbleRight(
            message: ChatRightMessage(
                id: message.id,
                text: message.content,
                statusSubtitle: message.timestampString,
                statusIcon: message.readStatus.icon,
                quote: getQuote(message),
                contextActions: getMessageContextActions(message.id)
            ),
            cornerRadiusSet: RadiusSet(
                topLeftRadius: 12.0,
                topRightRadius: offset == 0 ? 12.0 : 4.0,
                bottomLeftRadius: 12.0,
                bottomRightRadius: 4.0
            )
        )
    }
    
    private func getQuote(_ from: UserMessage) -> ChatBubbleQuote? {
        guard
            let replied = from.repliedMessage,
            let title = getTitle(replied)
        else {
            return nil
        }
        
        return ChatBubbleQuote(
            title: title,
            content: replied.message.text ?? "",
            image: nil,
            fileImage: nil
        )
    }
    
    private func getTitle(_ from: ChatMessage) -> String? {
        switch from.message.author {
        case let .remoteOperator(operatorName):
            return operatorName
        case .currentUser:
            return "user_quote_name".localized
        case .systemMessage, .unknown:
            return nil
        }
    }
    
    @MRBuilder<ChatContextAction>
    private func getMessageContextActions(_ messageId: String) -> [ChatContextAction] {
        ChatContextAction(
            title: "chat_copy".localized,
            icon: UIImage(systemName: "doc.on.doc")
        ) { (text, _) in
            UIPasteboard.general.string = text
        }
    }
}

struct ChatUserBubblesView: View {
    
    let userMessageGroup: MessageGroup
    
    var body: some View {
        let userMessages = getUserMessages()
        ForEach(
            Array(userMessages.enumerated()),
            id: \.element.id
        ) { offset, message in
            UserBubbleView(message: message, offset: offset)
        }
    }
    
    private func getUserMessages() -> [UserMessage] {
        userMessageGroup.messages.compactMap { UserMessage(message: $0) }
    }
}
