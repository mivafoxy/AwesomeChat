//
//  ChatQuoteView.swift
//  
//
//  Created by Илья Малахов on 05.03.2025.
//

import SwiftUI

struct ChatQuoteView: View {
    
    @Binding var quoted: ChatMessage?
    let onCloseTap: () -> Void
    
    var body: some View {
        if let quoted = quoted {
            let title: String = {
                switch quoted.message.author {
                case .currentUser, .systemMessage, .unknown:
                    return ""
                case let .remoteOperator(name):
                    return name
                }
            }()
            
            ChatQuote(
                title: title,
                content: quoted.message.text ?? "",
                image: nil,
                fileImage: nil,
                onCloseTap: onCloseTap
            )
        }
    }
}
