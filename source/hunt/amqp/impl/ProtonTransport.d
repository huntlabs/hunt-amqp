/*
* Copyright 2016, 2017 the original author or authors.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/
module hunt.amqp.impl.ProtonTransport;

import hunt.net.NetClient;
import hunt.amqp.ProtonReceiver;
import hunt.amqp.ProtonSender;
import hunt.net.buffer.ByteBuf;
import hunt.io.ByteBuffer;
// import hunt.io.Buffer;
import hunt.amqp.ProtonConnection;
import hunt.amqp.ProtonTransportOptions;
import hunt.amqp.sasl.ProtonSaslAuthenticator;
import hunt.proton.Proton;
import hunt.proton.engine.BaseHandler;
import hunt.proton.engine.Collector;
import hunt.proton.engine.Connection;
import hunt.proton.engine.EndpointState;
import hunt.proton.engine.Event;
import hunt.proton.engine.Transport;
import hunt.proton.engine.impl.TransportInternal;
import hunt.amqp.impl.ProtonClientImpl;
import hunt.net.Connection;
import hunt.net.buffer.WrappedByteBuf;
import hunt.amqp.impl.ProtonConnectionImpl;
import hunt.amqp.impl.ProtonSessionImpl;
import hunt.amqp.impl.ProtonLinkImpl;
import hunt.amqp.impl.ProtonDeliveryImpl;
import hunt.amqp.impl.ProtonReceiverImpl;
import hunt.net.buffer.Unpooled;
import hunt.Exceptions;
import hunt.logging;
import std.algorithm;
import hunt.amqp.Handler;
import std.stdio;
import hunt.time.LocalDateTime;
import hunt.util.DateTime;
// import hunt.io.BufferUtils;
import hunt.concurrency.ScheduledThreadPoolExecutor;
import hunt.concurrency.Executors;
import hunt.concurrency.ExecutorService;
import hunt.concurrency.Scheduler;
import hunt.concurrency.Delayed;
import hunt.util.Common;
import core.time;
import std.concurrency : initOnce;
import hunt.time.LocalDateTime;
import hunt.util.Runnable;

/**
 * @author <a href="http://tfox.org">Tim Fox</a>
 * @author <a href="http://hiramchirino.com">Hiram Chirino</a>
 */

alias NetSocket = hunt.net.Connection;
alias ConnCallBack = void delegate(NetSocket.Connection connection);
alias MsgCallBack = void delegate(NetSocket.Connection connection, ByteBuffer message);

/**
 *
 */
struct CommonUtil {

    static ScheduledThreadPoolExecutor scheduler() {
        return initOnce!_scheduler(
                cast(ScheduledThreadPoolExecutor) Executors.newScheduledThreadPool(5));
    }

    private __gshared ScheduledThreadPoolExecutor _scheduler;

    static void stopScheduler() {
        if (_scheduler !is null) {
            _scheduler.shutdown();
        }
    }
}

/**
 * 
 */
class ProtonTransport : BaseHandler {
    private static int DEFAULT_MAX_FRAME_SIZE = 32 * 1024; // 32kb

    private hunt.proton.engine.Connection.Connection connection;
    private NetClient netClient;
    private hunt.net.Connection.Connection socket;
    private Transport transport; //= Proton.transport();
    private Collector collector; // = Proton.collector();
    private ProtonSaslAuthenticator authenticator;
    private ScheduledThreadPoolExecutor executor;

    // private volatile Long idleTimeoutCheckTimerId; // TODO: cancel when closing etc?

    private bool failed;

