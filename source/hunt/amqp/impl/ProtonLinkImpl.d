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
module hunt.amqp.impl.ProtonLinkImpl;

//import io.vertx.core.AsyncResult;
//import io.vertx.core.Handler;
import hunt.amqp.ProtonHelper;
import hunt.amqp.ProtonLink;
import hunt.amqp.ProtonQoS;

import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.transport.ErrorCondition;
import hunt.proton.amqp.transport.ReceiverSettleMode;
import hunt.proton.amqp.transport.SenderSettleMode;
import hunt.proton.amqp.transport.Source;
import hunt.proton.amqp.transport.Target;
import hunt.proton.engine.Delivery;
import hunt.proton.engine.EndpointState;
import hunt.proton.engine.Link;
import hunt.proton.engine.Record;
import hunt.collection.Map;
import hunt.amqp.Handler;
import hunt.amqp.impl.ProtonSessionImpl;
import hunt.Exceptions;
import hunt.logging;
/**
 * @author <a href="http://hiramchirino.com">Hiram Chirino</a>
 */
abstract class ProtonLinkImpl(T) : ProtonLink!T {

  protected  Link link;
  private Handler!T _openHandler;
  private Handler!T _closeHandler;
  private Handler!T _detachHandler;

  this(Link link) {
    this.link = link;
    this.link.setContext(this);

    setQoS(getRemoteQoS());
  }

  public abstract T self();

  public ProtonSessionImpl getSession() {
    return cast(ProtonSessionImpl) (this.link.getSession().getContext());
  }

  public Record attachments() {
    return link.attachments();
  }

  public ErrorCondition getCondition() {
    return link.getCondition();
  }

  public int getCredit() {
    return link.getCredit();
  }

  public bool getDrain() {
    return link.getDrain();
  }

  public EndpointState getLocalState() {
    return link.getLocalState();
  }

  public string getName() {
    return link.getName();
  }

  public ErrorCondition getRemoteCondition() {
    return link.getRemoteCondition();
  }

  public int getRemoteCredit() {
    return link.getRemoteCredit();
  }

  public EndpointState getRemoteState() {
    return link.getRemoteState();
  }

  public Target getRemoteTarget() {
    return link.getRemoteTarget();
  }

  public Target getTarget() {
    return link.getTarget();
  }

  public T setTarget(Target target) {
    link.setTarget(target);
    return self();
  }

  public Source getRemoteSource() {
    return link.getRemoteSource();
  }

  public Source getSource() {
    return link.getSource();
  }

  public T setSource(Source source) {
    link.setSource(source);
    return self();
  }

  public int getUnsettled() {
    return link.getUnsettled();
  }

  public int getQueued() {
    return link.getQueued();
  }

  public bool advance() {
    return link.advance();
  }

  public int drained() {
    int drained = link.drained();
    getSession().getConnectionImpl().flush();
    return drained;
  }

  public bool detached() {
    return link.detached();
  }

  public Delivery delivery(byte[] tag, int offset, int length) {
    return link.delivery(tag, offset, length);
  }

  public Delivery current() {
    return link.current();
  }

  public T setCondition(ErrorCondition condition) {
    link.setCondition(condition);
    return self();
  }

  public Delivery delivery(byte[] tag) {
    return link.delivery(tag);
  }

  public T open() {
    link.open();
    logInfo("link open flush --------------------------------------------------");
    getSession().getConnectionImpl().flush();
    return self();
  }

  public T close() {
    link.close();
    getSession().getConnectionImpl().flush();
    return self();
  }

  public T detach() {
    link.detach();
    getSession().getConnectionImpl().flush();
    return self();
  }

  public T openHandler(Handler!T openHandler) {
    this._openHandler = openHandler;
    return self();
  }

  public T closeHandler(Handler!T closeHandler) {
    this._closeHandler = closeHandler;
    return self();
  }

  public T detachHandler(Handler!T detachHandler) {
    this._detachHandler = detachHandler;
    return self();
  }

  public bool isOpen() {
    return getLocalState() == EndpointState.ACTIVE;
  }

  public ProtonQoS getQoS() {
    if (link.getSenderSettleMode() == SenderSettleMode.SETTLED) {
      return ProtonQoS.AT_MOST_ONCE;
    }

    return ProtonQoS.AT_LEAST_ONCE;
  }

  public ProtonQoS getRemoteQoS() {
    if (link.getRemoteSenderSettleMode() == SenderSettleMode.SETTLED) {
      return ProtonQoS.AT_MOST_ONCE;
    }

    return ProtonQoS.AT_LEAST_ONCE;
  }

  public T setQoS(ProtonQoS qos) {
    int type = qos.ordinal();
    const int AT_MOST_ONCE = ProtonQoS.AT_MOST_ONCE.ordinal;
    const int AT_LEAST_ONCE = ProtonQoS.AT_LEAST_ONCE.ordinal;
    switch (type) {
    case AT_MOST_ONCE:
      link.setSenderSettleMode(SenderSettleMode.SETTLED);
      link.setReceiverSettleMode(ReceiverSettleMode.FIRST);
      break;
    case AT_LEAST_ONCE:
      link.setSenderSettleMode(SenderSettleMode.UNSETTLED);
      link.setReceiverSettleMode(ReceiverSettleMode.FIRST);
      break;
    default:
      break;
    }
    return self();
  }

  public UnsignedLong getMaxMessageSize() {
    return link.getMaxMessageSize();
  }

  public void setMaxMessageSize(UnsignedLong maxMessageSize) {
    link.setMaxMessageSize(maxMessageSize);
  }

  public UnsignedLong getRemoteMaxMessageSize() {
    return link.getRemoteMaxMessageSize();
  }

  public Map!(Symbol, Object) getRemoteProperties() {
    return link.getRemoteProperties();
  }

  public void setProperties(Map!(Symbol, Object) properties) {
    link.setProperties(properties);
  }

  public void setOfferedCapabilities(Symbol[] capabilities) {
    link.setOfferedCapabilities(capabilities);
  }

  public Symbol[] getRemoteOfferedCapabilities() {
    return link.getRemoteOfferedCapabilities();
  }

  public void setDesiredCapabilities(Symbol[] capabilities) {
    link.setDesiredCapabilities(capabilities);
  }

  public Symbol[] getRemoteDesiredCapabilities() {
    return link.getRemoteDesiredCapabilities();
  }

  public void free() {
    link.free();
    getSession().getConnectionImpl().flush();
  }

  /////////////////////////////////////////////////////////////////////////////
  //
  // Implementation details hidden from public api.
  //
  /////////////////////////////////////////////////////////////////////////////
  void fireRemoteOpen() {
    if (_openHandler !is null) {
      //openHandler.handle(ProtonHelper.future(self(), getRemoteCondition()));
      _openHandler.handle(self());
    }
  }

  void fireRemoteDetach() {
    if (_detachHandler !is null) {
      //detachHandler.handle(ProtonHelper.future(self(), getRemoteCondition()));
      _detachHandler.handle(self());
    }
  }

  void fireRemoteClose() {
    if (_closeHandler !is null) {
      //closeHandler.handle(ProtonHelper.future(self(), getRemoteCondition()));
      _closeHandler.handle(self());
    }
  }

  abstract void handleLinkFlow();
}
