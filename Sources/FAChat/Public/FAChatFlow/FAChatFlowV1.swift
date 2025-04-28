//
//  FAChatFlowV1.swift
//  
//
//  Created by Ilja Malakhov on 21.11.2024.
//

import UIKit

public struct FAChatFlowV1 {
    
    // MARK: - Data
    
    let input: FAChatInput
    
    // MARK: - Init
    
    public init(input: FAChatInput) {
        self.input = input
    }
    
    // MARK: - Factory
    
    public func makeViewController() -> UIViewController {
        return Self.makeChat(input: input)
    }
}

extension FAChatFlowV1: ChatFactory { }
