//
//  ChatLoaderScreen.swift
//  
//
//  Created by Илья Малахов on 24.04.2025.
//

import SwiftUI

struct ChatLoaderScreen: View {
    var body: some View {
        VStack(spacing: .zero) {
            Loader()
                .frame(
                    minHeight: 0,
                    maxHeight: .infinity,
                    alignment: .center
                )
        }
    }
}
