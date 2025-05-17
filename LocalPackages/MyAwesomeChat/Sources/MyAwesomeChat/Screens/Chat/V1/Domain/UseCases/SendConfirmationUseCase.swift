//
//  SendConfirmationUseCase.swift
//  MyChat
//
//  Created by Илья Малахов on 09.05.2025.
//

protocol SendConfirmationUseCaseProtocol: Sendable {
    func sendConfirmation(for oneMessageId: String)
    func sendConfirmation(for messageIds: [String]) async
}

final class SendConfirmationUseCase: SendConfirmationUseCaseProtocol {
    
    private let repository: ChatRepositoryProtocol
    private let confirmationSendingTask: TaskHolder<Void, Never>
    
    init(repository: ChatRepositoryProtocol) {
        self.repository = repository
        confirmationSendingTask = TaskHolder()
    }
    
    func sendConfirmation(for oneMessageId: String) {
        Task.detached(priority: .background) { [chatRepository = repository] in
            chatRepository.sendReadConfirmation(messageId: oneMessageId)
        }
    }
    
    func sendConfirmation(for messageIds: [String]) async {
        await confirmationSendingTask.cancelTask()
        let task = Task.detached { [weak self] in
            await withTaskGroup(of: Void.self) { [weak self] group in
                guard let self = self else { return }
                for messageId in messageIds {
                    group.addTask { [weak self] in
                        self?.repository.sendReadConfirmation(messageId: messageId)
                    }
                }
            }
        }
        await confirmationSendingTask.set(task: task)
    }
}
