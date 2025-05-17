//
//  String+extension.swift
//
//
//  Created by Ilja Malakhov on 21.11.2024.
//

import Foundation

extension String {
    var localized: String {
        NSLocalizedString(self, bundle: .module, comment: "")
    }
}
