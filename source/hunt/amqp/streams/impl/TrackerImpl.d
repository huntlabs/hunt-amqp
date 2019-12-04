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
module hunt.amqp.streams.impl.TrackerImpl;

import hunt.proton.amqp.messaging.Accepted;
import hunt.proton.amqp.transport.DeliveryState;
import hunt.proton.message.Message;

import hunt.amqp.Handler;
import hunt.amqp.ProtonDelivery;
import hunt.amqp.impl.ProtonDeliveryImpl;
import hunt.amqp.streams.Tracker;

class TrackerImpl : Tracker {
  private  Message _message;
  private  ProtonDeliveryImpl _delivery;
  private  Handler!Tracker onUpdated;

  this(Message message, Handler!Tracker onUpdated) {
    this._message = message;
    this.onUpdated = onUpdated;
  }

  
  public Message message() {
      return _message;
  }

  public ProtonDelivery delivery() {
    return _delivery;
  }

  public void setDelivery(ProtonDeliveryImpl delivery) {
    this._delivery = delivery;
  }

  
  public bool isAccepted() {
    return   cast(Accepted)(_delivery.getRemoteState()) !is null;
  }

  
  public DeliveryState getRemoteState() {
    return _delivery.getRemoteState();
  }

  
  public bool isRemotelySettled() {
    return _delivery.remotelySettled();
  }

  public Handler!Tracker handler() {
    return onUpdated;
  }

  public void setHandler(Handler!Tracker onUpdated) {
    this.onUpdated = onUpdated;
  }

}