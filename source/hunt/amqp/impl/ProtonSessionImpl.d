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
module hunt.amqp.impl.ProtonSessionImpl;

import hunt.amqp.ProtonReceiver;
import hunt.amqp.ProtonSender;
import hunt.amqp.ProtonSession;
import hunt.amqp.ProtonConnection;
import hunt.amqp.ProtonHelper;
import hunt.amqp.ProtonQoS;
import hunt.amqp.ProtonLinkOptions;
import hunt.amqp.impl.ProtonConnectionImpl;
import hunt.amqp.impl.ProtonReceiverImpl;
import hunt.amqp.impl.ProtonSenderImpl;

import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.messaging.Accepted;
import hunt.proton.amqp.messaging.Modified;
import hunt.proton.amqp.messaging.Rejected;
import hunt.proton.amqp.messaging.Released;
import hunt.proton.amqp.messaging.Source;
import hunt.proton.amqp.messaging.Target;
import hunt.proton.amqp.transport.ErrorCondition;
import hunt.proton.engine.EndpointState;
import hunt.proton.engine.Receiver;
import hunt.proton.engine.Record;
import hunt.proton.engine.Sender;
import hunt.proton.engine.Session;
import hunt.Exceptions;
import hunt.String;
import hunt.collection.ArrayList;
import std.conv: to;
import hunt.Boolean;
import hunt.amqp.Handler;
import hunt.logging;
/**
 * @author <a href="http://hiramchirino.com">Hiram Chirino</a>
 */
class ProtonSessionImpl : ProtonSession {

  private  Session session;
  private int autoLinkCounter = 0;
  private Handler!ProtonSession _openHandler ;//= (result) -> {
  //  LOG.trace("Session open completed");
  //};
  private Handler!ProtonSession _closeHandler; // = (result) -> {
  //  if (result.succeeded()) {
  //    LOG.trace("Session closed");
  //  } else {
  //    LOG.warn("Session closed with error", result.cause());
  //  }
  //};

  this(Session session) {
    this.session = session;
    this.session.setContext(this);
    session.setIncomingCapacity(2147483647);
    _openHandler = new class Handler!ProtonSession
    {
      void handle(ProtonSession var1)
      {
          version(HUNT_DEBUG) logInfo("Session open completed");
      }
    };

    _closeHandler = new class Handler!ProtonSession
    {
      void handle(ProtonSession var1)
      {
        error("Session closed with error");
      }
    };

  }

  
  ProtonConnection getConnection() {
    return getConnectionImpl();
  }

  ProtonConnectionImpl getConnectionImpl() {
    return cast(ProtonConnectionImpl) (this.session.getConnection().getContext());
  }

  long getOutgoingWindow() {
    return session.getOutgoingWindow();
  }

  
  ProtonSession setIncomingCapacity(int bytes) {
    session.setIncomingCapacity(bytes);
    return this;
  }

  int getOutgoingBytes() {
    return session.getOutgoingBytes();
  }

  EndpointState getRemoteState() {
    return session.getRemoteState();
  }

  int getIncomingBytes() {
    return session.getIncomingBytes();
  }

  
  ErrorCondition getRemoteCondition() {
    return session.getRemoteCondition();
  }

  
  int getIncomingCapacity() {
    return session.getIncomingCapacity();
  }

  EndpointState getLocalState() {
    return session.getLocalState();
  }

  
  ProtonSession setCondition(ErrorCondition condition) {
    session.setCondition(condition);
    return this;
  }

  
  ErrorCondition getCondition() {
    return session.getCondition();
  }

  void setOutgoingWindow(long outgoingWindowSize) {
    session.setOutgoingWindow(outgoingWindowSize);
  }

  
  ProtonSessionImpl open() {
    session.open();
    version(HUNT_AMQP_DEBUG) logInfo("session open");
    getConnectionImpl().flush();
    return this;
  }

  
  ProtonSessionImpl close() {
    version(HUNT_AMQP_DEBUG) logInfo("session close");
    session.close();
    getConnectionImpl().flush();
    return this;
  }

  
  ProtonSessionImpl openHandler(Handler!ProtonSession openHandler) {
    this._openHandler = openHandler;
    return this;
  }


