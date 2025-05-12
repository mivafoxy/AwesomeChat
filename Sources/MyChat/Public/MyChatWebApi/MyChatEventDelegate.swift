public protocol MyChatEventDelegate: AnyObject {
    func didConnect()
    func didDisconnect()
    func didReconnect()
    func didAuthorize()
    func didReceiveError(_ error: Error?, _ data: Any?)
    func didReceiveMessage(_ message: MyChatMessage)
    func didReceiveHistoryMessages(_ messages: [MyChatMessage])
}
