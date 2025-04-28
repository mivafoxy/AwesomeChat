//
//  IndicatorEmptyState.swift
//  
//
//  Created by Илья Малахов on 06.02.2025.
//

import SwiftUI
import MRDSKit

struct IndicatorEmptyState: View {
    
    let title: String
    let buttonText: String
    let buttonAction: () -> Void
    
    var body: some View {
        VStack(alignment: .center, spacing: .zero) {
            Spacer()
                .frame(maxHeight: 104.0)
            Text("🤷‍♂️")
                .font(fontStyle: .largeTitle1)
                .foregroundColor(color: MRTextColor.colorTextPrimary)
                .frame(alignment: .center)
            Spacer()
                .frame(maxHeight: 48.0)
            Text(title)
                .font(fontStyle: .subheadline3)
                .foregroundColor(color: MRTextColor.colorTextPrimary)
                .multilineTextAlignment(.center)
            Spacer()
            Button(action: buttonAction, label: {
                RoundedRectangle(cornerRadius: 12.0)
                    .foregroundColor(
                        color: MRButtonsColor.colorButtonPrimarySecondNormal.color
                    )
                    .overlay {
                        Text(buttonText)
                            .font(fontStyle: .body2)
                            .foregroundColor(color: MRElementsColor.colorOnPrimary)
                    }
            })
                .frame(height: 52.0, alignment: .center)
                .padding(.leading, 24.0)
                .padding(.trailing, 24.0)
                .padding(.bottom, 24.0)
        }
    }
}
