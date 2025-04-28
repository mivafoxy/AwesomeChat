//
//  FAChatMessage.swift
//  FAChat
//
//  Created by Илья Малахов on 28.04.2025.
//

public protocol FAChatMessage {
    var id: String { get }
    var messageType: FAChatMessageType { get }
    var isReplied: Bool { get }
    var parentMessageId: String? { get }
    var additionalParentMessageId: String? { get }
    var timestamp: Int { get }
    var text: String? { get }
    var score: Int { get }
    var actions: [FAChatActionProtocol]? { get }
    var action: String? { get }
    var operatorName: String? { get }
    var operatorId: String? { get }
    var fromChannelId: String? { get }
    var replyToMessage: FAChatMessage? { get }
    var buttons: [[FAChatButtonProtocol]]? { get }
}
