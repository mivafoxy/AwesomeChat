public protocol MyChatWebApi {
    func connect() async throws
    func startDialog()
    func loadHistory(with timestamp: Int)
    func send(content: String, _ repliedMessage: MyChatMessage?)
    func sendAction(with id: String)
    func sendReadConfirmation(messageId: String)
    func send(operatorScore: Int)
    func disconnect()
    func setup(eventDelegate: MyChatEventDelegate)
}
