//
//  ChatSuggestionAction.swift
//  
//
//  Created by Илья Малахов on 02.12.2024.
//

public final class ChatSuggestionAction {
    let title: String
    let onTap: (String) -> ()
    
    public init(title: String, onTap: @escaping (String) -> ()) {
        self.title = title
        self.onTap = onTap
    }
}
