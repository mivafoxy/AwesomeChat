//
//  FlowLayout.swift
//  
//
//  Created by Илья Малахов on 02.12.2024.
//

import SwiftUI

struct FlowLayout<RefreshBinding, Data: Collection, ItemView: View>: View {
    let mode: Mode
    let rotated: Bool
    @Binding var binding: RefreshBinding
    let items: Data
    let itemSpacing: CGFloat
    @ViewBuilder let viewMapping: (Data.Element) -> ItemView
    
    @State private var totalHeight: CGFloat
    
    public init(
        mode: Mode = .vstack,
        rotated: Bool = false,
        binding: Binding<RefreshBinding>,
        items: Data,
        itemSpacing: CGFloat = 0,
        @ViewBuilder viewMapping: @escaping (Data.Element) -> ItemView
    ) {
        self.mode = mode
        self.rotated = rotated
        _binding = binding
        self.items = items
        self.itemSpacing = itemSpacing
        self.viewMapping = viewMapping
        _totalHeight = State(initialValue: (mode == .scrollable) ? .zero : .infinity)
    }
    
    public var body: some View {
        let stack = VStack {
            GeometryReader { geometry in
                self.content(in: geometry)
            }
        }
            .rotationEffect(.degrees(rotated ? 180 : 0))
        return Group {
            if mode == .scrollable {
                stack.frame(height: totalHeight)
            } else {
                stack.frame(maxHeight: totalHeight)
            }
        }
    }
    
    private func content(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        var lastHeight = CGFloat.zero
        let itemCount = items.count
        return ZStack(alignment: .topLeading) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                viewMapping(item)
                    .padding([.horizontal, .vertical], itemSpacing)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > g.size.width) {
                            width = 0
                            height -= lastHeight
                        }
                        lastHeight = d.height
                        let result = width
                        if index == itemCount - 1 {
                            width = 0
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { d in
                        let result = height
                        if index == itemCount - 1 {
                            height = 0
                        }
                        return result
                    })
                    .rotationEffect(.degrees(rotated ? 180 : 0))
            }
        }
        .background(HeightReaderView(binding: $totalHeight))
    }
    
    public enum Mode {
        case scrollable, vstack
    }
}

private struct HeightPreferenceKey: PreferenceKey {
    static func reduce(value _: inout CGFloat, nextValue _: () -> CGFloat) {}
    static var defaultValue: CGFloat = 0
}

private struct HeightReaderView: View {
    @Binding var binding: CGFloat
    var body: some View {
        GeometryReader { geo in
            Color.clear
                .preference(key: HeightPreferenceKey.self, value: geo.frame(in: .local).size.height)
        }
        .onPreferenceChange(HeightPreferenceKey.self) { h in
            binding = h
        }
    }
}


extension FlowLayout where RefreshBinding == Never? {
    init(
        mode: Mode,
        rotated: Bool = false,
        items: Data,
        itemSpacing: CGFloat = 0,
        @ViewBuilder viewMapping: @escaping (Data.Element) -> ItemView
    ) {
        self.init(
            mode: mode,
            rotated: rotated,
            binding: .constant(nil),
            items: items,
            itemSpacing: itemSpacing,
            viewMapping: viewMapping
        )
    }
}
