//
//  ChatRemoteOperatorBubblesView.swift
//  
//
//  Created by Илья Малахов on 05.03.2025.
//

import SwiftUI

struct ChatRemoteOperatorBubblesView: View {
    
    private let operatorName: String
    private let userMessageGroup: MessageGroup
    private let onContextAction: (String) -> ()
    private let onProxyChange: (GeometryProxy, ChatMessage) -> ()
    
    init(
        operatorName: String,
        userMessageGroup: MessageGroup,
        onContextAction: @escaping (String) -> (),
        onProxyChange: @escaping (GeometryProxy, ChatMessage) -> ()
    ) {
        self.operatorName = operatorName
        self.userMessageGroup = userMessageGroup
        self.onContextAction = onContextAction
        self.onProxyChange = onProxyChange
    }
    
    var body: some View {
        let operatorMessages = userMessageGroup.messages
        ForEach(
            Array(operatorMessages.enumerated()),
            id: \.element.id
        ) { offset, message in
            let operatorMessage = OperatorMessage(message: message)
            ChatBubbleLeft(
                title: offset == 0 ? operatorName : nil,
                userName: offset == operatorMessages.count - 1 ?  operatorName : nil,
                message: ChatLeftMessage(
                    id: operatorMessage.id,
                    text: operatorMessage.content,
                    statusSubtitle: operatorMessage.timestampString,
                    quote: getQuote(operatorMessage),
                    contextActions: getMessageContextActions(operatorMessage)
                ),
                avatar: nil,
                cornerRadiusSet: RadiusSet(
                    topLeftRadius: offset == 0 ? 12.0 : 4.0,
                    topRightRadius: 12.0,
                    bottomLeftRadius: 4.0,
                    bottomRightRadius: 12.0
                )
            )
            .background {
                if message.readStatus == .unread {
                    GeometryReader { proxy in
                        Rectangle()
                            .fill(.clear)
                            .onAppear {
                                onProxyChange(proxy, message)
                            }
                            .onChange(of: proxy.frame(in: .global)) { _, _ in
                                onProxyChange(proxy, message)
                            }
                        }
                    }
                }
        }
    }
    
    private func getQuote(_ from: OperatorMessage) -> ChatBubbleQuote? {
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
    
    private func getMessageContextActions(_ message: OperatorMessage) -> [ChatContextAction] {
        [
            ChatContextAction(
                title: "chat_copy".localized,
                icon: UIImage(systemName: "doc.on.doc")
            ) { (text, _) in
                UIPasteboard.general.string = text
            },
            ChatContextAction(
                title: "chat_quote".localized,
                icon: UIImage(systemName: "arrowshape.turn.up.backward")
            ) { (_, _) in
                onContextAction(message.id)
            }
        ]
    }
}
