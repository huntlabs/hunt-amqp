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

import hunt.Exceptions;
import hunt.amqp.ProtonConnection;
import hunt.amqp.ProtonHelper;
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
import hunt.collection.LinkedHashMap;
import hunt.collection.List;
import hunt.collection.Map;
import hunt.net.NetClient;


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

    // static  Symbol ANONYMOUS_RELAY = Symbol.valueOf("ANONYMOUS-RELAY");

    static Symbol ANONYMOUS_RELAY() {
        __gshared Symbol inst;
        return initOnce!inst(Symbol.valueOf("ANONYMOUS-RELAY"));
    }

    private hunt.proton.engine.Connection.Connection connection; //= Proton.connection();
    private ProtonTransport transport;
    private Handler!(Void)[] endHandlers;

    private Handler!ProtonConnection _openHandler; //= (result) -> {
    //  LOG.trace("Connection open completed");
    //};
    private AsyncResultHandler!ProtonConnection _closeHandler;

    private AmqpEventHandler!ProtonConnection _disconnectHandler; 
    //
    private AmqpEventHandler!ProtonSession _sessionOpenHandler;

    private Handler!ProtonSender _senderOpenHandler; //= (sender) -> {
    //  sender.setCondition(new ErrorCondition(Symbol.getSymbol("Not Supported"), ""));
    //};
    private Handler!ProtonReceiver _receiverOpenHandler; //= (receiver) -> {
    //  receiver.setCondition(new ErrorCondition(Symbol.getSymbol("Not Supported"), ""));
    //};
    private bool anonymousRelaySupported;
    private ProtonSession defaultSession;
    private hunt.net.Connection.Connection _conn;

    this(string hostname, hunt.net.Connection.Connection conn) {
        _closeHandler = (result) {
            if (result.succeeded()) {
                trace("Connection closed");
            } else {
                warning("Connection closed with error", result.cause());
            }
        };

        _disconnectHandler = (connection) {
            trace("Connection disconnected");
        };

        _sessionOpenHandler = (session) {
            session.setCondition(new ErrorCondition(Symbol.getSymbol("Not Supported"), new String("")));
        };

        this.connection = Proton.connection();
        this.connection.setContext(this);
        string tmp = "vert.x-";
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

    ProtonConnectionImpl setProperties(Map!(Symbol, Object) properties) {
        Map!(Symbol, Object) newProps = null;
        if (properties !is null) {
            newProps = createInitialPropertiesMap();
            newProps.putAll(properties);
        }

        connection.setProperties(newProps);
        return this;
    }

    ProtonConnectionImpl setOfferedCapabilities(Symbol[] capabilities) {
        connection.setOfferedCapabilities(capabilities);
        return this;
    }

    ProtonConnectionImpl setHostname(string hostname) {
        connection.setHostname(hostname);
        return this;
    }

    ProtonConnectionImpl setDesiredCapabilities(Symbol[] capabilities) {
        connection.setDesiredCapabilities(capabilities);
        return this;
    }

    ProtonConnectionImpl setContainer(string container) {
        connection.setContainer(container);
        return this;
    }

    ProtonConnectionImpl setCondition(ErrorCondition condition) {
        connection.setCondition(condition);
        return this;
    }

    ErrorCondition getCondition() {
        return connection.getCondition();
    }

    string getContainer() {
        return connection.getContainer();
    }

    string getHostname() {
        return connection.getHostname();
    }

    EndpointState getLocalState() {
        return connection.getLocalState();
    }

    ErrorCondition getRemoteCondition() {
        return connection.getRemoteCondition();
    }

    string getRemoteContainer() {
        return connection.getRemoteContainer();
    }

    Symbol[] getRemoteDesiredCapabilities() {
        return connection.getRemoteDesiredCapabilities();
    }

    string getRemoteHostname() {
        return connection.getRemoteHostname();
    }

    Symbol[] getRemoteOfferedCapabilities() {
        return connection.getRemoteOfferedCapabilities();
    }

    Map!(Symbol, Object) getRemoteProperties() {
        return connection.getRemoteProperties();
    }

    EndpointState getRemoteState() {
        return connection.getRemoteState();
    }

    bool isAnonymousRelaySupported() {
        return anonymousRelaySupported;
    }

    Record attachments() {
        return connection.attachments();
    }

    /////////////////////////////////////////////////////////////////////////////
    //
    // Handle/Trigger connection level state changes
    //
    /////////////////////////////////////////////////////////////////////////////

    ProtonConnection open() {
        version (HUNT_AMQP_DEBUG)
            logInfo("open-------");
        connection.open();
        flush();
        return this;
    }

    ProtonConnection close() {
        connection.close();
        flush();
        return this;
    }

    ProtonSessionImpl createSession() {
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

    ProtonSender createSender(string address) {
        return getDefaultSession().createSender((address));
    }

    ProtonSender createSender(string address, ProtonLinkOptions senderOptions) {
        return getDefaultSession().createSender((address), senderOptions);
    }

    ProtonReceiver createReceiver(string address) {
        return getDefaultSession().createReceiver((address));
    }

    ProtonReceiver createReceiver(string address, ProtonLinkOptions receiverOptions) {
        return getDefaultSession().createReceiver((address), receiverOptions);
    }

    void flush() {
        if (transport !is null) {
            version (HUNT_AMQP_DEBUG)
                logInfo("transport flush");
            transport.flush();
        }
    }

    void disconnect() {
        if (transport !is null) {
            transport.disconnect();
        }
    }

    bool isDisconnected() {
        return transport is null;
    }

    ProtonConnection openHandler(Handler!ProtonConnection openHandler) {
        //implementationMissing(false);
        this._openHandler = openHandler;
        return this;
    }

    ProtonConnection closeHandler(AsyncResultHandler!ProtonConnection closeHandler) {
        this._closeHandler = closeHandler;
        return this;
    }

    ProtonConnection disconnectHandler(AmqpEventHandler!ProtonConnection disconnectHandler) {
        this._disconnectHandler = disconnectHandler;
        return this;
    }

    ProtonConnection sessionOpenHandler(AmqpEventHandler!ProtonSession remoteSessionOpenHandler) {
        this._sessionOpenHandler = remoteSessionOpenHandler;
        return this;
    }

    ProtonConnection senderOpenHandler(Handler!ProtonSender remoteSenderOpenHandler) {
        //implementationMissing(false);
        this._senderOpenHandler = remoteSenderOpenHandler;
        return this;
    }

    ProtonConnection receiverOpenHandler(Handler!ProtonReceiver remoteReceiverOpenHandler) {
        //implementationMissing(false);
        this._receiverOpenHandler = remoteReceiverOpenHandler;
        return this;
    }

    /////////////////////////////////////////////////////////////////////////////
    //
    // Implementation details hidden from api.
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
        version(HUNT_DEBUG) info("Remote closed");
        if (_closeHandler !is null) {
            _closeHandler(ProtonHelper.future!(ProtonConnection)(this, getRemoteCondition()));
        }
    }

    void fireDisconnect() {
        version(HUNT_DEBUG) info("Disconnecting...");
        transport = null;
        if (_disconnectHandler !is null) {
            _disconnectHandler(this);
        }

        foreach(Handler!Void handler; endHandlers) {
            handler.handle(null);
        }

        endHandlers = null;
    }

    void bindClient(NetClient client, ProtonSaslClientAuthenticatorImpl authenticator,
            ProtonTransportOptions transportOptions) {
        transport = new ProtonTransport(connection, client, _conn,
                authenticator, transportOptions);
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
        if (cast(Sender) link !is null) {
            if (_senderOpenHandler !is null) {
                _senderOpenHandler.handle(new ProtonSenderImpl(cast(Sender) link));
            }
        } else {
            if (_receiverOpenHandler !is null) {
                _receiverOpenHandler.handle(new ProtonReceiverImpl(cast(Receiver) link));
            }
        }
    }

    void addEndHandler(Handler!Void handler) {
        endHandlers ~= handler;
    }

    hunt.net.Connection.Connection getContext() {
        return _conn;
    }
}
