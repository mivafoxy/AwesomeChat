//
//  ChatContextAction.swift
//  
//
//  Created by Илья Малахов on 06.11.2024.
//

import Foundation
import MRDSKit
import SwiftUI

public struct ChatContextAction: Identifiable {
    
    public let id = UUID().uuidString
    
    public let title: String
    public let icon: UIImage?
    public let action: (_ text: String, _ image: MRImage?) -> Void
    
    public init(
        title: String,
        icon: UIImage?,
        action: @escaping (_ text: String, _ image: MRImage?) -> Void
    ) {
        self.title = title
        self.icon = icon
        self.action = action
    }
}