    this(hunt.proton.engine.Connection.Connection connection, NetClient netClient,
            hunt.net.Connection.Connection socket,
            ProtonSaslAuthenticator authenticator, ProtonTransportOptions options) {
        this.transport = Proton.transport();
        this.collector = Proton.collector();
        this.connection = connection;
        this.netClient = netClient;
        this.socket = socket;
        int maxFrameSize = options.getMaxFrameSize() == 0
            ? DEFAULT_MAX_FRAME_SIZE : options.getMaxFrameSize();
        transport.setMaxFrameSize(maxFrameSize);
        transport.setOutboundFrameSizeLimit(maxFrameSize);
        transport.setEmitFlowEventOnSend(false); // TODO: make configurable
        transport.setIdleTimeout(2 * options.getHeartbeat());
        (cast(TransportInternal) transport).setUseReadOnlyOutputBuffer(false);
        if (authenticator !is null) {
            authenticator.init(this.socket,
                    cast(ProtonConnection)(this.connection.getContext()), transport);
        }
        this.authenticator = authenticator;
        transport.bind(connection);
        connection.collect(collector);
        (cast(ConnectionEventBaseHandler)(socket.getHandler())).setOnClosed(&this.handleSocketEnd);
        (cast(ConnectionEventBaseHandler)(socket.getHandler())).setOnMessage(
                &this.handleSocketBuffer);
        // socket.endHandler(this::handleSocketEnd);
        //socket.handler(this::handleSocketBuffer);
    }

    private void handleSocketEnd(NetSocket.Connection arg) {
        transport.unbind();
        transport.close();
        if (this.netClient !is null) {
            this.netClient.close();
        } else {
            this.socket.close();
        }
        (cast(ProtonConnectionImpl) this.connection.getContext()).fireDisconnect();
    }

