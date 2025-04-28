//
//  ChatBottomSheet.swift
//  
//
//  Created by Илья Малахов on 27.02.2025.
//

import SwiftUI
import MRDSKit

public struct ChatBottomSheet<Content: View>: View {
    
    private let content: () -> Content
    
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    public var body: some View {
        content()
            .frame(maxWidth: .infinity, alignment: .bottom)
            .background {
                Rectangle()
                    .foregroundColor(color: MRBackgroundColor.colorBackground)
            }
    }
}

struct BottomSheetModifier<SheetContent: View>: ViewModifier {
    
    @Binding var isHidden: Bool
    @ViewBuilder var sheetContent: () -> SheetContent
    @State private var yOffset: CGFloat = .zero
    @State private var contentSize: CGSize = .zero
    
    func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(Color(MRBackgroundColor.colorBackground.color))
                .overlay {
                    content.allowsHitTesting(isHidden)
                }
                .blur(radius: isHidden ? 0 : 12)
                .onTapGesture {
                    if !isHidden {
                        isHidden.toggle()
                    }
                }
            VStack {
                if !isHidden {
                    ChatBottomSheet(content: sheetContent)
                        .cornerRadius(12.0, corners: .topLeft)
                        .cornerRadius(12.0, corners: .topRight)
                        .shadow(
                            color: Color.black.opacity(0.06),
                            radius: 4,
                            x: 0,
                            y: -4
                        )
                        .transition(.move(edge: .bottom))
                }
            }
            .offset(
                x: 0,
                y: yOffset > 0 ? yOffset : 0
            )
            .gesture(
                DragGesture(minimumDistance: 10, coordinateSpace: .local)
                    .onChanged { gestureValue in
                        yOffset = gestureValue.location.y - gestureValue.startLocation.y
                    }
                    .onEnded { gestureValue in
                        withAnimation {
                            yOffset = .zero
                        }
                    }
            )
            .background {
                GeometryReader { proxy in
                    Rectangle()
                        .fill(.clear)
                        .onAppear {
                            contentSize = proxy.size
                        }
                        .onChange(of: proxy.size) { newSize in
                            contentSize = newSize
                        }
                }
                
            }
            .onChange(of: yOffset) { newOffset in
                if newOffset > contentSize.height / 1.5 {
                    isHidden = true
                }
            }
        }
        .animation(.easeOut(duration: 0.2), value: isHidden)
    }
}

extension View {
    public func bottomSheet<Content: View> (
        isHidden: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        ModifiedContent(
            content: self,
            modifier: BottomSheetModifier(
                isHidden: isHidden,
                sheetContent: content
            )
        )
    }
}
