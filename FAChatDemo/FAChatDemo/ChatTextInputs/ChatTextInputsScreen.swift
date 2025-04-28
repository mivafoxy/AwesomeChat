//
//  ChatTextInputsScreen.swift
//  FAChatDemo
//
//  Created by Илья Малахов on 30.10.2024.
//

import SwiftUI
import FAChat
import MRDSKit

struct ChatTextInputsScreen: View {
    @State
    private var text = ""
    
    var body: some View {
        VStack(spacing: .zero) {
            Spacer()
            .onTapGesture {
                endEditing()
            }
            ChatTextInputs(
                text: $text,
                placeholder: "Введите сообщение"
            ) {
                print(text)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
    }
}