    private void handleSocketBuffer(hunt.net.Connection.Connection connection, ByteBuffer buff) {
        pumpInbound(buff);

        Event protonEvent = null;

        enum CONNECTION_REMOTE_OPEN = AmqpEventType.CONNECTION_REMOTE_OPEN.ordinal;
        enum CONNECTION_REMOTE_CLOSE = AmqpEventType.CONNECTION_REMOTE_CLOSE.ordinal;
        enum SESSION_REMOTE_OPEN = AmqpEventType.SESSION_REMOTE_OPEN.ordinal;
        enum SESSION_REMOTE_CLOSE = AmqpEventType.SESSION_REMOTE_CLOSE.ordinal;
        enum LINK_REMOTE_OPEN = AmqpEventType.LINK_REMOTE_OPEN.ordinal;
        enum LINK_REMOTE_DETACH = AmqpEventType.LINK_REMOTE_DETACH.ordinal;
        enum LINK_REMOTE_CLOSE = AmqpEventType.LINK_REMOTE_CLOSE.ordinal;
        enum LINK_FLOW = AmqpEventType.LINK_FLOW.ordinal;
        enum DELIVERY = AmqpEventType.DELIVERY.ordinal;
        enum TRANSPORT_ERROR = AmqpEventType.TRANSPORT_ERROR.ordinal;
        enum CONNECTION_INIT = AmqpEventType.CONNECTION_INIT.ordinal;
        enum CONNECTION_BOUND = AmqpEventType.CONNECTION_BOUND.ordinal;
        enum CONNECTION_UNBOUND = AmqpEventType.CONNECTION_UNBOUND.ordinal;
        enum CONNECTION_LOCAL_OPEN = AmqpEventType.CONNECTION_LOCAL_OPEN.ordinal;
        enum CONNECTION_LOCAL_CLOSE = AmqpEventType.CONNECTION_LOCAL_CLOSE.ordinal;
        enum CONNECTION_FINAL = AmqpEventType.CONNECTION_FINAL.ordinal;

        enum SESSION_INIT = AmqpEventType.SESSION_INIT.ordinal;
        enum SESSION_LOCAL_OPEN = AmqpEventType.SESSION_LOCAL_OPEN.ordinal;
        enum SESSION_LOCAL_CLOSE = AmqpEventType.SESSION_LOCAL_CLOSE.ordinal;
        enum SESSION_FINAL = AmqpEventType.SESSION_FINAL.ordinal;

        enum LINK_INIT = AmqpEventType.LINK_INIT.ordinal;
        enum LINK_LOCAL_OPEN = AmqpEventType.LINK_LOCAL_OPEN.ordinal;
        enum LINK_LOCAL_DETACH = AmqpEventType.LINK_LOCAL_DETACH.ordinal;
        enum LINK_LOCAL_CLOSE = AmqpEventType.LINK_LOCAL_CLOSE.ordinal;
        enum LINK_FINAL = AmqpEventType.LINK_FINAL.ordinal;

        while ((protonEvent = collector.peek()) !is null) {
            ProtonConnectionImpl conn = cast(ProtonConnectionImpl) protonEvent.getConnection()
                .getContext();

            Type eventType = protonEvent.getType();
            int type = eventType.ordinal;

            version (HUNT_AMQP_DEBUG) {
                if (eventType != (Type.TRANSPORT)) {
                    warningf("New Proton Event: %s, ordinal: %d", eventType.toString(), type);
                }
            }
            // warningf("New Proton Event: %s, ordinal: %d", eventType.toString(), type);

            switch (type) {
            case CONNECTION_REMOTE_OPEN: {
                    conn.fireRemoteOpen();
                    initiateIdleTimeoutChecks();
                    break;
                }

            case CONNECTION_REMOTE_CLOSE: {
                    conn.fireRemoteClose();
                    break;
                }

            case SESSION_REMOTE_OPEN: {
                    ProtonSessionImpl session = cast(ProtonSessionImpl) protonEvent.getSession()
                        .getContext();
                    if (session is null) {
                        conn.fireRemoteSessionOpen(protonEvent.getSession());
                    } else {
                        session.fireRemoteOpen();
                    }
                    break;
                }
            case SESSION_REMOTE_CLOSE: {
                    ProtonSessionImpl session = cast(ProtonSessionImpl) protonEvent.getSession()
                        .getContext();
                    session.fireRemoteClose();
                    break;
                }
            case LINK_REMOTE_OPEN: {
                    ProtonLinkImpl!ProtonReceiver link = cast(ProtonLinkImpl!ProtonReceiver) protonEvent.getLink()
                        .getContext();
                    if (link !is null) {
                        link.fireRemoteOpen();
                        break;
                    }

                    ProtonLinkImpl!ProtonSender lins = cast(ProtonLinkImpl!ProtonSender) protonEvent.getLink()
                        .getContext();
                    if (lins !is null) {
                        lins.fireRemoteOpen();
                        break;
                    }

                    conn.fireRemoteLinkOpen(protonEvent.getLink());
                    //if (link is null) {
                    //  conn.fireRemoteLinkOpen(protonEvent.getLink());
                    //} else {
                    //  link.fireRemoteOpen();
                    //}
                    break;
                }
            case LINK_REMOTE_DETACH: {
                    ProtonLinkImpl!ProtonReceiver link = cast(ProtonLinkImpl!ProtonReceiver) protonEvent.getLink()
                        .getContext();
                    if (link !is null) {
                        link.fireRemoteDetach();
                        break;
                    } else {
                        ProtonLinkImpl!ProtonSender lk = cast(ProtonLinkImpl!ProtonSender) protonEvent.getLink()
                            .getContext();
                        lk.fireRemoteDetach();
                        break;
                    }
                }

            case LINK_REMOTE_CLOSE: {
                    ProtonLinkImpl!ProtonReceiver link = cast(ProtonLinkImpl!ProtonReceiver) protonEvent.getLink()
                        .getContext();
                    if (link !is null) {
                        link.fireRemoteClose();
                        break;
                    } else {
                        ProtonLinkImpl!ProtonSender lk = cast(ProtonLinkImpl!ProtonSender) protonEvent.getLink()
                            .getContext();
                        lk.fireRemoteClose();
                        break;
                    }
                    // link.fireRemoteClose();
                }
            case LINK_FLOW: {
                    ProtonLinkImpl!ProtonReceiver link = cast(ProtonLinkImpl!ProtonReceiver) protonEvent.getLink()
                        .getContext();
                    if (link !is null) {
                        link.handleLinkFlow();
                        break;
                    } else {
                        ProtonLinkImpl!ProtonSender lk = cast(ProtonLinkImpl!ProtonSender) protonEvent.getLink()
                            .getContext();
                        lk.handleLinkFlow();
                        break;
                    }
                    // ProtonLinkImpl<?> link = (ProtonLinkImpl<?>) protonEvent.getLink().getContext();
                    //link.handleLinkFlow();
                }
            case DELIVERY: {
                    ProtonDeliveryImpl delivery = cast(ProtonDeliveryImpl) protonEvent.getDelivery()
                        .getContext();
                    if (delivery !is null) {
                        delivery.fireUpdate();
                    } else {
                        ProtonReceiverImpl receiver = cast(ProtonReceiverImpl) protonEvent.getLink()
                            .getContext();
                        receiver.onDelivery();
                    }
                    break;
                }
            case TRANSPORT_ERROR: {
                    failed = true;
                    break;
                }

            case CONNECTION_INIT:
                break;
            case CONNECTION_BOUND:
                break;
            case CONNECTION_UNBOUND:
                break;
            case CONNECTION_LOCAL_OPEN:
                break;
            case CONNECTION_LOCAL_CLOSE:
                break;
            case CONNECTION_FINAL:
                break;
            case SESSION_INIT:
                break;
            case SESSION_LOCAL_OPEN:
                break;
            case SESSION_LOCAL_CLOSE:
                break;
            case SESSION_FINAL:
                break;
            case LINK_INIT:
                break;
            case LINK_LOCAL_OPEN:
                break;
            case LINK_LOCAL_DETACH:
                break;
            case LINK_LOCAL_CLOSE:
                break;
            case LINK_FINAL:
                break;
            default:
                break;
            }

            collector.pop();
        }

        if (!failed) {
            processSaslAuthentication();
        }

        flush();

        if (failed) {
            disconnect();
        }
    }

