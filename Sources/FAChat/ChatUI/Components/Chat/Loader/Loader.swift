//
//  Loader.swift
//  
//
//  Created by Илья Малахов on 13.01.2025.
//

import SwiftUI
import MRDSKit

public struct Loader: View {
    
    @State private var isAnimating = false
    
    public var body: some View {
        Circle()
            .trim(from: 0.5, to: 1)
            .stroke(
                Color(MRElementsColor.colorPrimary.color),
                style: StrokeStyle(lineWidth: 4, lineCap: .round)
            )
            .frame(width: 28, height: 28)
            .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
            .animation(
                Animation
                    .linear(duration: 1)
                    .repeatForever(autoreverses: false),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
            .background {
                Circle()
                    .stroke(
                        Color(MRElementsColor.colorElementsThird.color),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
            }
    }
}
