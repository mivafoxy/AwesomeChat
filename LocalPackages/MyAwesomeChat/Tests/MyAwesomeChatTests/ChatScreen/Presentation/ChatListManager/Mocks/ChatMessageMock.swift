//
//  ChatMessageMock.swift
//  MyAwesomeChat
//
//  Created by Илья Малахов on 18.05.2025.
//

import MyAwesomeChat

struct ChatMessageMock: MyChatMessage {
    let id: String
    let messageType: MyAwesomeChat.MyChatMessageType
    let isReplied: Bool
    let parentMessageId: String?
    let additionalParentMessageId: String?
    let timestamp: Int
    let text: String?
    let score: Int
    let actions: [any MyAwesomeChat.MyChatActionProtocol]?
    let action: String?
    let operatorName: String?
    let operatorId: String?
    let fromChannelId: String?
    let replyToMessage: (any MyAwesomeChat.MyChatMessage)?
    let buttons: [[any MyAwesomeChat.MyChatButtonProtocol]]?
}