    private void processSaslAuthentication() {
        if (authenticator is null) {
            return;
        }

        // socket.pause();
        // dfmt off
        authenticator.process(new class Handler!bool {
            void handle(bool var1)
            {
                    if (var1)
                    {
                        authenticator = null;
                    }
            }
        });
        // dfmt on

        //  authenticator.process(complete -> {
        //    if(complete) {
        //      authenticator = null;
        //    }
        //
        //    socket.resume();
        //  });
    }

    private void initiateIdleTimeoutChecks() {
        executor = CommonUtil.scheduler();
        executor.setRemoveOnCancelPolicy(true);

        // dfmt off
        ScheduledFuture!(void) pingFuture = executor.scheduleWithFixedDelay(new class Runnable {
            void run() {
                bool checkScheduled = false;
                version(HUNT_AMQP_DEBUG) logInfo("beating ...");
                if (connection.getLocalState() == EndpointState.ACTIVE) {
                    // Using nano time since it is not related to the wall clock, which may change
                    long now = LocalDateTime.now().toEpochMilli();
                    long deadline = transport.tick(now);

                    flush();


                    if (transport.isClosed()) {
                        logError("IdleTimeoutCheck closed the transport due to the peer exceeding our requested idle-timeout.");
                        disconnect();
                    } else {
                        checkScheduled = true;
                        //if (deadline != 0) {
                        //  // timer treats 0 as error, ensure value is at least 1 as there was a deadline
                        //  long delay = Math.max(deadline - now, 1);
                        //  checkScheduled = true;
                        //  if (LOG.isTraceEnabled()) {
                        //    LOG.trace("IdleTimeoutCheck rescheduling with delay: " + delay);
                        //  }
                        //  idleTimeoutCheckTimerId = vertx.setTimer(delay, this);
                        //}
                    }
                } else {
                    version(HUNT_DEBUG) logInfo("IdleTimeoutCheck skipping check, connection is not active.");
                }
            }
        },
        msecs(20000),
        msecs(20000));

        // dfmt on

        //implementationMissing(false);
        // Using nano time since it is not related to the wall clock, which may change
        // long now = TimeUnit.NANOSECONDS.toMillis(System.nanoTime());
        // long now = DateTime.currentTimeNsecs();
        // long deadline = transport.tick(now);
        // if (deadline != 0)
        // {
        //   logError("!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
        // }
        //if (deadline != 0) {
        //  // timer treats 0 as error, ensure value is at least 1 as there was a deadline
        //  long delay = Math.max(deadline - now, 1);
        //  if (LOG.isTraceEnabled()) {
        //    LOG.trace("IdleTimeoutCheck being initiated, initial delay: " + delay);
        //  }
        //  idleTimeoutCheckTimerId = vertx.setTimer(delay, new IdleTimeoutCheck());
        //}
    }