  ProtonSessionImpl closeHandler(Handler!ProtonSession closeHandler) {
    this._closeHandler = closeHandler;
    return this;
  }

  private string generateLinkName() {
    // TODO: include useful details in name, like address and container?
    return "auto-" ~ to!string((autoLinkCounter++));
  }

  private string getOrCreateLinkName(ProtonLinkOptions linkOptions) {
    return linkOptions.getLinkName() is null ? generateLinkName() : linkOptions.getLinkName();
  }

  
  ProtonReceiver createReceiver(string address) {
    return createReceiver(address, new ProtonLinkOptions());
  }

  
  ProtonReceiver createReceiver(string address, ProtonLinkOptions receiverOptions) {
    Receiver receiver = session.receiver(getOrCreateLinkName(receiverOptions));

    Symbol[] outcomes = [ Accepted.DESCRIPTOR_SYMBOL, Rejected.DESCRIPTOR_SYMBOL,
        Released.DESCRIPTOR_SYMBOL, Modified.DESCRIPTOR_SYMBOL ];

    Source source = new Source();
    source.setAddress(new String(address));
    //source.setOutcomes(new ArrayList!Symbol(outcomes));
    source.setDefaultOutcome(Released.getInstance());
    if(receiverOptions.isDynamic()) {
      source.setDynamic(new Boolean(true));
    }

    Target target = new Target();

    receiver.setSource(source);
    receiver.setTarget(target);

    ProtonReceiverImpl r = new ProtonReceiverImpl(receiver);
    //r.openHandler((result) -> {
    //  LOG.trace("Receiver open completed");
    //});
    //r.closeHandler((result) -> {
    //  if (result.succeeded()) {
    //    LOG.trace("Receiver closed");
    //  } else {
    //    LOG.warn("Receiver closed with error", result.cause());
    //  }
    //});

    // Default to at-least-once
    r.setQoS(ProtonQoS.AT_LEAST_ONCE);

    return r;
  }

  
  ProtonSender createSender(string address) {
    return createSender(address, new ProtonLinkOptions());
  }

  
  ProtonSender createSender(string address, ProtonLinkOptions senderOptions) {
    Sender sender = session.sender(getOrCreateLinkName(senderOptions));

    Symbol[] outcomes = [ Accepted.DESCRIPTOR_SYMBOL, Rejected.DESCRIPTOR_SYMBOL,
        Released.DESCRIPTOR_SYMBOL, Modified.DESCRIPTOR_SYMBOL ];
    Source source = new Source();
    //source.setOutcomes(new ArrayList!Symbol(outcomes));

    Target target = new Target();
    target.setAddress(address is null ? null : new String(address));
    if(senderOptions.isDynamic()) {
      target.setDynamic(new Boolean(true));
    }

    sender.setSource(source);
    sender.setTarget(target);

    ProtonSenderImpl s = new ProtonSenderImpl(sender);
    if (address is null) {
      s.setAnonymousSender(true);
    }

    //s.openHandler((result) -> {
    //  LOG.trace("Sender open completed");
    //});
    //s.closeHandler((result) -> {
    //  if (result.succeeded()) {
    //    LOG.trace("Sender closed");
    //  } else {
    //    LOG.warn("Sender closed with error", result.cause());
    //  }
    //});

    // Default to at-least-once
    s.setQoS(ProtonQoS.AT_LEAST_ONCE);

    return s;
  }

  
  Record attachments() {
    return session.attachments();
  }

  
  void free() {
    session.free();
    getConnectionImpl().flush();
  }

  /////////////////////////////////////////////////////////////////////////////
  //
  // Implementation details hidden from api.
  //
  /////////////////////////////////////////////////////////////////////////////
  void fireRemoteOpen() {
    //implementationMissing(false);
    if (_openHandler !is null)
    {
      _openHandler.handle(null);
    }
  }

  void fireRemoteClose() {
    //implementationMissing(false);
    if (_closeHandler !is null) {
      _closeHandler.handle(null);
    }
  }

}
