//
//  ChatRightBubbleV2Screen.swift
//  FAChatDemo
//
//  Created by Илья Малахов on 14.02.2025.
//

import SwiftUI
import FAChat
import MRDSKit

struct ChatRightBubbleScreen: View {
    
    @MRBuilder<ChatRightMessage>
    private var messages: [ChatRightMessage] {
        ChatRightMessage(
            text: "Добрый день",
            statusSubtitle: "11:45",
            statusIcon: Asset.Size16.Service.SmallStatusRead,
            contextActions: [
                ChatContextAction(title: "Копировать", icon: nil, action: { (text, _) in print(text) })
            ]
        )
        ChatRightMessage(
            text: "Катюша, подскажи, пожалуйста, как мне сохранить выписку?",
            statusSubtitle: "11:45",
            statusIcon: Asset.Size16.Service.SmallStatusSend
        )
        ChatRightMessage(
            text: "У меня поменялся паспорт",
            statusSubtitle: "11:45",
            statusIcon: Asset.Size16.Service.SmallStatusUnread
        )
        ChatRightMessage(
            text: "А как сохранить выписку в формате txt?",
            statusSubtitle: "11:45",
            statusIcon: Asset.Size16.Service.SmallStatusSent
        )
        ChatRightMessage(
            text: "Можно оператора?",
            statusSubtitle: "11:45",
            statusIcon: Asset.Size16.Service.SmallStatusRead
        )
        ChatRightMessage(
            text: "Катюша, подскажи, пожалуйста, как мне сохранить выписку?",
            statusSubtitle: "Не доставлено"
        )
        ChatRightMessage(
            text: "Катюша, подскажи, пожалуйста, как мне сохранить выписку?",
            statusSubtitle: "11:45",
            statusIcon: Asset.Size16.Service.SmallStatusRead
        )
        ChatRightMessage(
            text: "Катюша, подскажи, пожалуйста, как мне сохранить выписку?",
            statusSubtitle: "Не доставлено"
        )
        ChatRightMessage(
            text: "Добрый день",
            statusSubtitle: "11:45",
            statusIcon: Asset.Size16.Service.SmallStatusRead
        )
        ChatRightMessage(
            text: "Катюша, подскажи, пожалуйста, как мне сохранить выписку?",
            statusSubtitle: "11:45",
            statusIcon: Asset.Size16.Service.SmallStatusSend
        )
        ChatRightMessage(
            text: "У меня поменялся паспорт",
            statusSubtitle: "11:45",
            statusIcon: Asset.Size16.Service.SmallStatusUnread
        )
        ChatRightMessage(
            text: "А как сохранить выписку в формате txt?",
            statusSubtitle: "11:45",
            statusIcon: Asset.Size16.Service.SmallStatusSent
        )
        ChatRightMessage(
            text: "Можно оператора?",
            statusSubtitle: "11:45",
            statusIcon: Asset.Size16.Service.SmallStatusRead
        )
        ChatRightMessage(
            text: "Катюша, подскажи, пожалуйста, как мне сохранить выписку?",
            statusSubtitle: "Не доставлено"
        )
        ChatRightMessage(
            text: "Катюша, подскажи, пожалуйста, как мне сохранить выписку?",
            statusSubtitle: "11:45",
            statusIcon: Asset.Size16.Service.SmallStatusRead
        )
        ChatRightMessage(
            text: "Катюша, подскажи, пожалуйста, как мне сохранить выписку?",
            statusSubtitle: "Не доставлено"
        )
        ChatRightMessage(
            text: "Катюша, подскажи, пожалуйста, как мне сохранить выписку?",
            statusSubtitle: "Не доставлено",
            quote: ChatBubbleQuote(
                title: "Ассистент Катюша",
                content: "Приветствую! Я — Катюша, бизнес-ассистент ПСБ."
            )
        )
        ChatRightMessage(
            text: "Катюша, подскажи, пожалуйста, как мне сохранить выписку?",
            statusSubtitle: "Не доставлено",
            quote: ChatBubbleQuote(
                title: "Ассистент Катюша",
                content: "Приветствую! Я — Катюша, бизнес-ассистент ПСБ.",
                image: UIImage(named: "quote")
            )
        )
        ChatRightMessage(
            text: "Катюша, подскажи, пожалуйста, как мне сохранить выписку?",
            statusSubtitle: "Не доставлено",
            quote: ChatBubbleQuote(
                title: "Ассистент Катюша",
                content: "Приветствую! Я — Катюша, бизнес-ассистент ПСБ.",
                fileImage: Asset.Size32.FileUploader.FileUploaderPdf
            )
        )
    }
    
    var body: some View {
        List {
            ForEach(
                Array(messages.enumerated()),
                id: \.element.id
            ) { offset, message in
                ChatBubbleRight(
                    message: message,
                    cornerRadiusSet: RadiusSet(
                        topLeftRadius: 12.0,
                        topRightRadius: offset == 0 ? 12.0 : 4.0,
                        bottomLeftRadius: 12.0,
                        bottomRightRadius: 4.0
                    )
                )
            }
            .listRowSeparator(.hidden)
            .listRowInsets(.zero)
        }
        .listStyle(.plain)
    }
}
