//
//  ChatTextInputsView.swift
//  
//
//  Created by Илья Малахов on 30.10.2024.
//

import SwiftUI

public struct ChatTextInputs: View {
    
    @Binding
    public private(set) var text: String
    
    public let placeholder: String
    public let onSendTap: (() -> Void)?
    
    private let minTextViewHeight = 24.0
    private let maxTextViewHeight = 184.0
    
    public init(text: Binding<String>, placeholder: String = "", onSendTap: (() -> Void)? = nil) {
        self._text = text
        self.placeholder = placeholder
        self.onSendTap = onSendTap
    }
    
    public var body: some View {
        textInput
            .padding(.all, 8.0)
            .background {
                Rectangle()
                    .foregroundStyle(.background)
                    .shadow(
                        color: .init(.black).opacity(0.08),
                        radius: 16,
                        x: 0,
                        y: 12
                    )
                    .shadow(
                        color: .init(.black).opacity(0.16),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
                    .ignoresSafeArea(.all, edges: .bottom)
            }
            .padding(.top, 16.0)
    }
    
    private var staple: some View {
        Image(systemName: "paperclip")
            .frame(width: 24.0, height: 24.0)
            .padding(.vertical, 8.0)
    }
    
    private var textInput: some View {
        HStack(alignment: .bottom, spacing: .zero) {
            TextInputView(
                text: $text,
                maxHeight: maxTextViewHeight
            )
                .frame(minHeight: minTextViewHeight, maxHeight: maxTextViewHeight)
                .fixedSize(horizontal: false, vertical: true)
            if !text.isEmpty {
                sendMessage
            }
        }
        .background(
            ZStack(alignment: Alignment(horizontal: .leading, vertical: .center)) {
                RoundedRectangle(cornerRadius: 12.0)
                    .foregroundStyle(.background)
                if text.isEmpty {
                    Text(placeholder)
                        .font(.callout)
                        .foregroundStyle(.black)
                        .padding(.leading, 10.0)
                }
            }
        )
    }
    
    private var sendMessage: some View {
        Circle()
            .overlay(
                Image(systemName: "arrow.up.message")
            )
            .foregroundStyle(.link)
            .frame(width: 24.0, height: 24.0)
            .padding(.all, 8.0)
            .onTapGesture {
                onSendTap?()
            }
    }
}
