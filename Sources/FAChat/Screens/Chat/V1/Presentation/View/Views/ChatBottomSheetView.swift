//
//  ChatBottomSheetView.swift
//  
//
//  Created by Илья Малахов on 03.03.2025.
//

import SwiftUI

struct ChatBottomSheetView: View {
    
    @ObservedObject var viewModel: ChatViewModel
    @State private var filledStars: Int = 0
    
    var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .top, spacing: .zero) {
                Text("chat_dialog_finish".localized)
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(EdgeInsets(top: 12, leading: 24, bottom: 16, trailing: 0))
                
                Image(systemName: "xmark.circle")
                    .resizable()
                    .foregroundStyle(.primary)
                    .frame(width: 16, height: 16, alignment: .center)
                    .padding(EdgeInsets(top: 6.0, leading: 17, bottom: 0.0, trailing: 20.0))
                    .onTapGesture {
                        viewModel.send(.onCloseTap)
                    }
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
            .padding(.top, 10)
            
            ChatButtonTooltipBanner(filledStars: $filledStars)
                .padding(EdgeInsets(top: 0.0, leading: 24.0, bottom: 20.0, trailing: 24.0))
                .onChange(of: filledStars) { newValue in
                    viewModel.send(.onSendOperatorScore(newValue))
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
            
            HStack(alignment: .center) {
                ForEach(
                    [
                        "chat_score_bad".localized,
                        "chat_score_good".localized,
                        "chat_score_excelent".localized
                    ],
                    id: \.self
                ) { label in
                    Text(label)
                        .font(.caption)
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
}
