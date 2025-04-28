//
//  View+Extension.swift
//  
//
//  Created by Илья Малахов on 13.10.2024.
//

import SwiftUI
import MRDSKit

public extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(
            RoundedCorner(
                radius: radius,
                corners: corners
            )
        )
    }
    
    func foregroundColor(color: IMRColor) -> some View {
        self.foregroundColor(.init(color.color))
    }
    
    @ViewBuilder func foregroundStyle(background: MRBackgroundType?) -> some View {
        switch background {
        case let .fillColor(color):
            foregroundColor(color: color)
        case let .gradient(gradient, _):
            let colors = [
                Color(gradient.startColor),
                Color(gradient.endColor)
            ]
            let startPoint = UnitPoint(
                x: gradient.startPoint?.x ?? 0.0,
                y: gradient.startPoint?.y ?? 0.5
            )
            let endPoint = UnitPoint(
                x: gradient.endPoint?.x ?? 1.0,
                y: gradient.endPoint?.y ?? 0.5
            )
            foregroundStyle(
                .linearGradient(
                    colors: colors,
                    startPoint: startPoint,
                    endPoint: endPoint
                )
            )
        case .none:
            self
        }
    }
    
    func endEditing() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}
