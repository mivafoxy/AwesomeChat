//
//  TaskHolder.swift
//  MyChat
//
//  Created by Илья Малахов on 14.05.2025.
//

actor TaskHolder<Input: Sendable, Result: Error> {
    private var task: Task<Input, Result>?
    
    func set(task: Task<Input, Result>) {
        self.task?.cancel()
        self.task = task
    }
    
    func cancelTask() {
        task?.cancel()
        task = nil
    }
}
