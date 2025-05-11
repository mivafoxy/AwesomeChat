//
//  ChatButtonTooltipBanner.swift
//  
//
//  Created by Илья Малахов on 28.02.2025.
//

import SwiftUI

public struct ChatButtonTooltipBanner: View {
    
    @Binding private var filledStars: Int
    private let maxRatingCount: Int = 5
    
    public init(filledStars: Binding<Int>) {
        self._filledStars = filledStars
    }
    
    public var body: some View {
        HStack(spacing: .zero) {
            ForEach(1..<(maxRatingCount + 1)) { i in
                Image(
                    uiImage: i <= filledStars ?
                    Image(systemName: "star").getUIImage(newSize: CGSize(width: 40, height: 40)) :
                    Image(systemName: "star.fill").getUIImage(newSize: CGSize(width: 40, height: 40))
                )
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
