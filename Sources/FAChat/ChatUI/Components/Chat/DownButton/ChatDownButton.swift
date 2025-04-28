//
//  ChatDownButton.swift
//  
//
//  Created by Илья Малахов on 12.02.2025.
//

import SwiftUI
import MRDSKit

public struct ChatDownButton: View {
    
    @Binding var newMessagesCount: Int
    
    public init(newMessagesCount: Binding<Int>) {
        self._newMessagesCount = newMessagesCount
    }
    
    public var body: some View {
        Circle()
            .frame(width: 32, height: 32)
            .foregroundColor(
                color: MRBackgroundColor.colorOnBackgroundThird
            )
        .overlay {
            VStack(spacing: .zero) {
                Spacer().frame(height: 6)
                ImageView(mrImage: Asset.Size24.Service.ServiceArrowNormal)
                    .frame(
                        width: 24,
                        height: 24,
                        alignment: .center
                    )
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
                .foregroundColor(
                    color: MRStatusColor.colorStatusCriticalError
                )
                .overlay {
                    Text("\(newMessagesCount < 100 ? newMessagesCount : 99)")
                        .font(fontStyle: .caption1)
                        .foregroundColor(
                            color: MRBackgroundColor.colorBackground
                        )
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
