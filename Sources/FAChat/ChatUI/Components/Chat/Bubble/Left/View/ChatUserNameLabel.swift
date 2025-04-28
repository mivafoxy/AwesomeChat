//
//  ChatUserNameLabel.swift
//  
//
//  Created by Илья Малахов on 13.10.2024.
//

import SwiftUI
import MRDSKit

struct ChatUserNameLabel: View {
    
    let userName: String
    
    var body: some View {
        Text(userName)
            .font(fontStyle: .caption1)
            .foregroundColor(color: MRTextColor.colorTextCaption)
    }
}

struct ChatUserNameLabel_Previews: PreviewProvider {
    static var previews: some View {
        ChatUserNameLabel(userName: "Ассистент Катюша")
    }
}
