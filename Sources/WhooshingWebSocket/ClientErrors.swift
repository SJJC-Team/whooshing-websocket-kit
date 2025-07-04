import ErrorHandle

//public extension HttpsWebSocket {
//    @frozen
//    enum Errcase: String, ErrList, Sendable {
//        public typealias ErrType = WhooshingWebSocketError<HttpsWebSocket>
//        
//        case internalFailure = "内部未知错误"
//    }
//}
//
//public extension ApiWebSocket {
//    @frozen
//    enum Errcase: String, ErrList, Sendable {
//        public typealias ErrType = WhooshingWebSocketError<ApiWebSocket>
//        
//        case internalFailure = "内部未知错误"
//    }
//}
//
//@frozen
//public struct WhooshingWebSocketError<Client>: Err, Sendable where Client: WhooshingWebSocket {
//    /// 该错误的错误枚举值。
//    public var error: Client.Errcase!
//    /// 每次发生错误时，可以自行阐述一些附加说明。
//    public var explain: String?
//    /// 发生错误的文件名称。
//    public var file: String!
//    /// 发生错误的行数。
//    public var line: Int!
//    /// 发生错误的函数。
//    public var function: String!
//    /// 该错误的子错误
//    public var subError: (any Error)?
//
//    /// 空初始化函数，用于默认构造实例
//    @inlinable
//    public init() {}
//}

@frozen
public enum WhooshingWebSocketErrcase: String, ErrList, Sendable {    
    case pingFailed = "WebSocket 第一次 ping 请求失败"
    case upgradeFailed = "WebSocket 升级失败"
    case tcpHandlerRemoveFailed = "TCP 处理器移除失败"
    case wsHandlerAddFailed = "WebSocket 处理器添加失败"
    case wsConnectFailed = "WebSocket 连接失败"
    
    case internalFailure = "内部错误"
}
