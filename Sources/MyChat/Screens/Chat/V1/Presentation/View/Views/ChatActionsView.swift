//
//  ChatActionsView.swift
//  
//
//  Created by Илья Малахов on 05.03.2025.
//

import SwiftUI

struct ChatActionsView: View {
    
    @Binding var actions: [ChatBotAction]
    let onChatBotAction: (ChatBotAction) -> ()
    
    var body: some View {
        if !actions.isEmpty {
            VStack(spacing: 8) {
                VStack(spacing: .zero) {
                    ChatSuggestions(suggestions: getChatSuggestionAction(actions))
                }
            }
        }
    }
    
    private func getChatSuggestionAction(_ chatBotActions: [ChatBotAction]) -> [ChatSuggestionAction] {
        chatBotActions.compactMap { action in
            ChatSuggestionAction(
                title: action.content,
                onTap: { _ in onChatBotAction(action) }
            )
        }
        .reversed()
    }
}
