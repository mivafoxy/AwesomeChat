public protocol MyChatMessage {
    var id: String { get }
    var messageType: MyChatMessageType { get }
    var isReplied: Bool { get }
    var parentMessageId: String? { get }
    var additionalParentMessageId: String? { get }
    var timestamp: Int { get }
    var text: String? { get }
    var score: Int { get }
    var actions: [MyChatActionProtocol]? { get }
    var action: String? { get }
    var operatorName: String? { get }
    var operatorId: String? { get }
    var fromChannelId: String? { get }
    var replyToMessage: MyChatMessage? { get }
    var buttons: [[MyChatButtonProtocol]]? { get }
}
