//
//  ChatDownButton.swift
//  
//
//  Created by Илья Малахов on 12.02.2025.
//

import SwiftUI

public struct ChatDownButton: View {
    
    @Binding var newMessagesCount: Int
    
    public init(newMessagesCount: Binding<Int>) {
        self._newMessagesCount = newMessagesCount
    }
    
    public var body: some View {
        Circle()
            .frame(width: 32, height: 32)
            .foregroundStyle(.fill)
        .overlay {
            VStack(spacing: .zero) {
                Spacer().frame(height: 6)
                Image(systemName: "arrow.down")
                    .resizable()
                    .frame(
                        width: 16,
                        height: 16,
                        alignment: .center
                    )
                    .foregroundStyle(.secondary)
            }
        }
        .overlay {
            VStack(spacing: .zero) {
                messageCounter
                Spacer().frame(height: 28)
            }
        }
    }
    
    @ViewBuilder
    private var messageCounter: some View {
        if newMessagesCount > 0 {
            counterShape
                .foregroundStyle(.red)
                .overlay {
                    Text("\(newMessagesCount < 100 ? newMessagesCount : 99)")
                        .font(.caption)
                        .foregroundStyle(.background)
                        .frame(width: 16, height: 16, alignment: .center)
                }
        }
    }
    
    @ViewBuilder
    private var counterShape: some View {
        if newMessagesCount < 10 {
            Circle()
                .frame(
                    width: 20,
                    height: 20,
                    alignment: .center
                )
        } else {
            RoundedRectangle(cornerRadius: 100)
                .frame(
                    width: 28,
                    height: 20,
                    alignment: .center
                )
        }
    }
}

#Preview {
    @Previewable @State var count = 1
    ChatDownButton(newMessagesCount: $count)
}
