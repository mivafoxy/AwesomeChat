//
//  Image+Extension.swift
//  MyChat
//
//  Created by Илья Малахов on 11.05.2025.
//

import SwiftUI

extension Image {
    @MainActor
    func getUIImage(newSize: CGSize) -> UIImage {
        let image = resizable()
            .scaledToFill()
            .frame(width: newSize.width, height: newSize.height)
            .clipped()
        return ImageRenderer(content: image).uiImage ?? UIImage()
    }
}
