//
//  ChatQuoteContent.swift
//  
//
//  Created by Илья Малахов on 05.11.2024.
//

import SwiftUI

struct ChatQuoteContent: View {
    
    var image: Image? = nil
    var fileImage: Image? = nil
    var title: String
    var content: String
    
    var body: some View {
        HStack(alignment: .center, spacing: .zero) {
            verticalRect
            imageView.padding(.leading, 8.0)
            fileImageView
            textContent.padding(.leading, fileImage == nil ? 8.0 : .zero)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
        
    private var verticalRect: some View {
        RoundedRectangle(cornerRadius: 2.0)
            .foregroundStyle(.primary)
            .frame(
                width: 3.0,
                height: 34.0
            )
    }
    
    private var imageView: some View {
        image
            .frame(width: 30.0, height: 30.0)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 4.0
                )
            )
    }
    
    private var fileImageView: some View {
        fileImage
            .frame(
                width: 32.0,
                height: 32.0
            )
            .foregroundStyle(.primary)
    }
    
    private var textContent: some View {
        VStack(
            alignment: .leading,
            spacing: 2.0
        ) {
            Text(title)
                .font(.caption)
                .lineLimit(1)
                .truncationMode(.tail)
                .foregroundStyle(.primary)
            Text(content)
                .font(.caption2)
                .lineLimit(1)
                .truncationMode(.tail)
                .foregroundStyle(.primary)
        }
    }
}
