//
//  ChatListManagerTests.swift
//  MyAwesomeChat
//
//  Created by Илья Малахов on 18.05.2025.
//

import Testing
import Foundation
@testable import MyAwesomeChat

@Suite("Chat List Manager test suite")
struct ChatListManagerTests {
    
    // MARK: - Positive tests
    
    @Test func append_new_visitor_messages_to_empty_date_groups() {
        // Arrange
        
        let messages: [ChatMessage] = [1, 2, 3, 4, 5].compactMap { num in
            let content = "\(num) message"
            let messageMock = ChatMessageMock(
                id: "\(num)",
                messageType: .visitorMessage,
                isReplied: false,
                parentMessageId: nil,
                additionalParentMessageId: nil,
                timestamp: 1747551600,
                text: content,
                score: 0,
                actions: nil,
                action: nil,
                operatorName: "Operator",
                operatorId: "1",
                fromChannelId: "1",
                replyToMessage: nil,
                buttons: nil
            )
            return ChatMessage(message: messageMock, messageContent: content)
        }
        
        var dateGroups = [DateMessageGroup]()
        var botActions = [ChatBotAction]()
        let listManager = ChatListManager()
        
        // Act
        
        listManager.append(
            newMessages: messages,
            dateMessageGroups: &dateGroups,
            botActions: &botActions
        )
        
        // Assert
        
        #expect(botActions.isEmpty == true)
        #expect(dateGroups.count == 1)
        #expect(dateGroups[0].userMessageGroups.count == 1)
        #expect(dateGroups[0].userMessageGroups[0].messages.count == messages.count)
        
        for message in dateGroups[0].userMessageGroups[0].messages {
            #expect(messages.contains(message))
        }
    }
    
    @Test func append_history_messages_to_empty_date_groups() {
        // Arrange
        
        let messages: [MyChatMessage] = [1, 2, 3, 4, 5].compactMap { num in
            ChatMessageMock(
                id: "\(num)",
                messageType: .visitorMessage,
                isReplied: false,
                parentMessageId: nil,
                additionalParentMessageId: nil,
                timestamp: 1747465200,
                text: "\(num) history message",
                score: 0,
                actions: nil,
                action: nil,
                operatorName: "Operator",
                operatorId: "1",
                fromChannelId: "1",
                replyToMessage: nil,
                buttons: nil
            )
        }
        
        var dateGroups = [DateMessageGroup]()
        let listManager = ChatListManager()
        
        // Act
        
        listManager.append(
            historyMessages: messages,
            dateMessageGroups: &dateGroups
        )
        
        // Assert
        
        #expect(dateGroups.count == 1)
        #expect(dateGroups[0].userMessageGroups.count == 1)
        #expect(dateGroups[0].userMessageGroups[0].messages.count == messages.count)
        
        for message in messages {
            let chatMessage = ChatMessage(message: message, messageContent: message.text!)
            #expect(
                dateGroups[0].userMessageGroups[0].messages.contains(chatMessage)
            )
        }
    }
    
    @Test func append_system_messages_to_empty_date_groups() {
        // Arrange
        
        let messages: [ChatMessage] = [1, 2, 3, 4, 5].compactMap { num in
            let content = "Operator connected"
            let mock = ChatMessageMock(
                id: "\(num)",
                messageType: .connectedOperator,
                isReplied: false,
                parentMessageId: nil,
                additionalParentMessageId: nil,
                timestamp: 1747465200,
                text: content,
                score: 0,
                actions: nil,
                action: nil,
                operatorName: "Operator",
                operatorId: "1",
                fromChannelId: "1",
                replyToMessage: nil,
                buttons: nil
            )
            return ChatMessage(message: mock, messageContent: content)
        }
        
        var dateGroups = [DateMessageGroup]()
        let listManager = ChatListManager()
        
        // Act
        
        for message in messages {
            listManager.append(systemMessage: message, dateMessageGroups: &dateGroups)
        }
        
        // Assert
        
        #expect(dateGroups.count == 1)
        #expect(dateGroups[0].userMessageGroups.count == 1)
        #expect(dateGroups[0].userMessageGroups[0].messages.count == messages.count)
        
        for message in dateGroups[0].userMessageGroups[0].messages {
            #expect(
                messages.contains(message)
            )
        }
    }
    
    // MARK: - Negative tests
    
    @Test
    func append_history_visitor_messages_as_new_to_filled_date_groups() async throws {
        // Arrange
        
        let messages: [ChatMessage] = [1, 2, 3, 4, 5].compactMap { num in
            let content = "\(num) message"
            let messageMock = ChatMessageMock(
                id: "\(num)",
                messageType: .visitorMessage,
                isReplied: false,
                parentMessageId: nil,
                additionalParentMessageId: nil,
                timestamp: 1747551600,
                text: content,
                score: 0,
                actions: nil,
                action: nil,
                operatorName: "Operator",
                operatorId: "1",
                fromChannelId: "1",
                replyToMessage: nil,
                buttons: nil
            )
            return ChatMessage(message: messageMock, messageContent: content)
        }
        
        let userGroup = MessageGroup(
            id: "1",
            author: .remoteOperator(operatorName: "Operator"),
            messages: messages
        )
        
        let dateGroup = DateMessageGroup(
            id: "1",
            date: Date.init(timeIntervalSince1970: 1747551600),
            userMessageGroups: [userGroup]
        )
        
        let newOldMessages: [ChatMessage] = [6, 7, 8, 9, 10].compactMap { num in
            let content = "Operator connected"
            let mock = ChatMessageMock(
                id: "\(num) old message",
                messageType: .visitorMessage,
                isReplied: false,
                parentMessageId: nil,
                additionalParentMessageId: nil,
                timestamp: 1747465200,
                text: content,
                score: 0,
                actions: nil,
                action: nil,
                operatorName: "Operator",
                operatorId: "1",
                fromChannelId: "1",
                replyToMessage: nil,
                buttons: nil
            )
            return ChatMessage(message: mock, messageContent: content)
        }
        
        var dateGroups = [DateMessageGroup]()
        dateGroups.append(dateGroup)
        var botActions = [ChatBotAction]()
        let listManager = ChatListManager()
        
        // Act
        
        listManager.append(
            newMessages: newOldMessages,
            dateMessageGroups: &dateGroups,
            botActions: &botActions
        )
        
        // Assert
        
        #expect(dateGroups.count == 1)
        #expect(dateGroups[0].userMessageGroups.count == 1)
        #expect(dateGroups[0].userMessageGroups[0].messages.count == messages.count)
        for message in dateGroups[0].userMessageGroups[0].messages {
            #expect(
                messages.contains(message)
            )
        }
    }
}
