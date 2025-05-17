//
//  Sequence+Extension.swift
//  MyChat
//
//  Created by Илья Малахов on 16.05.2025.
//

extension Sequence {
    
    func forEachAsync<Element: Sendable>(_ completion: @Sendable @escaping (Element) async -> Void) async where Element == Self.Element {
        await withTaskGroup(of: Void.self) { group in
            for item in self {
                group.addTask {
                    await completion(item)
                }
            }
        }
    }
}
