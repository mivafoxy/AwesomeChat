//
//  ChatDate.swift
//  
//
//  Created by Илья Малахов on 01.11.2024.
//

import SwiftUI
import MRDSKit

public struct ChatDate: View {
    
    public let text: String
    
    public init(text: String) {
        self.text = text
    }
    
    public var body: some View {
        HStack(alignment: .center) {
            Text(text)
                .font(fontStyle: .caption1)
                .foregroundColor(color: MRTextColor.colorTextCaption)
                .padding(.vertical, 8.0)
        }
    }
}