    private void pumpInbound(ByteBuffer buffer) {
        if (failed) {
            logError("Skipping processing of data following transport error");
            return;
        }

        //ByteBuf data = buffer.getByteBuf();
        //do {
        //  ByteBuffer transportBuffer = transport.tail();
        //
        //  int amount = Math.min(transportBuffer.remaining(), data.readableBytes());
        //  transportBuffer.limit(transportBuffer.position() + amount);
        //  data.readBytes(transportBuffer);
        //
        //  transport.process();
        //} while (data.isReadable());

        // Lets push bytes from vert.x to proton engine.
        try {
            // ByteBuf data = buffer.getByteBuf();
            // WrappedByteBuf data = new WrappedByteBuf;
            // data.readBytes(buffer.getRemaining());

            ByteBuf data = Unpooled.wrappedBuffer(buffer);
            do {
                ByteBuffer transportBuffer = transport.tail();
                // writeln("%s",transportBuffer.array);
                int amount = min(transportBuffer.remaining(), data.readableBytes());
                transportBuffer.limit(transportBuffer.position() + amount);
                // byte[] tmb = new byte[transportBuffer.position() + amount];
                version (HUNT_AMQP_DEBUG) {
                    tracef("recv(%d bytes): [%(%02X %)]",
                            data.getReadableBytes.length, data.getReadableBytes);
                }
                data.readBytes(transportBuffer);

                // transportBuffer = BufferUtils.toBuffer(tmb);
                // logError("recevbef : %s",transportBuffer.toString());
                // transportBuffer.put(tmb);

                // logError("recevafter : %s",transportBuffer.toString());

                //transportBuffer.flip();
                // logError("recevafter flip : %s",transportBuffer.getRemaining());
                transport.process();
            }
            while (data.isReadable());
        } catch (Exception te) {
            failed = true;
            logError("Exception while processing transport input");
            //LOG.trace("Exception while processing transport input", te);
        }
    }

    void flush() {
        synchronized (this) {
            bool done = false;
            while (!done) {
                ByteBuffer outputBuffer = transport.getOutputBuffer();
                if (outputBuffer !is null && outputBuffer.hasRemaining()) {
                    //NetSocketInternal internal = (NetSocketInternal) socket;
                    //ByteBuf bb = internal.channelHandlerContext().alloc().directBuffer(outputBuffer.remaining());
                    // bb.writeBytes(outputBuffer);
                    //logError("send : %s --- %d" , outputBuffer.array(),outputBuffer.array().length);
                    version (HUNT_AMQP_DEBUG) {
                        logInfof("send(%d bytes): [%(%02X %)]",
                                outputBuffer.getRemaining.length, outputBuffer.getRemaining());
                    }
                    socket.write(outputBuffer);
                    // internal.writeMessage(bb);
                    transport.outputConsumed();
                } else {
                    done = true;
                }
            }
        }
    }

    public void disconnect() {
        if (netClient !is null) {
            netClient.close();
        } else {
            socket.close();
        }
    }

    //private  class IdleTimeoutCheck implements Handler<Long> {
    //  @Override
    //  public void handle(Long event) {
    //    boolean checkScheduled = false;
    //
    //    if (connection.getLocalState() == EndpointState.ACTIVE) {
    //      // Using nano time since it is not related to the wall clock, which may change
    //      long now = TimeUnit.NANOSECONDS.toMillis(System.nanoTime());
    //      long deadline = transport.tick(now);
    //
    //      flush();
    //
    //      if (transport.isClosed()) {
    //        LOG.info("IdleTimeoutCheck closed the transport due to the peer exceeding our requested idle-timeout.");
    //        disconnect();
    //      } else {
    //        if (deadline != 0) {
    //          // timer treats 0 as error, ensure value is at least 1 as there was a deadline
    //          long delay = Math.max(deadline - now, 1);
    //          checkScheduled = true;
    //          if (LOG.isTraceEnabled()) {
    //            LOG.trace("IdleTimeoutCheck rescheduling with delay: " + delay);
    //          }
    //          idleTimeoutCheckTimerId = vertx.setTimer(delay, this);
    //        }
    //      }
    //    } else {
    //      LOG.trace("IdleTimeoutCheck skipping check, connection is not active.");
    //    }
    //
    //    if (!checkScheduled) {
    //      idleTimeoutCheckTimerId = null;
    //      LOG.trace("IdleTimeoutCheck exiting");
    //    }
    //  }
    //}
}
