//
//  FAChatEventDelegate.swift
//  FAChat
//
//  Created by Илья Малахов on 28.04.2025.
//

public protocol FAChatEventDelegate: AnyObject {
    func didConnect()
    func didDisconnect()
    func didReconnect()
    func didAuthorize()
    func didReceiveError(_ error: Error?, _ data: Any?)
    func didReceiveMessage(_ message: FAChatMessage)
    func didReceiveHistoryMessages(_ messages: [FAChatMessage])
}
