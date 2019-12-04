/*
 * hunt-amqp: AMQP library for D programming language, based on hunt-net.
 *
 * Copyright (C) 2018-2019 HuntLabs
 *
 * Website: https://www.huntlabs.net
 *
 * Licensed under the Apache-2.0 License.
 *
 */
module hunt.amqp.impl.ProtonServerImpl;

//import io.vertx.core.AsyncResult;
//import io.vertx.core.Context;
//import io.vertx.core.Future;
//import io.vertx.core.Handler;
//import io.vertx.core.Vertx;
//import io.vertx.core.impl.ContextInternal;
//import io.vertx.core.net.NetServer;
//import io.vertx.core.net.NetSocket;
//import hunt.amqp.ProtonConnection;
//import hunt.amqp.ProtonServer;
//import hunt.amqp.ProtonServerOptions;
//import hunt.amqp.ProtonTransportOptions;
//import hunt.amqp.sasl.ProtonSaslAuthenticator;
//import hunt.amqp.sasl.ProtonSaslAuthenticatorFactory;
//import hunt.proton.amqp.Symbol;
//import hunt.proton.engine.Transport;
//
//import java.net.InetAddress;
//import java.net.UnknownHostException;
//
///**
// * @author <a href="http://hiramchirino.com">Hiram Chirino</a>
// */
//class ProtonServerImpl implements ProtonServer {
//
//  private final Vertx vertx;
//  private final NetServer server;
//  private Handler<ProtonConnection> handler;
//  // default authenticator, anonymous
//  private ProtonSaslAuthenticatorFactory authenticatorFactory = new DefaultAuthenticatorFactory();
//  private boolean advertiseAnonymousRelayCapability = true;
//
//  private ProtonServerOptions options;
//
//  public ProtonServerImpl(Vertx vertx) {
//    this.vertx = vertx;
//    this.server = this.vertx.createNetServer();
//
//    this.options = new ProtonServerOptions();
//  }
//
//  public ProtonServerImpl(Vertx vertx, ProtonServerOptions options) {
//    this.vertx = vertx;
//    this.server = this.vertx.createNetServer(options);
//
//    this.options = options;
//  }
//
//  @Override
//  public int actualPort() {
//    return server.actualPort();
//  }
//
//  @Override
//  public ProtonServerImpl listen(int i) {
//    server.listen(i);
//    return this;
//  }
//
//  @Override
//  public ProtonServerImpl listen() {
//    server.listen();
//    return this;
//  }
//
//  public boolean isMetricsEnabled() {
//    return server.isMetricsEnabled();
//  }
//
//  @Override
//  public ProtonServerImpl listen(int port, String host, Handler<AsyncResult<ProtonServer>> handler) {
//    server.listen(port, host, convertHandler(handler));
//    return this;
//  }
//
//  @Override
//  public ProtonServerImpl listen(Handler<AsyncResult<ProtonServer>> handler) {
//    server.listen(convertHandler(handler));
//    return this;
//  }
//
//  private Handler<AsyncResult<NetServer>> convertHandler(final Handler<AsyncResult<ProtonServer>> handler) {
//    return result -> {
//      if (result.succeeded()) {
//        handler.handle(Future.succeededFuture(ProtonServerImpl.this));
//      } else {
//        handler.handle(Future.failedFuture(result.cause()));
//      }
//    };
//  }
//
//  @Override
//  public ProtonServerImpl listen(int i, String s) {
//    server.listen(i, s);
//    return this;
//  }
//
//  @Override
//  public ProtonServerImpl listen(int i, Handler<AsyncResult<ProtonServer>> handler) {
//    server.listen(i, convertHandler(handler));
//    return this;
//  }
//
//  @Override
//  public void close() {
//    server.close();
//  }
//
//  @Override
//  public void close(Handler<AsyncResult<Void>> handler) {
//    server.close(handler);
//  }
//
//  @Override
//  public Handler<ProtonConnection> connectHandler() {
//    return handler;
//  }
//
//  @Override
//  public ProtonServer saslAuthenticatorFactory(ProtonSaslAuthenticatorFactory authenticatorFactory) {
//    if (authenticatorFactory is null) {
//      // restore the default
//      this.authenticatorFactory = new DefaultAuthenticatorFactory();
//    } else {
//      this.authenticatorFactory = authenticatorFactory;
//    }
//    return this;
//  }
//
//  @Override
//  public ProtonServerImpl connectHandler(Handler<ProtonConnection> handler) {
//    this.handler = handler;
//    server.connectHandler(netSocket -> {
//      String hostname = null;
//      try {
//        hostname = InetAddress.getLocalHost().getHostName();
//      } catch (UnknownHostException e) {
//        // ignore
//      }
//
//      final ProtonConnectionImpl connection = new ProtonConnectionImpl(vertx, hostname, (ContextInternal) Vertx.currentContext());
//      if (advertiseAnonymousRelayCapability) {
//        connection.setOfferedCapabilities(new Symbol[] { ProtonConnectionImpl.ANONYMOUS_RELAY });
//      }
//
//      final ProtonSaslAuthenticator authenticator = authenticatorFactory.create();
//
//      ProtonTransportOptions transportOptions = new ProtonTransportOptions();
//      transportOptions.setHeartbeat(this.options.getHeartbeat());
//      transportOptions.setMaxFrameSize(this.options.getMaxFrameSize());
//
//      connection.bindServer(netSocket, new ProtonSaslAuthenticator() {
//
//        @Override
//        public void init(NetSocket socket, ProtonConnection protonConnection, Transport transport) {
//          authenticator.init(socket, protonConnection, transport);
//        }
//
//        @Override
//        public void process(Handler<Boolean> completionHandler) {
//          final Context context = Vertx.currentContext();
//
//          authenticator.process(complete -> {
//            final Context callbackContext = vertx.getOrCreateContext();
//            if(context != callbackContext) {
//              throw new IllegalStateException("Callback was not made on the original context");
//            }
//
//            if (complete) {
//              // The authenticator completed, now check success, do required post processing
//              if (succeeded()) {
//                handler.handle(connection);
//                connection.flush();
//              } else {
//                // auth failed, flush any pending data and disconnect client
//                connection.flush();
//                connection.disconnect();
//              }
//            }
//
//            completionHandler.handle(complete);
//          });
//        }
//
//        @Override
//        public boolean succeeded() {
//          return authenticator.succeeded();
//        }
//
//      }, transportOptions);
//    });
//    return this;
//  }
//
//  public void setAdvertiseAnonymousRelayCapability(boolean advertiseAnonymousRelayCapability) {
//    this.advertiseAnonymousRelayCapability = advertiseAnonymousRelayCapability;
//  }
//
//  private static class DefaultAuthenticatorFactory implements ProtonSaslAuthenticatorFactory {
//    @Override
//    public ProtonSaslAuthenticator create() {
//      return new ProtonSaslServerAuthenticatorImpl();
//    }
//  }
//}
