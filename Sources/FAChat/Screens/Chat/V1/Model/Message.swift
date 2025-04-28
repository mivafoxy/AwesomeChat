//
//  Message.swift
//  
//
//  Created by Илья Малахов on 24.11.2024.
//

import Foundation
import MRDSKit

// MARK: - Common message

final class ChatMessage: Identifiable, Hashable {
    let id: String
    var readStatus: MessageReadStatus = .read
    let content: String
    let repliedMessage: ChatMessage?
    let timestamp: Date
    let message: FAChatMessage
    
    init(message: FAChatMessage, messageContent: String) {
        self.id = message.id
        self.content = messageContent
        self.timestamp = message.getTimestamp()
        if let replied = message.replyToMessage {
            self.repliedMessage = ChatMessage(message: replied, messageContent: "")
        } else {
            self.repliedMessage = nil
        }
        self.message = message
    }
    
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        lhs.id == rhs.id &&
        lhs.readStatus == rhs.readStatus &&
        lhs.content == rhs.content &&
        lhs.timestamp == rhs.timestamp &&
        lhs.repliedMessage == rhs.repliedMessage
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(readStatus)
        hasher.combine(content)
        hasher.combine(timestamp)
        hasher.combine(repliedMessage)
    }
}

// MARK: - User messages

struct UserMessage: Identifiable {
    let id: String
    let content: String
    let timestamp: Date
    let repliedMessage: ChatMessage?
    let readStatus: MessageReadStatus
    
    var timestampString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: timestamp)
    }
    
    init(message: ChatMessage) {
        self.id = message.id
        self.content = message.content
        self.timestamp = message.timestamp
        self.readStatus = message.readStatus
        if let replied = message.repliedMessage {
            self.repliedMessage = replied
        } else {
            self.repliedMessage = nil
        }
    }
}

// MARK: - Operator messages

struct OperatorMessage: Identifiable {
    let id: String
    let content: String
    let timestamp: Date
    let repliedMessage: ChatMessage?
    
    var timestampString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: timestamp)
    }
    
    init(message: ChatMessage) {
        self.id = message.id
        self.content = message.content
        self.timestamp = message.timestamp
        if let replied = message.repliedMessage {
            self.repliedMessage = replied
        } else {
            self.repliedMessage = nil
        }
    }
}

// MARK: - System messages

struct SystemMessage: Identifiable {
    let id: String
    let content: String
    
    init(message: ChatMessage) {
        self.id = message.id
        self.content = message.content
    }
    
    init(id: String, content: String) {
        self.id = id
        self.content = content
    }
}

struct ChatBotAction: Equatable {
    let id: String
    let content: String
    
    init(action: FAChatActionProtocol) {
        self.id = action.id
        self.content = action.text
    }
    
    static func == (_ lhs: ChatBotAction, _ rhs: ChatBotAction) -> Bool {
        lhs.content == rhs.content && lhs.id == rhs.id
    }
}

// MARK: - Message author

enum MessageAuthor: Equatable {
    case unknown
    case remoteOperator(operatorName: String)
    case currentUser
    case systemMessage
}

// MARK: - Message status

enum MessageReadStatus {
    case read
    case unread
    
    var icon: MRImage {
        switch self {
        case .read:
            return Asset.Size16.Service.SmallStatusRead
        case .unread:
            return Asset.Size16.Service.SmallStatusUnread
        }
    }
}

// MARK: - MCChatMessageProtocol+Helper

extension FAChatMessage {
    var author: MessageAuthor {
        if
            let operatorName = operatorName,
            .visitorMessage == messageType
        {
            return .remoteOperator(operatorName: operatorName)
        } else if .visitorMessage == messageType {
            return .currentUser
        } else if .finishDialog == messageType || .connectedOperator == messageType {
            return .systemMessage
        } else {
            return .unknown
        }
    }
    
    func getTimestamp() -> Date {
        let unixTimeInSeconds = TimeInterval(timestamp) / 1000
        return Date(timeIntervalSince1970: unixTimeInSeconds)
    }
}
