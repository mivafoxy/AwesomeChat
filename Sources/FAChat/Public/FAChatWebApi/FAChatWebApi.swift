//
//  FAChatWebApi.swift
//  FAChatWebApi
//
//  Created by Илья Малахов on 28.04.2025.
//

public protocol FAChatWebApi {
    func connect() async throws
    func startDialog()
    func loadHistory(with timestamp: Int)
    func send(content: String, _ repliedMessage: FAChatMessage?)
    func sendAction(with id: String)
    func sendReadConfirmation(messageId: String)
    func send(operatorScore: Int)
    func disconnect()
    func setup(eventDelegate: FAChatEventDelegate)
}
