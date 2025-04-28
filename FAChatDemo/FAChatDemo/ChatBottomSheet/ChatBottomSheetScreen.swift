//
//  ChatBottomSheetScreen.swift
//  FAChatDemo
//
//  Created by Илья Малахов on 27.02.2025.
//

import SwiftUI
import MRDSKit
import FAChat

struct ChatBottomSheetScreen: View {
    
    @State private var isBottomSheetHidden = true
    @State private var filledStars: Int = 0
    
    var body: some View {
        Button(
            "Show sheet",
            action: {
                isBottomSheetHidden.toggle()
            }
        )
        .bottomSheet(
            isHidden: $isBottomSheetHidden,
            content: {
                VStack(spacing: 10) {
                    HStack(alignment: .top, spacing: .zero) {
                        Text("Диалог завершён.\nОцените качество обслуживания")
                            .font(fontStyle: .body1)
                            .multilineTextAlignment(.leading)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(EdgeInsets(top: 12, leading: 24, bottom: 16, trailing: 17))
                        
                        Image(uiImage: Asset.Size16.UI.SmallClose2.imageValue)
                            .resizable()
                            .foregroundColor(color: MRButtonsColor.colorButtonNoticeTextNormal)
                            .frame(width: 16, height: 16, alignment: .center)
                            .padding(EdgeInsets(top: 6.0, leading: 0, bottom: 0.0, trailing: 20.0))
                            .onTapGesture {
                                isBottomSheetHidden = true
                            }
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                    .padding(.top, 10)
                    
                    ChatButtonTooltipBanner(filledStars: $filledStars)
                        .padding(EdgeInsets(top: 0.0, leading: 24.0, bottom: 20.0, trailing: 24.0))
                    
                    HStack(alignment: .center) {
                        ForEach(["Плохо", "Хорошо", "Отлично"], id: \.self) { label in
                            Text(label)
                                .font(fontStyle: .caption1)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    alignment: .leading
                )
            }
        )
    }
}
