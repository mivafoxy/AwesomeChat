//
//  ChatButtonTooltipBanner.swift
//  
//
//  Created by Илья Малахов on 28.02.2025.
//

import SwiftUI
import MRDSKit

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
                    Asset.Size40.Rating.StarFill.imageValue :
                    Asset.Size40.Rating.StarOutline.imageValue
                )
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(color: MRButtonsColor.colorButtonPrimarySecondNormal)
                    .frame(maxWidth: .infinity, idealHeight: 40, maxHeight: 40, alignment: .center)
                    .onTapGesture {
                        filledStars = i
                    }
            }
        }
    }
}
