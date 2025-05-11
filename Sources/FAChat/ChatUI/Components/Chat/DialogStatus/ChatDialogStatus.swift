//
//  ChatDialogStatus.swift
//  
//
//  Created by Илья Малахов on 05.11.2024.
//

import SwiftUI

public struct ChatDialogStatus: View {
    
    public let text: String
    
    public init(text: String) {
        self.text = text
    }
    
    public var body: some View {
        HStack(alignment: .center) {
            Text(text)
                .font(.caption)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 48.0)
                .padding(.vertical, 12.0)
        }
    }
}

#Preview {
    ChatDialogStatus(text: "Оператор подключился к диалогу")
}
