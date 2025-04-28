//
//  ChatBubbleLeftV2Screen.swift
//  FAChatDemo
//
//  Created by Илья Малахов on 14.02.2025.
//

import SwiftUI
import FAChat
import MRDSKit

struct ChatBubbleLeftScreen: View {
    
    @MRBuilder<ChatLeftMessage>
    private var operatorMessages: [ChatLeftMessage] {
        ChatLeftMessage(
            text: "Привет!",
            statusSubtitle: "11:00",
            contextActions: [
                ChatContextAction(title: "Копировать", icon: UIImage(systemName: "arrowshape.turn.up.backward"), action: { (text, image) in print(text) })
            ]
        )
        ChatLeftMessage(
            text:
                """
                Приветствую! Я — Катюша,
                бизнес-ассистент ПСБ!
                """,
            statusSubtitle: "11:00"
        )
        ChatLeftMessage(
            text:
                """
                Приветствую! Я — Катюша,
                бизнес-ассистент ПСБ!
                """,
            statusSubtitle: "11:00"
        )
        ChatLeftMessage(
            text:
                """
                Приветствую! Я — Катюша,
                бизнес-ассистент ПСБ!
                """,
            statusSubtitle: "11:00"
        )
        ChatLeftMessage(
            text:
                """
                Приветствую! Я — Катюша,
                бизнес-ассистент ПСБ!
                """,
            statusSubtitle: "11:00"
        )
        ChatLeftMessage(
            text:
                """
                Приветствую! Я — Катюша,
                бизнес-ассистент ПСБ!
                Приветствую! Я — Катюша, бизнес-ассистент ПСБ!
                Приветствую! Я — Катюша, бизнес-ассистент ПСБ!
                Приветствую! Я — Катюша,
                бизнес-ассистент ПСБ!
                Приветствую! Я — Катюша,
                бизнес-ассистент ПСБ!
                Приветствую! Я — Катюша,
                бизнес-ассистент ПСБ!
                """,
            statusSubtitle: "11:00"
        )
        ChatLeftMessage(
            text: "Приветствую! Я — Катюша, бизнес-ассистент ПСБ.",
            statusSubtitle: "11:00",
            quote: ChatBubbleQuote(
                title: "Ассистент Катюша",
                content: "Приветствую! Я – Катюша, бизнес-асси..."
            )
        )
        ChatLeftMessage(
            text: "Привет!",
            statusSubtitle: "11:00",
            quote: ChatBubbleQuote(
                title: "Ассистент Катюша",
                content: "Приветствую! Я — Катюша, бизнес-ассистент ПСБ."
            )
        )
        ChatLeftMessage(
            text: "Привет!",
            statusSubtitle: "11:00",
            quote: ChatBubbleQuote(
                title: "Ассистент Катюша",
                content: "Приветствую! Я — Катюша, бизнес-ассистент ПСБ.",
                image: UIImage(named: "quote")
            )
        )
        ChatLeftMessage(
            text: "Привет!",
            statusSubtitle: "11:00",
            quote: ChatBubbleQuote(
                title: "Ассистент Катюша",
                content: "Приветствую! Я – Катюша, бизнес-асси...",
                fileImage: Asset.Size32.FileUploader.FileUploaderPdf
            )
        )
    }
    
    @MRBuilder<ChatLeftMessage>
    private var katMessages: [ChatLeftMessage] {
        ChatLeftMessage(
            text: "Привет!",
            statusSubtitle: "11:00"
        )
        ChatLeftMessage(
            text:
                """
                Приветствую! Я — Катюша,
                бизнес-ассистент ПСБ!
                """,
            statusSubtitle: "11:00"
        )
        ChatLeftMessage(
            text:
                """
                Приветствую! Я — Катюша,
                бизнес-ассистент ПСБ!
                """,
            statusSubtitle: "11:00"
        )
        ChatLeftMessage(
            text:
                """
                Приветствую! Я — Катюша,
                бизнес-ассистент ПСБ!
                """,
            statusSubtitle: "11:00"
        )
        ChatLeftMessage(
            text:
                """
                Приветствую! Я — Катюша,
                бизнес-ассистент ПСБ!
                """,
            statusSubtitle: "11:00"
        )
        ChatLeftMessage(
            text:
                """
                Приветствую! Я — Катюша,
                бизнес-ассистент ПСБ!
                Приветствую! Я — Катюша, бизнес-ассистент ПСБ!
                Приветствую! Я — Катюша, бизнес-ассистент ПСБ!
                Приветствую! Я — Катюша,
                бизнес-ассистент ПСБ!
                Приветствую! Я — Катюша,
                бизнес-ассистент ПСБ!
                Приветствую! Я — Катюша,
                бизнес-ассистент ПСБ!
                """,
            statusSubtitle: "11:00"
        )
    }
    
    var body: some View {
        List {
            ForEach(
                Array(operatorMessages.enumerated()),
                id: \.element.id
            ) { offset, operatorMessage in
                ChatBubbleLeft(
                    title: offset == 0 ? "Антон" : nil,
                    userName: offset == operatorMessages.count - 1 ? "Антон" : nil,
                    message: operatorMessage,
                    avatar: nil,
                    cornerRadiusSet: RadiusSet(
                        topLeftRadius: offset == 0 ? 12.0 : 4.0,
                        topRightRadius: 12.0,
                        bottomLeftRadius: 4.0,
                        bottomRightRadius: 12.0
                    )
                )
            }
            .listRowSeparator(.hidden)
            .listRowInsets(.zero)
            ForEach(
                Array(katMessages.enumerated()),
                id: \.element.id
            ) { offset, operatorMessage in
                ChatBubbleLeft(
                    title: offset == 0 ? "Ассистент Катюша" : nil,
                    userName: offset == katMessages.count - 1 ? "Ассистент Катюша" : nil,
                    message: operatorMessage,
                    avatar: offset == katMessages.count - 1 ? Image("avatar") : nil,
                    cornerRadiusSet: RadiusSet(
                        topLeftRadius: offset == 0 ? 12.0 : 4.0,
                        topRightRadius: 12.0,
                        bottomLeftRadius: 4.0,
                        bottomRightRadius: 12.0
                    )
                )
            }
            .listRowSeparator(.hidden)
            .listRowInsets(.zero)
        }
        .listStyle(.plain)
    }
}
