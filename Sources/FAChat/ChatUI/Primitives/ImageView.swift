//
//  ImageView.swift
//  
//
//  Created by Илья Малахов on 24.10.2024.
//

import SwiftUI
import MRDSKit

struct ImageView: View {
    
    var mrImage: MRImage?
    
    @State
    private var image = UIImage()
    
    var body: some View {
        if let mrImage = mrImage {
            Image(uiImage: image)
                .resizable()
                .foregroundStyle(background: mrImage.background)
                .tint(.init(mrImage.tintColor?.color ?? .tintColor))
                .onReceive(mrImage.publisher) { image in
                    if let image = image {
                        self.image = image
                    } else if let placeholder = mrImage.placeholder {
                        self.image = placeholder
                    }
                }
        } else {
            EmptyView()
        }
    }
}
