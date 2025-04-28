//
//  ChatDownButtonScreen.swift
//  FAChatDemo
//
//  Created by Илья Малахов on 12.02.2025.
//

import SwiftUI
import FAChat

struct ChatDownButtonScreen: View {
    
    @State private var firstButton = 0
    @State private var secondButton = 1
    @State private var thirdButton = 999
    @State private var fourthButton = 10
    @State private var fifthButton = 9
    
    var body: some View {
        VStack(spacing: 10) {
            ChatDownButton(newMessagesCount: $firstButton)
            ChatDownButton(newMessagesCount: $secondButton)
            ChatDownButton(newMessagesCount: $thirdButton)
            ChatDownButton(newMessagesCount: $fourthButton)
            ChatDownButton(newMessagesCount: $fifthButton)
        }
    }
}
