//
//  ChatAvatarLetter.swift
//  
//
//  Created by Илья Малахов on 22.10.2024.
//

import SwiftUI
import MRDSKit

struct ChatAvatarLetter: View {
    
    let userName: String
    
    var body: some View {
        Circle()
            .frame(
                width: 20.0,
                height: 20.0
            )
            .foregroundColor(color: MRElementsColor.colorElementsSelect)
            .overlay {
                Text(userName.prefix(1))
                    .font(fontStyle: .subheadline3)
                    .foregroundColor(color: MRTextColor.colorTextLink)
            }
    }
}
