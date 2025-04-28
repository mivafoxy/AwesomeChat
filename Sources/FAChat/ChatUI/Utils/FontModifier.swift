//
//  FontWithLineHeight.swift
//  
//
//  Created by Илья Малахов on 13.10.2024.
//

import SwiftUI
import MRDSKit

struct FontModifier: ViewModifier {
    let fontStyle: MRFontStyle

    func body(content: Content) -> some View {
        content
            .font(.init(fontStyle.font))
            .frame(minHeight: fontStyle.lineHeight)
            .lineSpacing(
                fontStyle.lineHeight - fontStyle.font.lineHeight
            )
    }
}

public extension Text {
    func font(fontStyle: MRFontStyle) -> some View {
        ModifiedContent(
            content: self
                .tracking(fontStyle.letterSpacing)
                .baselineOffset(fontStyle.baselineOffset),
            modifier: FontModifier(fontStyle: fontStyle)
        )
    }
}
