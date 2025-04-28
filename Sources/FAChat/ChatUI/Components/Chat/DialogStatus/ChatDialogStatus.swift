//
//  ChatDialogStatus.swift
//  
//
//  Created by Илья Малахов on 05.11.2024.
//

import SwiftUI
import MRDSKit

public struct ChatDialogStatus: View {
    
    public let text: String
    
    public init(text: String) {
        self.text = text
    }
    
    public var body: some View {
        HStack(alignment: .center) {
            Text(text)
                .font(fontStyle: .caption1)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundColor(color: MRTextColor.colorTextCaption)
                .padding(.horizontal, 48.0)
                .padding(.vertical, 12.0)
        }
    }
}
