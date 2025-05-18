//
//  ChatListManagerV2.swift
//  MyChat
//
//  Created by Илья Малахов on 09.05.2025.
//

import Foundation

final class ChatListManager {
    
    private var messageIds = Set<String>()
    
    func append(historyMessages: [MyChatMessage], dateMessageGroups: inout [DateMessageGroup]) {
        let visitorMessages = getVisitorMessages(historyMessages, dateMessageGroups)
        
        // При ситуации, когда приложение
        // свёрнуто, и оператор присылает сообщения, они не отображаются
        // Это происходит из-за того, что при свернутом приложении
        // сокет отключается, идет переподключение, а события
        // про новые сообщения не поступают.
        // Без доработок бэка есть способ принудительно загрузить новые сообщения -
        // попросить историю с timestamp = следуюший день.
        // Это требует корректировки алгоритма добавления сообщений, чтобы новые сообщения
        // добавлялись в правильном порядке.
        
        let last = getAllMessages(from: dateMessageGroups)
            .sorted { $0.timestamp < $1.timestamp }
            .last

        for message in visitorMessages {
            if let last = last, last.timestamp < message.timestamp {
                append(newMessage: message, dateMessageGroups: &dateMessageGroups)
            } else {
                append(oldMessage: message, dateMessageGroups: &dateMessageGroups)
            }
        }
    }
    
    func append(
        newMessages: [ChatMessage],
        dateMessageGroups: inout [DateMessageGroup],
        botActions: inout [ChatBotAction]
    ) {
        guard isNewMessages(newMessages, dateMessageGroups) else { return }
        for message in newMessages {
            guard !hasMessage(message) else { continue }
            messageIds.insert(message.id)
            append(newMessage: message, dateMessageGroups: &dateMessageGroups)
        }
        botActions = getBotActions(from: dateMessageGroups)
    }
    
    func append(systemMessage: ChatMessage, dateMessageGroups: inout [DateMessageGroup]) {
        guard !hasMessage(systemMessage) else { return }
        messageIds.insert(systemMessage.id)
        append(newMessage: systemMessage, dateMessageGroups: &dateMessageGroups)
    }
    
    func getEarliestTimestamp(from dateMessageGroups: [DateMessageGroup]) -> Int {
        let earliestMessage = getAllMessages(from: dateMessageGroups)
            .min { $0.message.timestamp < $1.message.timestamp }
        return earliestMessage?.message.timestamp ?? 0
    }
    
    func getOperatorMessages(from dateMessageGroups: [DateMessageGroup]) -> [ChatMessage] {
        dateMessageGroups
            .flatMap { $0.userMessageGroups }
            .filter {
                switch $0.author {
                case .remoteOperator:
                    return true
                default:
                    return false
                }
            }
            .flatMap { $0.messages }
    }
    
    func getBotActions(from dateMessageGroups: [DateMessageGroup]) -> [ChatBotAction] {
        guard let userGroup = dateMessageGroups.first?.userMessageGroups.last else {
            return []
        }
        let messagesWithActions = userGroup.messages
            .filter { ($0.message.actions?.count ?? 0) > 0 }
            .sorted(
                by: { $0.message.timestamp < $1.message.timestamp }
            )
        guard
            let lastActionMessage = messagesWithActions.last,
            let actions = lastActionMessage.message.actions
        else {
            return []
        }
        
        return actions.compactMap {
            ChatBotAction(action: $0)
        }
    }
    
    func getAllMessages(from dateMessageGroups: [DateMessageGroup]) -> [ChatMessage] {
        dateMessageGroups
            .flatMap { $0.userMessageGroups }
            .flatMap { $0.messages }
    }
    
    func getIndiciesForMessage(
        with id: String,
        dateMessageGroups: [DateMessageGroup]
    ) -> (dateGroup: Int, userGroup: Int, message: Int)? {
        let indices: (dateGroup: Int, userGroup: Int, message: Int)? = dateMessageGroups
            .enumerated()
            .lazy
            .compactMap { dateGroupIndex, dateGroup in
                if
                    let userGroupIndex = dateGroup.userMessageGroups.firstIndex(where: { userGroup in
                        userGroup.messages.contains { $0.id == id }
                    }),
                    let messageIndex = dateGroup.userMessageGroups[userGroupIndex].messages.firstIndex(where: { $0.id == id })
                {
                    return (
                        dateGroup: dateGroupIndex,
                        userGroup: userGroupIndex,
                        message: messageIndex
                    )
                }
                return nil
            }
            .first
        
        return indices
    }
    
    func getFirstUnreadMessageId(from dateMessageGroups: [DateMessageGroup]) -> String? {
        getAllMessages(from: dateMessageGroups).first { $0.readStatus == .unread }?.id
    }
    
    // MARK: - Backward (for history) message appending
    
    private func append(oldMessage: ChatMessage, dateMessageGroups: inout [DateMessageGroup]) {
        if dateMessageGroups.isEmpty {
            dateMessageGroups.append(getDateGroup(with: oldMessage))
        } else {
            insert(oldMessage: oldMessage, dateMessageGroups: &dateMessageGroups)
        }
    }
    
