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
module hunt.amqp.impl.ProtonConnectionImpl;

//import io.vertx.core.AsyncResult;
//import io.vertx.core.Future;
//import io.vertx.core.Handler;
//import io.vertx.core.Vertx;
//import io.vertx.core.impl.ContextInternal;
//import io.vertx.core.impl.logging.Logger;
//import io.vertx.core.impl.logging.LoggerFactory;
//import io.vertx.core.net.NetClient;
//import io.vertx.core.net.NetSocket;
import hunt.Exceptions;
import hunt.amqp.ProtonConnection;
import hunt.amqp.ProtonLinkOptions;
import hunt.amqp.ProtonReceiver;
import hunt.amqp.ProtonSender;
import hunt.amqp.ProtonSession;
import hunt.amqp.ProtonTransportOptions;
import hunt.amqp.sasl.ProtonSaslAuthenticator;

import hunt.logging;
import hunt.proton.Proton;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.transport.ErrorCondition;
import hunt.proton.engine.Connection;
import hunt.proton.engine.EndpointState;
import hunt.proton.engine.Link;
import hunt.proton.engine.Receiver;
import hunt.proton.engine.Record;
import hunt.proton.engine.Sender;
import hunt.proton.engine.Session;
import hunt.amqp.impl.ProtonSenderImpl;
import hunt.amqp.impl.ProtonReceiverImpl;

import hunt.collection.ArrayList;
//import java.util.Arrays;
//import java.util.Iterator;
import hunt.collection.LinkedHashMap;
import hunt.collection.List;
import hunt.collection.Map;
import hunt.net.NetClient;
//import java.util.UUID;

//import hunt.amqp.ProtonHelper.future;
import hunt.amqp.impl.ProtonTransport;
import hunt.amqp.Handler;
import std.concurrency : initOnce;
import std.uuid;
import std.random;
import hunt.amqp.impl.ProtonMetaDataSupportImpl;
import hunt.amqp.impl.ProtonSessionImpl;
import hunt.net.Connection;
import hunt.amqp.impl.ProtonSaslClientAuthenticatorImpl;
import hunt.Object;
import hunt.String;
/**
 * @author <a href="http://tfox.org">Tim Fox</a>
 * @author <a href="http://hiramchirino.com">Hiram Chirino</a>
 */
class ProtonConnectionImpl : ProtonConnection {

 // public static  Symbol ANONYMOUS_RELAY = Symbol.valueOf("ANONYMOUS-RELAY");

  static Symbol  ANONYMOUS_RELAY() {
    __gshared Symbol  inst;
    return initOnce!inst(Symbol.valueOf("ANONYMOUS-RELAY"));
  }


  private  hunt.proton.engine.Connection.Connection connection ;//= Proton.connection();
//  private  ContextInternal connCtx;
  private ProtonTransport transport;
//  private List<Handler<Void>> endHandlers = new ArrayList<>();

  private Handler!ProtonConnection _openHandler ; //= (result) -> {
  //  LOG.trace("Connection open completed");
  //};
  private Handler!ProtonConnection _closeHandler ;//= (result) -> {
  //  if (result.succeeded()) {
  //    LOG.trace("Connection closed");
  //  } else {
  //    LOG.warn("Connection closed with error", result.cause());
  //  }
  //};
  private Handler!ProtonConnection _disconnectHandler;// = (connection) -> {
  //  LOG.trace("Connection disconnected");
  //};
  //
  //private Handler<ProtonSession> sessionOpenHandler = (session) -> {
  //  session.setCondition(new ErrorCondition(Symbol.getSymbol("Not Supported"), ""));
  //};
  private Handler!ProtonSender _senderOpenHandler ;//= (sender) -> {
  //  sender.setCondition(new ErrorCondition(Symbol.getSymbol("Not Supported"), ""));
  //};
  private Handler!ProtonReceiver _receiverOpenHandler ;//= (receiver) -> {
  //  receiver.setCondition(new ErrorCondition(Symbol.getSymbol("Not Supported"), ""));
  //};
  private bool anonymousRelaySupported;
  private ProtonSession defaultSession;
  private hunt.net.Connection.Connection _conn;

    this(string hostname ,hunt.net.Connection.Connection conn) {
      this.connection = Proton.connection();
      this.connection.setContext(this);
      string  tmp =  "vert.x-";
      tmp ~= randomUUID().toString();
      this.connection.setContainer(tmp);
      this.connection.setHostname(hostname);
      this._conn = conn;
      Map!(Symbol, Object) props = createInitialPropertiesMap();
      connection.setProperties(props);
  }

