//
//  ChatTextInputsView.swift
//  
//
//  Created by Илья Малахов on 30.10.2024.
//

import SwiftUI
import MRDSKit

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
                    .foregroundColor(color: MRBackgroundColor.colorBackground)
                    .shadow(
                        color: .init(MRShadowColor.dp16_1.color).opacity(0.08),
                        radius: 16,
                        x: 0,
                        y: 12
                    )
                    .shadow(
                        color: .init(MRShadowColor.dp16_0.color).opacity(0.16),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
                    .ignoresSafeArea(.all, edges: .bottom)
            }
            .padding(.top, 16.0)
    }
    
    private var staple: some View {
        ImageView(
            mrImage: Asset.Size24.UI.Staple.with(
                tintColor: MRTextColor.colorTextLink,
                andBackground: .fillColor(MRTextColor.colorTextLink)
            )
        )
            .frame(width: 24.0, height: 24.0)
            .padding(.vertical, 8.0)
    }
    
    private var textInput: some View {
        HStack(alignment: .bottom, spacing: .zero) {
            TextInputView(
                text: $text,
                textConfig: .init(style: .callout3),
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
                    .foregroundColor(color: MRBackgroundColor.colorOnBackgroundFirst)
                if text.isEmpty {
                    Text(placeholder)
                        .font(fontStyle: .callout3)
                        .foregroundColor(color: MRTextColor.colorTextCaption)
                        .padding(.leading, 10.0)
                }
            }
        )
    }
    
    private var sendMessage: some View {
        Circle()
            .overlay(
                ImageView(
                    mrImage: Asset.Size24.UI.ArrowUp.with(
                        tintColor: nil,
                        andBackground: .fillColor(MRBackgroundColor.colorBackground)
                    )
                )
            )
            .foregroundColor(color: MRTextColor.colorTextLink)
            .frame(width: 24.0, height: 24.0)
            .padding(.all, 8.0)
            .onTapGesture {
                onSendTap?()
            }
    }
}
