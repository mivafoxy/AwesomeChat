//
//  LoadHistoryUseCase.swift
//  MyChat
//
//  Created by Илья Малахов on 09.05.2025.
//

import Foundation

protocol LoadHistoryUseCaseProtocol: Sendable {
    func loadHistory(timespan: Int) async
    func loadHistoryAfterReconnect() async
    func observeHistoryMessages() -> AsyncStream<[MyChatMessage]>
}

final class LoadHistoryUseCase: LoadHistoryUseCaseProtocol {
    
    private let repository: ChatRepositoryProtocol
    
    init(repository: ChatRepositoryProtocol) {
        self.repository = repository
    }
    
    func loadHistory(timespan: Int) async {
        repository.loadHistory(with: timespan)
    }
    
    func loadHistoryAfterReconnect() async {
        guard let timeZone = TimeZone(identifier: "UTC") else { return }
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: .now)!
        let zeroPoint = Date.now.timeIntervalSince1970 + tomorrow.timeIntervalSinceNow
        repository.loadHistory(with: Int(zeroPoint))
    }
    
    func observeHistoryMessages() -> AsyncStream<[any MyChatMessage]> {
        repository.observeHistoryMessages()
    }
}