  private Map!(Symbol, Object) createInitialPropertiesMap() {
    Map!(Symbol, Object) props = new LinkedHashMap!(Symbol, Object)();
    props.put(ProtonMetaDataSupportImpl.PRODUCT_KEY, new String("vertx-proton"));
    props.put(ProtonMetaDataSupportImpl.VERSION_KEY, new String("version"));
    return props;
  }

  /////////////////////////////////////////////////////////////////////////////
  //
  // Delegated state tracking
  //
  /////////////////////////////////////////////////////////////////////////////

  public ProtonConnectionImpl setProperties( Map!(Symbol, Object) properties) {
    Map!(Symbol, Object) newProps = null;
    if (properties !is null) {
      newProps = createInitialPropertiesMap();
      newProps.putAll(properties);
    }

    connection.setProperties(newProps);
    return this;
  }

  public ProtonConnectionImpl setOfferedCapabilities(Symbol[] capabilities) {
    connection.setOfferedCapabilities(capabilities);
    return this;
  }


  public ProtonConnectionImpl setHostname(string hostname) {
    connection.setHostname(hostname);
    return this;
  }


  public ProtonConnectionImpl setDesiredCapabilities(Symbol[] capabilities) {
    connection.setDesiredCapabilities(capabilities);
    return this;
  }


  public ProtonConnectionImpl setContainer(string container) {
    connection.setContainer(container);
    return this;
  }


  public ProtonConnectionImpl setCondition(ErrorCondition condition) {
    connection.setCondition(condition);
    return this;
  }


  public ErrorCondition getCondition() {
    return connection.getCondition();
  }


  public string getContainer() {
    return connection.getContainer();
  }


  public string getHostname() {
    return connection.getHostname();
  }

  public EndpointState getLocalState() {
    return connection.getLocalState();
  }


  public ErrorCondition getRemoteCondition() {
    return connection.getRemoteCondition();
  }


  public string getRemoteContainer() {
    return connection.getRemoteContainer();
  }


  public Symbol[] getRemoteDesiredCapabilities() {
    return connection.getRemoteDesiredCapabilities();
  }


  public string getRemoteHostname() {
    return connection.getRemoteHostname();
  }


  public Symbol[] getRemoteOfferedCapabilities() {
    return connection.getRemoteOfferedCapabilities();
  }


  public Map!(Symbol, Object) getRemoteProperties() {
    return connection.getRemoteProperties();
  }

  public EndpointState getRemoteState() {
    return connection.getRemoteState();
  }


  public bool isAnonymousRelaySupported() {
    return anonymousRelaySupported;
  };


  public Record attachments() {
    return connection.attachments();
  }

  /////////////////////////////////////////////////////////////////////////////
  //
  // Handle/Trigger connection level state changes
  //
  /////////////////////////////////////////////////////////////////////////////


  public ProtonConnection open() {
    logInfo("open -------------------------------------------");
    connection.open();
    flush();
    return this;
  }


  public ProtonConnection close() {
    connection.close();
    flush();
    return this;
  }


  public ProtonSessionImpl createSession() {
    return new ProtonSessionImpl(connection.session());
  }

  private ProtonSession getDefaultSession() {
    if (defaultSession is null) {
      defaultSession = createSession();
      //defaultSession.closeHandler(result -> {
      //  string msg = "The connections default session closed unexpectedly";
      //  if (!result.succeeded()) {
      //    msg += ": ";
      //    msg += ": " + string.valueOf(result.cause());
      //  }
      //  Future<ProtonConnection> failure = Future.failedFuture(msg);
      //  Handler<AsyncResult<ProtonConnection>> connCloseHandler = closeHandler;
      //  if (connCloseHandler !is null) {
      //    connCloseHandler.handle(failure);
      //  }
      //});

      //defaultSession.closeHandler ( new class Handler!ProtonSession {
      //  void handle(ProtonSession var1)
      //      {
      //        string msg = "The connections default session closed unexpectedly";
      //          if (closeHandler !is null) {
      //            closeHandler.handle();
      //          }
      //      }
      //  } );

      defaultSession.open();
      // Deliberately not flushing, the sender/receiver open
      // call will do that (if it doesn't happen otherwise).
    }
    return defaultSession;
  }


  public ProtonSender createSender(string address) {
    return getDefaultSession().createSender((address));
  }


