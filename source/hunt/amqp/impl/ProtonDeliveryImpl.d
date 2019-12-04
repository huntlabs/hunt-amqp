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
module hunt.amqp.impl.ProtonDeliveryImpl;

import hunt.amqp.Handler;
import hunt.amqp.ProtonDelivery;

import hunt.proton.amqp.transport.DeliveryState;
import hunt.proton.engine.Delivery;
import hunt.proton.engine.Record;
import hunt.amqp.impl.ProtonLinkImpl;
import hunt.amqp.ProtonReceiver;
import hunt.amqp.ProtonSender;

/**
 * @author <a href="http://hiramchirino.com">Hiram Chirino</a>
 */
class ProtonDeliveryImpl : ProtonDelivery {

  private  Delivery delivery;
  private Handler!ProtonDelivery _handler;
  private bool autoSettle;

  this(Delivery delivery) {
    this.delivery = delivery;
    delivery.setContext(this);
  }

  public Object getLink() {
    return this.delivery.getLink().getContext();
  }

  public void clear() {
    delivery.clear();
  }

  public DeliveryState getLocalState() {
    return delivery.getLocalState();
  }

  
  public bool isSettled() {
    return delivery.isSettled();
  }

  
  public bool remotelySettled() {
    return delivery.remotelySettled();
  }

  
  public Record attachments() {
    return delivery.attachments();
  }

  
  public byte[] getTag() {
    return delivery.getTag();
  }

  public void setDefaultDeliveryState(DeliveryState state) {
    delivery.setDefaultDeliveryState(state);
  }

  public DeliveryState getDefaultDeliveryState() {
    return delivery.getDefaultDeliveryState();
  }

  public bool isReadable() {
    return delivery.isReadable();
  }

  public bool isUpdated() {
    return delivery.isUpdated();
  }

  public bool isWritable() {
    return delivery.isWritable();
  }

  public int pending() {
    return delivery.pending();
  }

  public bool isPartial() {
    return delivery.isPartial();
  }

  public DeliveryState getRemoteState() {
    return delivery.getRemoteState();
  }

  
  public int getMessageFormat() {
    return delivery.getMessageFormat();
  }

  public bool isBuffered() {
    return delivery.isBuffered();
  }

  
  public ProtonDelivery disposition(DeliveryState state, bool s) {
    if(delivery.isSettled()) {
      return this;
    }

    delivery.disposition(state);
    if (s) {
      settle();
    } else {
      flushConnection();
    }

    return this;
  }

  
  public ProtonDelivery settle() {
    delivery.settle();
    flushConnection();

    return this;
  }

  private void flushConnection() {
    ProtonLinkImpl!ProtonReceiver receiver = cast(ProtonLinkImpl!ProtonReceiver)getLinkImpl();
    if (receiver !is null)
    {
      receiver.getSession().getConnectionImpl().flush();
    }else
    {
      ProtonLinkImpl!ProtonSender sender = cast(ProtonLinkImpl!ProtonSender)getLinkImpl();
      if (sender !is null)
      {
        sender.getSession().getConnectionImpl().flush();
      }
    }
    //getLinkImpl().getSession().getConnectionImpl().flush();
  }

  public ProtonDelivery handler(Handler!ProtonDelivery handler) {
    this._handler = handler;
    if (delivery.isSettled()) {
      fireUpdate();
    }
    return this;
  }

  bool isAutoSettle() {
    return autoSettle;
  }

  void setAutoSettle(bool autoSettle) {
    this.autoSettle = autoSettle;
  }

  void fireUpdate() {
    if (this._handler !is null) {
      this._handler.handle(this);
    }

    if (autoSettle && delivery.remotelySettled() && !delivery.isSettled()) {
      settle();
    }
  }

  public Object getLinkImpl() {
    return  delivery.getLink().getContext();
  }

}
