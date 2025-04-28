//
//  ChatQuoteContent.swift
//  
//
//  Created by Илья Малахов on 05.11.2024.
//

import SwiftUI
import MRDSKit

struct ChatQuoteContent: View {
    
    var image: MRImage? = nil
    var fileImage: MRImage? = nil
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
            .foregroundColor(color: MRElementsColor.colorPrimaryHover)
            .frame(
                width: 3.0,
                height: 34.0
            )
    }
    
    private var imageView: some View {
        ImageView(mrImage: image)
            .frame(width: 30.0, height: 30.0)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 4.0
                )
            )
    }
    
    private var fileImageView: some View {
        ImageView(mrImage: fileImage)
            .frame(
                width: 32.0,
                height: 32.0
            )
            .foregroundColor(color: MRElementsColor.colorPrimary)
    }
    
    private var textContent: some View {
        VStack(
            alignment: .leading,
            spacing: 2.0
        ) {
            Text(title)
                .font(fontStyle: .caption1)
                .lineLimit(1)
                .truncationMode(.tail)
                .foregroundColor(color: MRElementsColor.colorPrimaryHover)
            Text(content)
                .font(fontStyle: .caption1)
                .lineLimit(1)
                .truncationMode(.tail)
                .foregroundColor(color: MRTextColor.colorTextPrimary)
        }
    }
}
