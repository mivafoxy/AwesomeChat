//
//  ChatBubbleScreen.swift
//  FAChatDemo
//
//  Created by Илья Малахов on 23.10.2024.
//

import SwiftUI

struct ChatBubbleScreen: View {
    
    var body: some View {
        List {
            NavigationLink(
                "Chat Bubble Left Screen",
                destination: ChatBubbleLeftScreen()
            )
            NavigationLink(
                "Chat Bubble Right Screen",
                destination: ChatRightBubbleScreen()
            )
        }
    }
}
