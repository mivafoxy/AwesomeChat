//
//  TextView.swift
//  
//
//  Created by Илья Малахов on 30.10.2024.
//

import Foundation
import SwiftUI
import UIKit

struct TextInputView: UIViewRepresentable {
    
    @Binding var text: String
    var placeholder: String = ""
    var maxHeight: CGFloat
        
    public func makeUIView(context: Context) -> UITextView {
        let textView = ResizableTextView()
        textView.delegate = context.coordinator
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        textView.allowsEditingTextAttributes = true
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .sentences
        textView.maxHeight = maxHeight
        textView.textContainerInset = .init(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
        textView.font = .systemFont(ofSize: 16.0)
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        let newValue = text
        uiView.text = newValue
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

final class Coordinator: NSObject, UITextViewDelegate {
    
    var parent: TextInputView
    
    init(_ uiTextView: TextInputView) {
        self.parent = uiTextView
    }
    
    func textViewDidChange(_ uiView: UITextView) {
        self.parent.text = uiView.text
    }
}
