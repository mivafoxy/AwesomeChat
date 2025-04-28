//
//  ContentView.swift
//  FAChatDemo
//
//  Created by Илья Малахов on 10.10.2024.
//

import SwiftUI
import FAChat

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(
                    "Chat Bubble",
                    destination: ChatBubbleScreen()
                )
                NavigationLink(
                    "Chat Text Inputs",
                    destination: ChatTextInputsScreen()
                )
                NavigationLink(
                    "Chat Date",
                    destination: ChatDateScreen()
                )
                NavigationLink(
                    "Chat Dialog Status",
                    destination: ChatDialogScreen()
                )
                NavigationLink(
                    "Chat Quote",
                    destination: ChatQuoteScreen()
                )
                NavigationLink(
                    "Chat Suggestions",
                    destination: ChatSuggestionsScreen()
                )
                NavigationLink(
                    "Chat Down Button",
                    destination: ChatDownButtonScreen()
                )
                NavigationLink(
                    "Chat Bottom Sheet",
                    destination: ChatBottomSheetScreen()
                )
                NavigationLink(
                    "Chat Banner Tooltip Banner",
                    destination: ChatButtonTooltipBannerScreen()
                )
                NavigationLink(
                    "Chat Typing",
                    destination: ChatTypingScreen()
                )
            }
            .navigationBarHidden(true)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
