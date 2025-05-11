//
//  ChatScreen.swift
//  
//
//  Created by Илья Малахов on 21.11.2024.
//

import SwiftUI
import Combine
import UIKit

struct ChatScreen: View {
    
    @ObservedObject var viewModel: ChatViewModel
    @State private var keyboardHeight: CGFloat = 0
    
    var body: some View {
        VStack(spacing: .zero) {
            headerView
            makeChatScreen()
        }
        .background(Color.accentColor)
        .onAppear {
            viewModel.send(.onAppear)
        }
        .onDisappear {
            viewModel.send(.onDisappear)
        }
        .bottomSheet(
            isHidden: $viewModel.isBottomSheetHidden,
            content: { ChatBottomSheetView(viewModel: viewModel) }
        )
    }
    
    private var headerView: some View {
        Text("chat_title".localized)
            .font(.subheadline)
            .padding(.vertical, 10)
            .frame(alignment: .center)
            .background {
                Rectangle().fill(Color.blue)
            }
    }
    
    @ViewBuilder
    private func makeChatScreen() -> some View {
        switch viewModel.state {
        case .loading:
            ChatLoaderScreen()
        case .content:
            contentScreen
        case .error:
            IndicatorEmptyState(
                title: "chat_error".localized,
                buttonText: "chat_update".localized,
                buttonAction: { viewModel.send(.onRetry) }
            )
        }
    }
}

// MARK: - View components

extension ChatScreen {
    
    @ViewBuilder fileprivate var contentScreen: some View {
        VStack(spacing: .zero) {
            ZStack(alignment: .bottomTrailing) {
                ChatListView(viewModel: viewModel).zIndex(0)
                downButton.zIndex(1)
            }
            quote.offset(y: 16)
            textInput
        }
        
    }
    
    @ViewBuilder private var downButton: some View {
        ChatDownButtonView(
            newMessagesCount: $viewModel.unreadCount,
            isHidden: $viewModel.isDownButtonHidden
        )
        .onTapGesture { }
        .highPriorityGesture(
            LongPressGesture(minimumDuration: 0.01)
                .sequenced(before: DragGesture(coordinateSpace: .global))
                .onChanged() { _ in
                    viewModel.send(.onDownButtonTap)
                })
    }
    
    @ViewBuilder private var quote: some View {
        ChatQuoteView(quoted: $viewModel.quoted) {
            viewModel.send(.onQuoteCloseTap)
        }
    }

    private var textInput: some View {
        ChatTextInputs(
            text: $viewModel.currentUserText,
            placeholder: "chat_write_message".localized
        ) {
            viewModel.send(.onMessageSend)
        }
        .onReceive(Publishers.keyboardHeight) { height in
            withAnimation(.easeOut(duration: 0.25)) {
                self.keyboardHeight = height
            }
        }
    }
}

extension Publishers {
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        let willShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .map { ($0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0 }

        let willHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }

        return MergeMany(willShow, willHide)
            .eraseToAnyPublisher()
    }
}

