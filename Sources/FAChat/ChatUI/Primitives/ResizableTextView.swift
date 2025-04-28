//
//  ResizableTextView.swift
//  
//
//  Created by Илья Малахов on 14.01.2025.
//

import UIKit

final class ResizableTextView: UITextView {
    
    private var lastWidth: CGFloat = 0
    var maxHeight: CGFloat?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        lastWidth = bounds.width
        
        let lineHeight = font?.lineHeight ?? contentSize.height
        let numOfLines = contentSize.height / lineHeight
        
        if Int(numOfLines.rounded(.up)) > 1 {
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        let size = sizeThatFits(
            CGSize(
                width: lastWidth,
                height: UIView.layoutFittingExpandedSize.height
            )
        )
        let height = getHeight(size)
        return CGSize(
            width: size.width.rounded(.up),
            height: height
        )
    }
    
    private func getHeight(_ fittedSize: CGSize) -> CGFloat {
        let fittedHeight = fittedSize.height.rounded(.up)
        if let maxHeight = maxHeight {
            return fittedHeight > maxHeight ? maxHeight : fittedHeight
        }
        return fittedHeight
    }
}
