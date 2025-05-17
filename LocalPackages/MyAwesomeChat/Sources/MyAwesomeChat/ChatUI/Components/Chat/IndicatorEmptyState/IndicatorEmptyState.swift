//
//  IndicatorEmptyState.swift
//  
//
//  Created by Илья Малахов on 06.02.2025.
//

import SwiftUI

struct IndicatorEmptyState: View {
    
    let title: String
    let buttonText: String
    let buttonAction: () -> Void
    
    var body: some View {
        VStack(alignment: .center, spacing: .zero) {
            Spacer()
                .frame(maxHeight: 104.0)
            Text("🤷‍♂️")
                .font(.largeTitle)
                .foregroundStyle(.primary)
                .frame(alignment: .center)
            Spacer()
                .frame(maxHeight: 48.0)
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
            Spacer()
            Button(action: buttonAction, label: {
                RoundedRectangle(cornerRadius: 12.0)
                    .foregroundStyle(.orange)
                    .overlay {
                        Text(buttonText)
                            .font(.body)
                            .foregroundStyle(.black)
                    }
            })
                .frame(height: 52.0, alignment: .center)
                .padding(.leading, 24.0)
                .padding(.trailing, 24.0)
                .padding(.bottom, 24.0)
        }
    }
}

#Preview {
    IndicatorEmptyState(title: "Извините, что то пошло не так", buttonText: "Попробовать снова", buttonAction: { })
}
