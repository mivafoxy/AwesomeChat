//
//  MyChatFlowV1.swift
//  
//
//  Created by Ilja Malakhov on 21.11.2024.
//

import UIKit

public struct MyChatFlowV1 {
    
    // MARK: - Data
    
    let input: MyChatInput
    
    // MARK: - Init
    
    public init(input: MyChatInput) {
        self.input = input
    }
    
    // MARK: - Factory
    
    public func makeViewController() -> UIViewController {
        return Self.makeChat(input: input)
    }
}

extension MyChatFlowV1: ChatFactory { }