  public ProtonSender createSender(string address, ProtonLinkOptions senderOptions) {
      return getDefaultSession().createSender((address), senderOptions);
  }


  public ProtonReceiver createReceiver(string address) {
    return getDefaultSession().createReceiver((address));
  }


  public ProtonReceiver createReceiver(string address, ProtonLinkOptions receiverOptions) {
      return getDefaultSession().createReceiver((address), receiverOptions);
  }

  public void flush() {
    if (transport !is null) {
      logInfo("transport flush ------------------------------------");
      transport.flush();
    }
  }


  public void disconnect() {
    if (transport !is null) {
      transport.disconnect();
    }
  }


  public bool isDisconnected() {
    return transport is null;
  }


  public ProtonConnection openHandler(Handler!ProtonConnection openHandler) {
    //implementationMissing(false);
    this._openHandler = openHandler;
    return this;
  }


  public ProtonConnection closeHandler(Handler!ProtonConnection closeHandler) {
   // implementationMissing(false);
    this._closeHandler = closeHandler;
    return this;
  }


  public ProtonConnection disconnectHandler(Handler!ProtonConnection disconnectHandler) {
   // implementationMissing(false);
    this._disconnectHandler = disconnectHandler;
    return this;
  }


  public ProtonConnection sessionOpenHandler(Handler!ProtonSession remoteSessionOpenHandler) {
    implementationMissing(false);
    //this.sessionOpenHandler = remoteSessionOpenHandler;
    return this;
  }


  public ProtonConnection senderOpenHandler(Handler!ProtonSender remoteSenderOpenHandler) {
    //implementationMissing(false);
    this._senderOpenHandler = remoteSenderOpenHandler;
    return this;
  }


  public ProtonConnection receiverOpenHandler(Handler!ProtonReceiver remoteReceiverOpenHandler) {
    //implementationMissing(false);
    this._receiverOpenHandler = remoteReceiverOpenHandler;
    return this;
  }

  /////////////////////////////////////////////////////////////////////////////
  //
  // Implementation details hidden from public api.
  //
  /////////////////////////////////////////////////////////////////////////////

  private void processCapabilities() {
    Symbol[] capabilities = getRemoteOfferedCapabilities();
    anonymousRelaySupported = true;
    if (capabilities.length != 0) {
      List!Symbol list = new ArrayList!Symbol(capabilities);
      if (list.contains(ANONYMOUS_RELAY)) {
        anonymousRelaySupported = true;
      }
    }
  }

  void fireRemoteOpen() {
    processCapabilities();

    if (_openHandler !is null) {
      _openHandler.handle(this);
    }
  }

  void fireRemoteClose() {
    implementationMissing(false);
    //if (closeHandler !is null) {
    //  closeHandler.handle(future(this, getRemoteCondition()));
    //}
  }

  public void fireDisconnect() {
    implementationMissing(false);
    //transport = null;
    //if (disconnectHandler !is null) {
    //  disconnectHandler.handle(this);
    //}
    //
    //Iterator<Handler<Void>> iter = endHandlers.iterator();
    //while(iter.hasNext()) {
    //  Handler<Void> h = iter.next();
    //  iter.remove();
    //  h.handle(null);
    //}
  }

  void bindClient(NetClient client ,ProtonSaslClientAuthenticatorImpl authenticator, ProtonTransportOptions transportOptions) {
    transport = new ProtonTransport(connection, client, _conn, authenticator, transportOptions);
  }

  //void bindServer(NetSocket socket, ProtonSaslAuthenticator authenticator, ProtonTransportOptions transportOptions) {
  //  transport = new ProtonTransport(connection, vertx, null, socket, authenticator, transportOptions);
  //}

  void fireRemoteSessionOpen(hunt.proton.engine.Session.Session session) {
    implementationMissing(false);
    //if (sessionOpenHandler !is null) {
    //  sessionOpenHandler.handle(new ProtonSessionImpl(session));
    //}
  }

  void fireRemoteLinkOpen(Link link) {
    if (cast(Sender)link !is null) {
      if (_senderOpenHandler !is null) {
        _senderOpenHandler.handle(new ProtonSenderImpl(cast(Sender) link));
      }
    } else {
      if (_receiverOpenHandler !is null) {
        _receiverOpenHandler.handle(new ProtonReceiverImpl(cast(Receiver) link));
      }
    }
  }

  public void addEndHandler(Handler!Void handler) {
    implementationMissing(false);
   // endHandlers.add(handler);
  }

  public hunt.net.Connection.Connection getContext() {
    return _conn;
  }
}
