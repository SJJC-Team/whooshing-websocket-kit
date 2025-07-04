import NIOCore
import Logging
import WhooshingClient
import ErrorHandle
import NIOAdvanced

public protocol WSIOHandler: Sendable {
    associatedtype Failure: Error
    func send(dataChunk: ByteBuffer, context: ChannelHandlerContext) -> EventLoopResult<ByteBuffer, Failure>
    func get(dataChunk: ByteBuffer, context: ChannelHandlerContext) -> EventLoopResult<ByteBuffer, Failure>
    func connectionStart(context: ChannelHandlerContext) -> EventLoopResult<Void, Failure>
    func connectionEnd(context: ChannelHandlerContext) -> EventLoopResult<Void, Failure>
}

public extension WSIOHandler {
    func connectionStart(context: ChannelHandlerContext) -> EventLoopResult<Void, Failure> { context.eventLoop.makeSucceededVoidResult() }
    func connectionEnd(context: ChannelHandlerContext) -> EventLoopResult<Void, Failure> { context.eventLoop.makeSucceededVoidResult() }
}

final class WSHandler<IOHandler>: ChannelDuplexHandler, Sendable where IOHandler: WSIOHandler {
    typealias InboundIn = ByteBuffer
    typealias InboundOut = ByteBuffer
    typealias OutboundIn = ByteBuffer
    typealias OutboundOut = ByteBuffer
    
    private let logger: Logger?
    private let ioHandler: IOHandler
    
    init(ioHandler: IOHandler, logger: Logger? = nil) {
        self.logger = logger
        self.ioHandler = ioHandler
    }
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let data = unwrapInboundIn(data)
        
        self.ioHandler.get(dataChunk: data, context: context).whenComplete { res in
            switch res {
            case .success(let data): context.fireChannelRead(self.wrapInboundOut(data))
            case .failure(let err): self.errorHappend(context: context, error: err)
            }
        }
    }
    
    func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        let data = unwrapOutboundIn(data)
        guard data.readableBytes > 0 else { return }

        let r = self.ioHandler.send(dataChunk: data, context: context).wrapped.flatMap { data in
            return context.writeAndFlush(self.wrapOutboundOut(data))
        }.flatMapErrorThrowing { err in
            self.errorHappend(context: context, error: err)
        }
        
        if let p = promise {
            r.cascade(to: p)
        }
    }
    
    func channelRegistered(context: ChannelHandlerContext) {
        ioHandler.connectionStart(context: context).whenFailure { err in
            self.errorHappend(context: context, error: err)
        }
        context.fireChannelRegistered()
    }
    
    func channelUnregistered(context: ChannelHandlerContext) {
        ioHandler.connectionEnd(context: context).whenFailure { err in
            self.errorHappend(context: context, error: err)
        }
        context.fireChannelUnregistered()
    }
    
    func errorHappend(context: ChannelHandlerContext, error: any Error) {
        logger?.warning("\(error)")
        context.fireErrorCaught(error)
    }
}
