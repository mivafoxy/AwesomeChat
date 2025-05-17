public protocol MyChatActionProtocol: Sendable {
    var id: String { get }
    var text: String { get }
}
