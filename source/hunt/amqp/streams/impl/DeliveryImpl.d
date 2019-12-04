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
module hunt.amqp.streams.impl.DeliveryImpl;

import hunt.proton.amqp.messaging.Accepted;
import hunt.proton.amqp.transport.DeliveryState;
import hunt.proton.message.Message;

import hunt.amqp.ProtonDelivery;
import hunt.amqp.streams.Delivery;
import std.concurrency : initOnce;
import hunt.net.Connection;
import hunt.Exceptions;

class DeliveryImpl : Delivery {
 // private static  Accepted ACCEPTED = Accepted.getInstance();

   static Accepted  ACCEPTED() {
     __gshared Accepted  inst;
     return initOnce!inst(Accepted.getInstance());
   }

  private  Message _message;
  private  ProtonDelivery _delivery;
  private  Connection ctx;

  this(Message message, ProtonDelivery delivery, Connection ctx) {
    this._message = message;
    this._delivery = delivery;
    this.ctx = ctx;
  }

  
  public Message message() {
      return _message;
  }

  public ProtonDelivery delivery() {
    return _delivery;
  }

  
  public Delivery accept() {
    _delivery.disposition(ACCEPTED, true);

    return this;
  }

  
  public Delivery disposition( DeliveryState state,  bool settle) {
    _delivery.disposition(state, settle);
    return this;
  }

  private void ackOnContext() {
    implementationMissing(false);
    //if (onContextEventLoop()) {
    //  action.handle(null);
    //} else {
    //  ctx.runOnContext(action);
    //}
  }

  public bool onContextEventLoop() {
    implementationMissing(false);
    return true;
    //return ctx.nettyEventLoop().inEventLoop();
  }

  public Connection getCtx() {
    return ctx;
  }
}