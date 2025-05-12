//
//  ChatLoader.swift
//  
//
//  Created by Илья Малахов on 24.11.2024.
//

import Foundation

protocol ChatLoader: AnyObject {
    func connect() async throws
    func startDialog()
    func loadHistory(with timestamp: Int)
    func sendMessage(content: String, repliedMessage: ChatMessage?)
    func sendAction(id: String)
    func sendReadingConfirmation(for messageId: String)
    func sendOperator(score: Int)
    func disconnect()
    func setup(eventDelegate: MyChatEventDelegate)
}

final class ChatApiLoader: ChatLoader {
    
    // MARK: - Private properties
    
    private let chatApi: MyChatWebApi
    
    // MARK: - Init
    
    init(chatApi: MyChatWebApi) {
        self.chatApi = chatApi
    }
    
    // MARK: ChatLoader
    
    func connect() async throws {
        try await chatApi.connect()
    }
    
    func startDialog() {
        chatApi.startDialog()
    }
    
    func loadHistory(with timestamp: Int) {
        chatApi.loadHistory(with: timestamp)
    }
    
    func sendMessage(content: String, repliedMessage: ChatMessage?) {
        chatApi.send(content: content, repliedMessage?.message)
    }
    
    func sendAction(id: String) {
        chatApi.sendAction(with: id)
    }
    
    func sendReadingConfirmation(for messageId: String) {
        chatApi.sendReadConfirmation(messageId: messageId)
    }
    
    func sendOperator(score: Int) {
        chatApi.send(operatorScore: score)
    }
    
    func disconnect() {
        chatApi.disconnect()
    }
    
    func setup(eventDelegate: MyChatEventDelegate) {
        chatApi.setup(eventDelegate: eventDelegate)
    }
}
