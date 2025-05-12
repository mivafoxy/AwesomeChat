//
//  WebSocketChatService.swift
//  MyChat
//
//  Created by Илья Малахов on 05.05.2025.
//

class ChatEventProvider {
    
    // MARK: - Privates
    
    let chatService: MyChatWebApi
    
    // MARK: - Continuations
    
    private var connectionContinuation: AsyncStream<ConnectionState>.Continuation?
    private var authorizeContinuation: AsyncStream<AuthorizationState>.Continuation?
    private var errorContinuation: AsyncStream<ErrorState>.Continuation?
    private var receiveMessageContinuation: AsyncStream<MyChatMessage>.Continuation?
    private var receiveHistoryMessagesContinuation: AsyncStream<[MyChatMessage]>.Continuation?
    
    // MARK: - Init
    
    init(chatService: MyChatWebApi) {
        self.chatService = chatService
        chatService.setup(eventDelegate: self)
    }
    
    // MARK: - Streams
    
    func connectionStream() -> AsyncStream<ConnectionState> {
        AsyncStream { continuation in
            self.connectionContinuation = continuation
            continuation.onTermination = { _ in
                self.connectionContinuation = nil
            }
        }
    }

    func authorizeStream() -> AsyncStream<AuthorizationState> {
        AsyncStream { continuation in
            self.authorizeContinuation = continuation
            continuation.onTermination = { _ in
                self.authorizeContinuation = nil
            }
        }
    }

    func errorStream() -> AsyncStream<ErrorState> {
        AsyncStream { continuation in
            self.errorContinuation = continuation
            continuation.onTermination = { _ in
                self.errorContinuation = nil
            }
        }
    }

    func receiveMessageStream() -> AsyncStream<MyChatMessage> {
        AsyncStream { continuation in
            self.receiveMessageContinuation = continuation
            continuation.onTermination = { _ in
                self.receiveMessageContinuation = nil
            }
        }
    }

    func receiveHistoryMessagesStream() -> AsyncStream<[MyChatMessage]> {
        AsyncStream { continuation in
            self.receiveHistoryMessagesContinuation = continuation
            continuation.onTermination = { _ in
                self.receiveHistoryMessagesContinuation = nil
            }
        }
    }
}

// MARK: - MyChatEventDelegate

extension ChatEventProvider: MyChatEventDelegate {
    
    func didConnect() {
        connectionContinuation?.yield(.connected)
    }
    
    func didDisconnect() {
        connectionContinuation?.yield(.disconnected(error: nil))
    }
    
    func didReconnect() {
        connectionContinuation?.yield(.reconnect)
    }
    
    func didAuthorize() {
        authorizeContinuation?.yield(.authorized)
    }
    
    func didReceiveError(_ error: (any Error)?, _ data: Any?) {
        errorContinuation?.yield(ErrorState(error: error, data: data))
    }
    
    func didReceiveMessage(_ message: any MyChatMessage) {
        receiveMessageContinuation?.yield(message)
    }
    
    func didReceiveHistoryMessages(_ messages: [any MyChatMessage]) {
        receiveHistoryMessagesContinuation?.yield(messages)
    }
}
