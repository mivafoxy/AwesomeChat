//
//  ChatListScreen.swift
//  
//
//  Created by Илья Малахов on 24.04.2025.
//

import SwiftUI
import MRDSKit

struct ChatListView: View {
    
    @ObservedObject var viewModel: ChatViewModel
    @StateObject private var screenData = ScreenData()
    @State private var isContentOutOfListBounds = false
    private let coordinateSpace = "List"
    
    var body: some View {
        ZStack(alignment: .top) {
            refreshView
            chatContentView
                .simultaneousGesture(TapGesture().onEnded {
                    endEditing()
                })
                .offset(x: 0, y: viewModel.isRefreshing ? refreshControlHeight : .zero)
                .coordinateSpace(name: coordinateSpace)
                .animation(.easeIn, value: viewModel.isRefreshing)
        }
    }
    
    @ViewBuilder private var refreshView: some View {
        if screenData.isRefreshing || viewModel.isRefreshing {
            refreshControlView.onAppear {
                viewModel.send(.onRefresh)
            }
        }
    }
    
    private var refreshControlHeight: CGFloat {
        return 50.0
    }
    
    @ViewBuilder private var refreshControlView: some View {
        HStack(alignment: .center, spacing: .zero) {
            Loader().frame(
                minWidth: .zero,
                maxWidth: .infinity,
                alignment: .center
            )
        }
        .frame(height: refreshControlHeight, alignment: .center)
    }
    
