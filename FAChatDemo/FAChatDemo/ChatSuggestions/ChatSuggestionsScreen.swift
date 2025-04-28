//
//  ChatSuggestionsScreen.swift
//  
//
//  Created by Илья Малахов on 02.12.2024.
//

import SwiftUI
import FAChat

struct ChatSuggestionsScreen: View {
    
    let suggestions: [String] = [
        "Some long item here",
        "And then some longer one",
        "Short", "Items", "Here", "And", "A", "Few", "More",
        "And then a very very very long long long long long long long long longlong long long long long long longlong long long long long long longlong long long long long long longlong long long long long long longlong long long long long long long long one",
        "and",
        "then",
        "some",
        "short short short ones"
    ]
    
    var body: some View {
        ScrollView {
            ChatSuggestions(
                suggestions:
                    suggestions.compactMap {
                        ChatSuggestionAction(title: $0, onTap: { print($0) })
                    }
            )
        }
    }
}
