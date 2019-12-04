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
module hunt.amqp.streams.impl.ProtonPublisherWrapperImpl;


import hunt.proton.amqp.transport.Source;
import hunt.proton.amqp.transport.Target;
import hunt.proton.message.Message;
import hunt.amqp.streams.Subscriber;
import hunt.amqp.streams.Subscription;

import hunt.amqp.ProtonReceiver;
import hunt.amqp.streams.Delivery;
import hunt.amqp.streams.ProtonPublisher;
import hunt.amqp.streams.impl.ProtonPublisherImpl;

class ProtonPublisherWrapperImpl : ProtonPublisher!Message {

  private ProtonPublisherImpl _delegate;

  this(ProtonPublisherImpl delegat) {
    this._delegate = delegat;
  }

  
  public void subscribe(Subscriber!Message subscriber) {
    _delegate.subscribe(new AmqpSubscriberWrapperImpl(subscriber));
  }

  public bool isEmitOnConnectionEnd() {
    return _delegate.isEmitOnConnectionEnd();
  }

  public void setEmitOnConnectionEnd(bool emitOnConnectionEnd) {
    _delegate.setEmitOnConnectionEnd(emitOnConnectionEnd);
  }

  // ==================================================

  class AmqpSubscriberWrapperImpl : Subscriber!Delivery {

    private Subscriber!Message delegateSub;

    this(Subscriber!Message subscriber) {
      this.delegateSub = subscriber;
    }

    
    public void onSubscribe(Subscription s) {
      delegateSub.onSubscribe(s);
    }

    
    public void onNext(Delivery d) {
      Message m = d.message();
      delegateSub.onNext(m);
      d.accept();
    }

    
    public void onError(Throwable t) {
      delegateSub.onError(t);
    }

    
    public void onComplete() {
      delegateSub.onComplete();
    }
  }

  public ProtonReceiver getLink() {
    return _delegate.getLink();
  }

  // ==================================================

  
  public string getRemoteAddress() {
    return _delegate.getRemoteAddress();
  }

  
  public ProtonPublisher!Message setSource(Source source) {
    _delegate.setSource(source);
    return this;
  }

  
  public Source getSource() {
    return _delegate.getSource();
  }

  
  public ProtonPublisher!Message setTarget(Target target) {
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