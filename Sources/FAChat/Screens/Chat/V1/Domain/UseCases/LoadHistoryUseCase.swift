//
//  LoadHistoryUseCase.swift
//  FAChat
//
//  Created by Илья Малахов on 09.05.2025.
//

import Foundation

protocol LoadHistoryUseCaseProtocol {
    func loadHistory(timespan: Int)
    func loadHistoryAfterReconnect()
    func observeHistoryMessages() -> AsyncStream<[FAChatMessage]>
}

final class LoadHistoryUseCase: LoadHistoryUseCaseProtocol {
    
    private let repository: ChatRepositoryProtocol
    private var loadHistoryTask: Task<Void, Never>?
    
    init(repository: ChatRepositoryProtocol) {
        self.repository = repository
    }
    
    func loadHistory(timespan: Int) {
        loadHistoryTask?.cancel()
        loadHistoryTask = Task.detached(priority: .userInitiated) { [weak self] in
            self?.repository.loadHistory(with: timespan)
        }
    }
    
    func loadHistoryAfterReconnect() {
        guard let timeZone = TimeZone(identifier: "UTC") else { return }
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: .now)!
        let zeroPoint = Date.now.timeIntervalSince1970 + tomorrow.timeIntervalSinceNow
        
        loadHistoryTask?.cancel()
        loadHistoryTask = Task.detached(priority: .userInitiated) { [weak self] in
            self?.repository.loadHistory(with: Int(zeroPoint))
        }
    }
    
    func observeHistoryMessages() -> AsyncStream<[any FAChatMessage]> {
        repository.observeHistoryMessages()
    }
}