    @ViewBuilder private var chatContentView: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                LazyVStack {
                    dateGroupViews
                        .foregroundColor(
                            color: MRBackgroundColor.colorBackground
                        )
                        .onChange(of: viewModel.isNeedScroll) { newValue in
                            Task {
                                await MainActor.run {
                                    withAnimation(.linear) {
                                        proxy.scrollTo(
                                            anchorId,
                                            anchor: .top
                                        )
                                    }
                                    viewModel.send(.onScrolling)
                                }
                            }
                        }
                        .id(anchorId)
                }
                .background {
                    smallContentGeometry
                }
            }
            .background {
                listFrameGeometry
            }
            .rotationEffect(.degrees(180))
        }
    }
    
    @ViewBuilder private var smallContentGeometry: some View {
        if !isContentOutOfListBounds {
            GeometryReader { proxy in
                Rectangle()
                    .fill(.clear)
                    .onChange(of: proxy.frame(in: .named(coordinateSpace)).minY) { _ in
                        detectOffset(proxy)
                    }
            }
        }
    }
    
    @ViewBuilder private var listFrameGeometry: some View {
        GeometryReader { proxy in
            Rectangle().fill(.clear)
                .onAppear {
                    guard !viewModel.isRefreshing else { return }
                    detectListFrame(proxy)
                }
                .onChange(of: proxy.frame(in: .global)) { _ in
                    guard !viewModel.isRefreshing else { return }
                    detectListFrame(proxy)
                }
        }
    }
    
    private var anchorId: String {
        "Bottom_Anchor"
    }
    
    @ViewBuilder private var dateGroupViews: some View {
        if viewModel.dateMessageGroups.isEmpty {
            Rectangle().fill(.clear).frame(height: 50)
        } else {
            ForEach(
                Array(viewModel.dateMessageGroups.enumerated()),
                id: \.element.id
            ) { offset, messageGroup in
                VStack {
                    makeChatDate(offset, messageGroup)
                    makeBubbles(dateMessageGroup: messageGroup)
                    makeActionsView(offset)
                    makeTypingView(offset)
                    makeBottomAnchor(offset)
                }
                .rotationEffect(.degrees(180))
                .id(messageGroup.id)
            }
            .animation(.linear(duration: 0.15), value: viewModel.dateMessageGroups)
        }
    }
    
    @ViewBuilder private func getChatDateGeometry(_ offset: Int) -> some View {
        if isContentOutOfListBounds && offset == viewModel.dateMessageGroups.count - 1 {
            let isLastOffset = offset == viewModel.dateMessageGroups.count - 1
            let hasGeometryBackground = isContentOutOfListBounds && isLastOffset
            if hasGeometryBackground {
                GeometryReader { proxy in
                    Rectangle()
                        .fill(.clear)
                        .onAppear {
                            detectOffset(proxy)
                        }
                        .onChange(
                            of: proxy.frame(in: .named(coordinateSpace))
                        ) { value in
                            guard value.height > 0 else { return }
                            detectOffset(proxy)
                        }
                }
            }
        }
    }
    
    @ViewBuilder
    private func makeChatDate(_ offset: Int, _ messageGroup: DateMessageGroup) -> some View {
        ChatDate(text: messageGroup.textedDate)
            .background {
                getChatDateGeometry(offset)
            }
    }
    
    @ViewBuilder
    private func makeBubbles(dateMessageGroup: DateMessageGroup) -> some View {
        ForEach(
            dateMessageGroup.userMessageGroups,
            id: \.id
        ) { userMessagesGroup in
            switch userMessagesGroup.author {
            case let .remoteOperator(operatorName):
                ChatRemoteOperatorBubblesView(
                    operatorName: operatorName,
                    userMessageGroup: userMessagesGroup,
                    onContextAction: { id in viewModel.send(.onQuote(id: id)) },
                    onProxyChange: { proxy, message in
                        let messageMinY = proxy.frame(in: .global).minY
                        let listMaxY = screenData.listFrame.maxY
                        if listMaxY - messageMinY > 0 {
                            viewModel.send(.onMessageAppear(message))
                        }
                    })
                    .id(userMessagesGroup.id)
            case .currentUser:
                ChatUserBubblesView(userMessageGroup: userMessagesGroup)
                    .id(userMessagesGroup.id)
            case .systemMessage:
                ChatSystemMessageView(userMessageGroup: userMessagesGroup)
                    .id(userMessagesGroup.id)
            case .unknown:
                EmptyView().id(userMessagesGroup.id)
            }
        }
    }
    
    @ViewBuilder
    private func makeActionsView(_ offset: Int) -> some View {
        if offset == 0 {
            ChatActionsView(actions: $viewModel.botActions) {
                viewModel.send(.onBotAction($0))
            }
            .listRowSeparator(.hidden)
            .listRowInsets(.zero)
            .id("actions")
        }
    }
    
    @ViewBuilder
    private func makeTypingView(_ offset: Int) -> some View {
        if viewModel.isOperatorTyping && offset == 0 {
            ChatTyping(typoText: "chat_operator_typing".localized)
                .padding(.leading, 24.0)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    @ViewBuilder
    private func makeBottomAnchor(_ offset: Int) -> some View {
        if offset == 0 && !viewModel.dateMessageGroups.isEmpty {
            GeometryReader { proxy in
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(height: 1, alignment: .center)
                    .onAppear {
                        let bottomY = screenData.listFrame.maxY
                        let anchorY = proxy.frame(in: .global).maxY
                        viewModel.send(.onAnchorChange(anchorY - bottomY))
                    }
                    .onChange(
                        of: proxy.frame(in: .global)
                    ) { frame in
                        let bottomY = screenData.listFrame.maxY
                        let anchorY = frame.maxY
                        viewModel.send(.onAnchorChange(anchorY - bottomY))
                    }
            }
        }
    }
}

final class ScreenData: ObservableObject {
    @Published fileprivate var listFrame: CGRect = .zero
    @Published fileprivate var previousContentHeight: CGFloat = 0.0
    @Published fileprivate var isRefreshing = false
    
    @MainActor
    fileprivate func set(listFrame: CGRect) {
        if self.listFrame != listFrame {
            self.listFrame = listFrame
        }
    }
    
    @MainActor
    fileprivate func set(previousContentHeight: CGFloat) {
        if self.previousContentHeight != previousContentHeight {
            self.previousContentHeight = previousContentHeight
        }
    }
    
    @MainActor
    fileprivate func set(isRefreshing: Bool) {
        if self.isRefreshing != isRefreshing {
            self.isRefreshing = isRefreshing
        }
    }
}

// MARK: - Расширение с методами по вычислению размеров фреймов и геометрии.

extension ChatListView {
    
    fileprivate func detectOffset(_ proxy: GeometryProxy) {
        let contentFrame = proxy.frame(in: .named(coordinateSpace))
        
        guard contentFrame.minY >= 0 else {
            if self.screenData.isRefreshing {
                self.screenData.set(isRefreshing: false)
            }
            return
        }
        guard !viewModel.isRefreshing else {
            screenData.set(isRefreshing: false)
            return
        }
        if Int(self.screenData.previousContentHeight) < Int(self.screenData.listFrame.height) {
            self.screenData.set(previousContentHeight: contentFrame.height)
            let contentOffset = contentFrame.maxY
            let listMaxY = self.screenData.listFrame.maxY
            sendRefreshEvent(contentOffset, listMaxY)
        } else {
            if contentFrame.height > self.screenData.previousContentHeight {
                self.screenData.set(previousContentHeight: contentFrame.height)
            }
            let contentOffset = contentFrame.minY
            let listMinY = self.screenData.listFrame.minY
            sendRefreshEvent(contentOffset, listMinY)
        }
    }
    
    @MainActor
    fileprivate func detectListFrame(_ proxy: GeometryProxy) {
        let listFrame = proxy.frame(in: .global)
        self.screenData.set(listFrame: listFrame)
    }
    
    @MainActor
    private func sendRefreshEvent(_ contentOffset: CGFloat, _ listY: CGFloat) {
        let diff = contentOffset - listY
        let minDiffForUpdate = 20.0
        guard diff >= 0 else {
            screenData.set(isRefreshing: false)
            return
        }
        screenData.set(isRefreshing: diff >= minDiffForUpdate)
    }
}
