//
//  FAChatActionProtocol.swift
//  FAChat
//
//  Created by Илья Малахов on 28.04.2025.
//

public protocol FAChatActionProtocol: Sendable {
    var id: String { get }
    var text: String { get }
}
