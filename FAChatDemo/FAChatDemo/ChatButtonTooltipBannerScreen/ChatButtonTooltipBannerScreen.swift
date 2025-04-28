//
//  ChatBannerTooltipBanner.swift
//  FAChatDemo
//
//  Created by Илья Малахов on 28.02.2025.
//

import SwiftUI
import FAChat

struct ChatButtonTooltipBannerScreen: View {
    
    @State private var filledStars = 0
    
    var body: some View {
        ChatButtonTooltipBanner(filledStars: $filledStars)
            .padding(
                EdgeInsets(
                    top: 10.0,
                    leading: 24.0,
                    bottom: 20.0,
                    trailing: 24.0)
            )
    }
}
