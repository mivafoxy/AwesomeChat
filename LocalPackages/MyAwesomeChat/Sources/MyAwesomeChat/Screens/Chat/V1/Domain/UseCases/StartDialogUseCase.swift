//
//  StartDialogUseCase.swift
//  MyChat
//
//  Created by Илья Малахов on 08.05.2025.
//

protocol StartDialogUseCaseProtocol: Sendable {
    func execute()
}

final class StartDialogUseCase: StartDialogUseCaseProtocol {
    
    private let repository: ChatRepositoryProtocol

    init(repository: ChatRepositoryProtocol) {
        self.repository = repository
    }

    func execute() {
        repository.startDialog()
    }
}
