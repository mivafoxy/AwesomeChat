//
//  ChatQuoteScreen.swift
//  FAChatDemo
//
//  Created by Илья Малахов on 05.11.2024.
//

import SwiftUI
import MRDSKit
import FAChat

struct ChatQuoteScreen: View {
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ChatQuote(
                    title: "Ассистент Катюша",
                    content: "Приветствую! Я – КатюшаБ бизнес-ассистент ПСБ Приветствую! Я – КатюшаБ бизнес-ассистент ПСБ"
                )
                ChatQuote(
                    title: "Ассистент Катюша",
                    content: "Приветствую! Я – КатюшаБ бизнес-ассистент ПСБ Приветствую! Я – КатюшаБ бизнес-ассистент ПСБ",
                    image: UIImage(named: "quote")
                )
                ChatQuote(
                    title: "Ассистент Катюша",
                    content: "Приветствую! Я – КатюшаБ бизнес-ассистент ПСБ Приветствую! Я – КатюшаБ бизнес-ассистент ПСБ",
                    fileImage: Asset.Size32.FileUploader.FileUploaderPdf
                )
            }
        }
    }
}
