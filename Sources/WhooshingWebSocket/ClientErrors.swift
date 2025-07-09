import ErrorHandle

@frozen
public enum WhooshingWebSocketErrcase: String, ErrList, Sendable {    
    case pingFailed = "WebSocket 第一次 ping 请求失败"
    case upgradeFailed = "WebSocket 升级失败"
    case tcpHandlerRemoveFailed = "TCP 处理器移除失败"
    case wsHandlerAddFailed = "WebSocket 处理器添加失败"
    case wsConnectFailed = "WebSocket 连接失败"

    case internalFailure = "内部错误"
}
