//
//  ChatDownButtonView.swift
//  
//
//  Created by Илья Малахов on 05.03.2025.
//

import SwiftUI

struct ChatDownButtonView: View {
    
    @Binding var newMessagesCount: Int
    @Binding var isHidden: Bool
    
    var body: some View {
        if !isHidden {
            HStack(spacing: .zero) {
                ChatDownButton(newMessagesCount: $newMessagesCount)
                    .padding(.bottom, 16)
                    .padding(.trailing, 24)
                    .frame(
                        minWidth: 0,
                        maxWidth: .infinity,
                        alignment: .trailing
                    )
            }
        }
    }
}
