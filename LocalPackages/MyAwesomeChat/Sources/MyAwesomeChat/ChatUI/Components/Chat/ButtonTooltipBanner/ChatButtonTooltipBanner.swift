//
//  ChatButtonTooltipBanner.swift
//  
//
//  Created by Илья Малахов on 28.02.2025.
//

import SwiftUI

public struct ChatButtonTooltipBanner: View {
    
    @Binding private var filledStars: Int
    private let maxRatingCount: Int = 6
    
    public init(filledStars: Binding<Int>) {
        self._filledStars = filledStars
    }
    
    public var body: some View {
        HStack(spacing: .zero) {
            ForEach(1..<maxRatingCount, id: \.self) { i in
                Image(systemName: i <= filledStars ? "star.fill" : "star")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.orange)
                    .frame(maxWidth: .infinity, idealHeight: 40, maxHeight: 40, alignment: .center)
                    .onTapGesture {
                        filledStars = i
                    }
            }
        }
    }
}

#Preview {
    @Previewable @State var filledStars = 0
    ChatButtonTooltipBanner(filledStars: $filledStars)
}