    private func insert(oldMessage: ChatMessage, dateMessageGroups: inout [DateMessageGroup]) {
        guard
            let timeZone = TimeZone(identifier: "UTC"),
            let oldDateGroup = dateMessageGroups.last?.date.startOfDay(),
            !hasMessage(oldMessage)
        else {
            return
        }
        messageIds.insert(oldMessage.id)
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        let messageDate = oldMessage.message.getTimestamp().startOfDay()
        
        if calendar.isDate(messageDate, inSameDayAs: oldDateGroup) {
            appendToBack(oldMessage: oldMessage, dateMessageGroups: &dateMessageGroups)
        } else {
            dateMessageGroups.append(getDateGroup(with: oldMessage))
        }
    }
    
    private func appendToBack(oldMessage: ChatMessage, dateMessageGroups: inout [DateMessageGroup]) {
        let userGroup = dateMessageGroups.last?.userMessageGroups.first
        let lastDateGroup = dateMessageGroups.count - 1
        let lastUserGroup = 0
        if userGroup?.author == oldMessage.message.author {
            dateMessageGroups[lastDateGroup]
                .userMessageGroups[lastUserGroup]
                .messages
                .append(oldMessage)
            dateMessageGroups[lastDateGroup].userMessageGroups[lastUserGroup].messages.sort {
                $0.message.timestamp < $1.message.timestamp
            }
        } else {
            dateMessageGroups[lastDateGroup]
                .userMessageGroups
                .insert(getMessageGroup(message: oldMessage), at: 0)
        }
    }
    
    // MARK: - Forward message appending
    
    private func append(newMessage: ChatMessage, dateMessageGroups: inout [DateMessageGroup]) {
        if dateMessageGroups.isEmpty {
            dateMessageGroups.append(getDateGroup(with: newMessage))
        } else {
            appendForwardly(message: newMessage, dateMessageGroups: &dateMessageGroups)
        }
    }
    
    private func appendForwardly(message: ChatMessage, dateMessageGroups: inout [DateMessageGroup]) {
        guard
            let timeZone = TimeZone(identifier: "UTC"),
            let newestDateGroup = dateMessageGroups.first?.date.startOfDay()
        else {
            return
        }
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        let messageDate = message.message.getTimestamp().startOfDay()
        if calendar.isDate(messageDate, inSameDayAs: newestDateGroup) {
            append(message: message, toDateGroup: 0, dateMessageGroups: &dateMessageGroups)
        } else {
            dateMessageGroups.insert(getDateGroup(with: message), at: 0)
        }
    }
    
    private func append(message: ChatMessage, toDateGroup: Int, dateMessageGroups: inout [DateMessageGroup]) {
        let lastMessageAuthor = dateMessageGroups[toDateGroup].userMessageGroups.last?.author
        if lastMessageAuthor == message.message.author {
            let lastUserGroup = dateMessageGroups[toDateGroup].userMessageGroups.count - 1
            dateMessageGroups[toDateGroup]
                .userMessageGroups[lastUserGroup]
                .messages
                .append(message)
            dateMessageGroups[toDateGroup]
                .userMessageGroups[lastUserGroup]
                .messages
                .sort { $0.message.timestamp < $1.message.timestamp }
        } else {
            let newMessageGroup = getMessageGroup(message: message)
            dateMessageGroups[toDateGroup]
                .userMessageGroups
                .append(newMessageGroup)
        }
    }
    
    // MARK: - Helpers
    
    private func getDateGroup(with message: ChatMessage) -> DateMessageGroup {
        let date = message.message.getTimestamp().startOfDay()
        let userGroup = getMessageGroup(message: message)
        return DateMessageGroup(id: UUID().uuidString, date: date, userMessageGroups: [userGroup])
    }
    
    private func getMessageGroup(message: ChatMessage) -> MessageGroup {
        MessageGroup(id: UUID().uuidString, author: message.message.author, messages: [message])
    }
    
    private func getVisitorMessages(
        _ messages: [MyChatMessage],
        _ dateMessageGroups: [DateMessageGroup]
    ) -> [ChatMessage] {
        let allMessages = dateMessageGroups
            .flatMap { $0.userMessageGroups }
            .flatMap { $0.messages }
        let nonSystemMessages = messages
            .filter { $0.messageType == .visitorMessage }
            .filter { oldMessage in
                if let text = oldMessage.text {
                    return !text.isEmpty
                } else {
                    return false
                }
            }
            .filter { oldMessage in
                !allMessages.contains(where: { chatMessage in
                    chatMessage.id == oldMessage.id &&
                    chatMessage.message.fromChannelId == oldMessage.fromChannelId
                })
            }
            .compactMap {
                ChatMessage(
                    message: $0,
                    messageContent: $0.text ?? ""
                )
            }
        return nonSystemMessages
    }
    
    private func hasMessage(_ message: ChatMessage) -> Bool {
        hasMessage(with: message.id)
    }
    
    private func hasMessage(with id: String) -> Bool {
        messageIds.contains(id)
    }
    
    private func isNewMessages(_ messages: [ChatMessage], _ dateMessageGroup: [DateMessageGroup]) -> Bool {
        if let last = getAllMessages(from: dateMessageGroup).last {
            for message in messages {
                if message.timestamp < last.timestamp {
                    return false
                }
            }
        }
        return true
    }
}
