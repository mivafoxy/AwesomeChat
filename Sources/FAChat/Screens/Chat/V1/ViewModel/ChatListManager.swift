//
//  ChatListManager.swift
//  
//
//  Created by Илья Малахов on 22.01.2025.
//

import Foundation

extension ChatViewModel {
    
    func append(historyMessages: [FAChatMessage]) {
        let visitorMessages = getVisitorMessages(historyMessages)
        
        // При ситуации, когда приложение
        // свёрнуто, и оператор присылает сообщения, они не отображаются
        // Это происходит из-за того, что при свернутом приложении
        // сокет отключается, идет переподключение, а события
        // про новые сообщения не поступают.
        // Без доработок бэка есть способ принудительно загрузить новые сообщения -
        // попросить историю с timestamp = следуюший день.
        // Это требует корректировки алгоритма добавления сообщений, чтобы новые сообщения
        // добавлялись в правильном порядке.
        
        let last = getAllMessages().sorted { $0.timestamp < $1.timestamp }.last

        for message in visitorMessages {
            if let last = last {
                if last.timestamp < message.timestamp {
                    append(newMessage: message)
                }
            } else {
                append(oldMessage: message)
            }
        }
    }
    
    func append(newMessages: [ChatMessage]) {
        for message in newMessages {
            guard !hasMessage(message) else { continue }
            messageIds.insert(message.id)
            append(newMessage: message)
        }
        botActions = getBotActions()
    }
    
    func append(systemMessage: ChatMessage) {
        guard !hasMessage(systemMessage) else { return }
        messageIds.insert(systemMessage.id)
        append(newMessage: systemMessage)
    }
    
    func getEarliestTimestamp() -> Int {
        let earliestMessage = getAllMessages()
            .min { $0.message.timestamp < $1.message.timestamp }
        return earliestMessage?.message.timestamp ?? 0
    }
    
    func getOperatorMessages() -> [ChatMessage] {
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
    
    func getBotActions() -> [ChatBotAction] {
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
    
    func getAllMessages() -> [ChatMessage] {
        dateMessageGroups
            .flatMap { $0.userMessageGroups }
            .flatMap { $0.messages }
    }
    
    func setMessageStatus(with id: String, _ status: MessageReadStatus) {
        struct MessageIndices {
            let dateGroup: Int
            let userGroup: Int
            let message: Int
        }
        
        let indices: MessageIndices? = dateMessageGroups
            .enumerated()
            .lazy
            .compactMap { dateGroupIndex, dateGroup in
                if
                    let userGroupIndex = dateGroup.userMessageGroups.firstIndex(where: { userGroup in
                        userGroup.messages.contains { $0.id == id }
                    }),
                    let messageIndex = dateGroup.userMessageGroups[userGroupIndex].messages.firstIndex(where: { $0.id == id })
                {
                    return MessageIndices(
                        dateGroup: dateGroupIndex,
                        userGroup: userGroupIndex,
                        message: messageIndex
                    )
                }
                return nil
            }
            .first
        
        guard let indices = indices else { return }
        
        let oldMessage = dateMessageGroups[indices.dateGroup]
            .userMessageGroups[indices.userGroup]
            .messages[indices.message]
        let newMessage = ChatMessage(
            message: oldMessage.message,
            messageContent: oldMessage.content
        )
        newMessage.readStatus = status
        Task.detached { @MainActor [weak self] in
            self?.dateMessageGroups[indices.dateGroup]
                .userMessageGroups[indices.userGroup]
                .messages[indices.message] = newMessage
        }
    }
    
    func getFirstUnreadMessageId() -> String? {
        getAllMessages().first { $0.readStatus == .unread }?.id
    }
    
    // MARK: - Backward (for history) message appending
    
    private func append(oldMessage: ChatMessage) {
        if dateMessageGroups.isEmpty {
            dateMessageGroups.append(getDateGroup(with: oldMessage))
        } else {
            insert(oldMessage: oldMessage)
        }
    }
    
    private func insert(oldMessage: ChatMessage) {
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
            appendToBack(oldMessage: oldMessage)
        } else {
            dateMessageGroups.append(getDateGroup(with: oldMessage))
        }
    }
    
    private func appendToBack(oldMessage: ChatMessage) {
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
    
    private func append(newMessage: ChatMessage) {
        if dateMessageGroups.isEmpty {
            dateMessageGroups.append(getDateGroup(with: newMessage))
        } else {
            appendForwardly(message: newMessage)
        }
    }
    
    private func appendForwardly(message: ChatMessage) {
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
            append(message: message, toDateGroup: 0)
        } else {
            dateMessageGroups.insert(getDateGroup(with: message), at: 0)
        }
    }
    
    private func append(message: ChatMessage, toDateGroup: Int) {
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
    
    private func getVisitorMessages(_ messages: [FAChatMessage]) -> [ChatMessage] {
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
}
