//
//  SendConfirmationUseCase.swift
//  FAChat
//
//  Created by Илья Малахов on 09.05.2025.
//

protocol SendConfirmationUseCaseProtocol {
    func sendConfirmation(for oneMessageId: String)
    func sendConfirmation(for messageIds: [String])
}

final class SendConfirmationUseCase: SendConfirmationUseCaseProtocol {
    
    private let repository: ChatRepositoryProtocol
    private var confirmationSendingTask: Task<Void, Never>?
    
    init(repository: ChatRepositoryProtocol) {
        self.repository = repository
    }
    
    func sendConfirmation(for oneMessageId: String) {
        Task.detached(priority: .background) { [weak self] in
            self?.repository.sendReadConfirmation(messageId: oneMessageId)
        }
    }
    
    func sendConfirmation(for messageIds: [String]) {
        confirmationSendingTask?.cancel()
        confirmationSendingTask = Task.detached { [weak self] in
            await withTaskGroup(of: Void.self) { [weak self] group in
                guard let self = self else { return }
                for messageId in messageIds {
                    group.addTask { [weak self] in
                        self?.repository.sendReadConfirmation(messageId: messageId)
                    }
                }
            }
        }
    }
}
