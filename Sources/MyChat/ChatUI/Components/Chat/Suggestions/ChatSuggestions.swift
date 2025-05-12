//
//  ChatSuggestions.swift
//  
//
//  Created by Илья Малахов on 02.12.2024.
//

import SwiftUI

public struct ChatSuggestions: View {
    
    let suggestions: [ChatSuggestionAction]
    
    public init(suggestions: [ChatSuggestionAction]) {
        self.suggestions = suggestions
    }
    
    public var body: some View {
        HStack(spacing: .zero) {
            Spacer(minLength: 12)
            suggestionLayout
        }
        .padding(.trailing, 12)
    }
    
    @ViewBuilder
    private var suggestionLayout: some View {
        FlowLayout(
            mode: .scrollable,
            rotated: true,
            items: suggestions,
            itemSpacing: 4
        ) {
            makeSuggestionItem($0)
        }
    }
    
    private func makeSuggestionItem(_ action: ChatSuggestionAction) -> some View {
        Text(action.title)
            .font(.subheadline)
            .foregroundStyle(.primary)
            .padding(.horizontal, 12.0)
            .padding(.vertical, 8.0)
            .overlay {
                RoundedRectangle(cornerRadius: 6.0)
                    .strokeBorder(
                        Color(.label),
                        lineWidth: 1
                    )
            }
            .simultaneousGesture(TapGesture().onEnded({
                action.onTap(action.title)
            }))
    }
}

#Preview {
    ChatSuggestions(suggestions: [
        .init(title: "Первый", onTap: { _ in }),
        .init(title: "Первый", onTap: { _ in }),
        .init(title: "Первый", onTap: { _ in }),
        .init(title: "Первый", onTap: { _ in }),
        .init(title: "Первый", onTap: { _ in })
    ])
}
