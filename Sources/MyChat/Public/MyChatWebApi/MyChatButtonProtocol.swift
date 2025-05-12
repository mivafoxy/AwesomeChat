public protocol MyChatButtonProtocol: Sendable {
    var id: String { get }
    var title: String { get }
    var action: String { get }
    var type: MyChatButtonType? { get }
}
