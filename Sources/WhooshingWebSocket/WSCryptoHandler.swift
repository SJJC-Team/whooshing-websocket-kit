import NIOCore
import WhooshingClient
import Cryptos
import ErrorHandle
import NIOFoundationCompat
import Logging
import NIOWebSocket
import NIOAdvanced

struct WSCryptoHandler: WSIOHandler, Sendable {
    
    @frozen
    public enum Errcase: String, ErrList {
        var domain: String { "woo.sys.websocket.crypto.err" }
        case responseDecryptFailed = "对响应解密时发生错误"
        case requestEncryptFailed = "对请求加密时发生错误"
    }
    
    let key: Crypto.Symm.Key
    let logger: Logger?
    
    /// 发送请求时，进行编码并加密
    func send(dataChunk: ByteBuffer, context: ChannelHandlerContext) -> EventLoopRes<ByteBuffer, Errcase> {
        context.eventLoop.submitResult { () throws(Failure) in
            logger?.trace("API.WS.Client-发送数据中: 大小 \(ChunkTool.formatByteSize(dataChunk.readableBytes)) \(context.channel.clientAddrInfo)")
            return try required(throws: Errcase.requestEncryptFailed) {
                try context.channel.allocator.buffer(data: Crypto.Symm.encrypt(dataChunk, key: key).get())
            }
        }
    }
    
    /// 收到响应时，进行解密并解码
    func get(dataChunk: ByteBuffer, context: ChannelHandlerContext) -> EventLoopRes<ByteBuffer, Errcase> {
        context.eventLoop.submitResult { () throws(Failure) in
            logger?.trace("API.WS.Client-接收数据中: 大小 \(ChunkTool.formatByteSize(dataChunk.readableBytes)) \(context.channel.clientAddrInfo)")
            return try required(throws: Errcase.responseDecryptFailed) {
                try Crypto.Symm.decrypt(.init(buffer: dataChunk), key: key).get()
            }
        }
    }
    
    func connectionStart(context: ChannelHandlerContext) -> EventLoopRes<Void, Errcase> {
        logger?.debug("API.WS.Client-连线建立: \(context.channel.clientAddrInfo)")
        return context.eventLoop.makeSucceededVoidResult()
    }
    
    func connectionEnd(context: ChannelHandlerContext) -> EventLoopRes<Void, Errcase> {
        logger?.debug("API.WS.Client-连线结束: \(context.channel.clientAddrInfo)")
        return context.eventLoop.makeSucceededVoidResult()
    }
}

extension WebSocketFrameEncoder: @unchecked @retroactive Sendable {}
