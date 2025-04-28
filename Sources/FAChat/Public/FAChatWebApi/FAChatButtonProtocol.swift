//
//  FAChatButtonProtocol.swift
//  FAChat
//
//  Created by Илья Малахов on 28.04.2025.
//

public protocol FAChatButtonProtocol: Sendable {
    var id: String { get }
    var title: String { get }
    var action: String { get }
    var type: FAChatButtonType? { get }
}
