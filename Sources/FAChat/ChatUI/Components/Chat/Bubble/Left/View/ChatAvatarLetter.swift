//
//  ChatAvatarLetter.swift
//  
//
//  Created by Илья Малахов on 22.10.2024.
//

import SwiftUI

struct ChatAvatarLetter: View {
    
    let userName: String
    
    var body: some View {
        Circle()
            .frame(
                width: 20.0,
                height: 20.0
            )
            .foregroundStyle(.blue)
            .overlay {
                Text(userName.prefix(1))
                    .font(.subheadline)
                    .foregroundStyle(.background)
            }
    }
}

#Preview {
    ChatAvatarLetter(userName: "Lol")
}
