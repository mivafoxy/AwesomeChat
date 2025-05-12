//
//  UserMessageGroup.swift
//  
//
//  Created by Илья Малахов on 24.11.2024.
//

struct MessageGroup: Identifiable, Equatable {
    let id: String
    let author: MessageAuthor
    var messages: [ChatMessage]
    
    static func == (lhs: MessageGroup, rhs: MessageGroup) -> Bool {
        lhs.id == rhs.id &&
        lhs.author == rhs.author &&
        lhs.messages == rhs.messages
    }
}
