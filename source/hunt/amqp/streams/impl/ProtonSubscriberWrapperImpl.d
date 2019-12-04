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
module hunt.amqp.streams.impl.ProtonSubscriberWrapperImpl;


import hunt.proton.amqp.transport.Source;
import hunt.proton.amqp.transport.Target;
import hunt.proton.message.Message;
import hunt.amqp.streams.Subscription;

import hunt.amqp.ProtonSender;
import hunt.amqp.streams.ProtonSubscriber;
import hunt.amqp.streams.Tracker;
import hunt.amqp.streams.impl.ProtonSubscriberImpl;

class ProtonSubscriberWrapperImpl : ProtonSubscriber!Message {

  private  ProtonSubscriberImpl _delegate;

  this(ProtonSubscriberImpl delegat) {
    this._delegate = delegat;
  }

  
  public void onSubscribe(Subscription subscription) {
    _delegate.onSubscribe(subscription);
  }

  
  public void onNext(Message m) {

    Tracker s = Tracker.create(m, null);

    _delegate.onNext(s);
  }

  
  public void onError(Throwable t) {
    _delegate.onError(t);
  }

  
  public void onComplete() {
    _delegate.onComplete();
  }

  public bool isEmitOnConnectionEnd() {
    return _delegate.isEmitOnConnectionEnd();
  }

  public void setEmitOnConnectionEnd(bool emitOnConnectionEnd) {
    _delegate.setEmitOnConnectionEnd(emitOnConnectionEnd);
  }

  public ProtonSender getLink() {
    return _delegate.getLink();
  }

  
  public ProtonSubscriber!Message setSource(Source source) {
    _delegate.setSource(source);
    return this;
  }

  
  public Source getSource() {
    return _delegate.getSource();
  }

  
  public ProtonSubscriber!Message setTarget(Target target) {
    _delegate.setTarget(target);
    return this;
  }

  
  public Target getTarget() {
    return _delegate.getTarget();
  }

  public Source getRemoteSource() {
    return _delegate.getRemoteSource();
  }

  public Target getRemoteTarget() {
    return _delegate.getRemoteTarget();
  }
}
