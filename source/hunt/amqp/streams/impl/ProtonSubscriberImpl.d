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
module hunt.amqp.streams.impl.ProtonSubscriberImpl;


import hunt.proton.amqp.transport.Source;
import hunt.proton.amqp.transport.Target;
import hunt.amqp.streams.Subscription;

import hunt.amqp.Handler;
import hunt.amqp.ProtonDelivery;
import hunt.amqp.ProtonLinkOptions;
import hunt.amqp.ProtonSender;
import hunt.amqp.impl.ProtonConnectionImpl;
import hunt.amqp.impl.ProtonDeliveryImpl;
import hunt.amqp.streams.ProtonSubscriber;
import hunt.amqp.streams.ProtonSubscriberOptions;
import hunt.amqp.streams.Tracker;
import hunt.net.Connection;
import hunt.Exceptions;
import hunt.logging;
import hunt.Object;
import hunt.amqp.streams.impl.TrackerImpl;

class ProtonSubscriberImpl : ProtonSubscriber!Tracker {

  private Subscription sub;
  private Connection connCtx;
  private ProtonConnectionImpl conn;
  private ProtonSender sender;
  //private  AtomicBoolean subscribed = new AtomicBoolean();
  //private  AtomicBoolean completed = new AtomicBoolean();
  //private  AtomicBoolean cancelledSub = new AtomicBoolean();

  private  bool subscribed ;
  private  bool completed ;
  private  bool cancelledSub ;
  private bool emitOnConnectionEnd = true;
  private long outstandingRequests = 0;

  this(string address, ProtonConnectionImpl conn) {
    this(address, conn, new ProtonSubscriberOptions());
  }

  this(string address, ProtonConnectionImpl conn, ProtonSubscriberOptions options) {
    this.connCtx = conn.getContext();
    this.conn = conn;

    ProtonLinkOptions linkOptions = new ProtonLinkOptions();
    if(options.getLinkName() !is null) {
      linkOptions.setLinkName(options.getLinkName());
    }

    sender = conn.createSender(address, linkOptions);
    sender.setAutoDrained(false);
  }

  
  public void onSubscribe(Subscription subscription) {
   // Objects.requireNonNull(subscription, "A subscription must be supplied");

    if(subscribed) {
      subscribed = true;
      logInfo("Only a single Subscription is supported and already subscribed, cancelling new subscriber.");
      subscription.cancel();
      return;
    }

    this.sub = subscription;

   conn.addEndHandler(
   new class Handler!Void{
     void handle(Void o)
     {
       if(emitOnConnectionEnd) {
         cancelSub();
       }
     }
   }
   );

  sender.sendQueueDrainHandler(
  new class Handler!ProtonSender{
    void handle(ProtonSender o)
    {
      if(!completed && !cancelledSub) {
        long credit = sender.getCredit();
        long newRequests = credit - outstandingRequests;

        if(newRequests > 0) {
          outstandingRequests += newRequests;
          sub.request(newRequests);
        }
      }
    }
  }
  );

  sender.detachHandler(
  new class Handler!ProtonSender{
    void handle(ProtonSender o)
    {
      cancelSub();
      sender.detach();
    }
  }
  );

  sender.closeHandler(
  new class Handler!ProtonSender{
    void handle(ProtonSender o)
    {
      cancelSub();
      sender.close();
    }
  }
  );

  sender.open();


    //connCtx.runOnContext(x-> {
    //  conn.addEndHandler(v -> {
    //    if(emitOnConnectionEnd) {
    //      cancelSub();
    //    }
    //  });
    //
    //  sender.sendQueueDrainHandler(sender -> {
    //    if(!completed.get() && !cancelledSub.get()) {
    //      long credit = sender.getCredit();
    //      long newRequests = credit - outstandingRequests;
    //
    //      if(newRequests > 0) {
    //        outstandingRequests += newRequests;
    //        sub.request(newRequests);
    //      }
    //    }
    //  });
    //
    //  sender.detachHandler(res-> {
    //    cancelSub();
    //    sender.detach();
    //  });
    //
    //  sender.closeHandler(res-> {
    //    cancelSub();
    //    sender.close();
    //  });
    //
    //  sender.openHandler(res -> {
    //    LOG.trace("Attach received");
    //  });
    //
    //  sender.open();
    //});
  }

  private void cancelSub() {
    if(!cancelledSub) {
      cancelledSub = true;
      sub.cancel();
    }
  }

  
  public void onNext(Tracker tracker) {
   // Objects.requireNonNull(tracker, "An element must be supplied when calling onNext");

    if(!completed) {
        outstandingRequests--;
        TrackerImpl env = cast(TrackerImpl) tracker;
        ProtonDelivery delivery = sender.send(tracker.message(), new class Handler!ProtonDelivery
        {
          void handle(ProtonDelivery var1)
          {
            Handler!Tracker h = env.handler();
            if(h !is null) {
              h.handle(env);
            }
          }
        });
        env.setDelivery(cast(ProtonDeliveryImpl) delivery);
    }
  }

  
  public void onError(Throwable t) {

    if(!completed) {
      completed = true;
      sender.sendQueueDrainHandler(null);
      sender.detachHandler(null);
      sender.closeHandler(null);
    }
  }

  
  public void onComplete() {
    if(!completed) {
      completed = true;
      sender.sendQueueDrainHandler(null);
      sender.detachHandler(null);
      sender.closeHandler(null);
      sender.close();
    }
  }

  
  public ProtonSubscriber!Tracker setSource(Source source) {
    sender.setSource(source);
    return this;
  }

  
  public Source getSource() {
    return sender.getSource();
  }

  
  public ProtonSubscriber!Tracker setTarget(Target target) {
    sender.setTarget(target);
    return this;
  }

  
  public Target getTarget() {
    return sender.getTarget();
  }

  public Source getRemoteSource() {
    return sender.getRemoteSource();
  }

  public Target getRemoteTarget() {
    return sender.getRemoteTarget();
  }

  public bool isEmitOnConnectionEnd() {
    return emitOnConnectionEnd;
  }

  public void setEmitOnConnectionEnd(bool emitOnConnectionEnd) {
    this.emitOnConnectionEnd = emitOnConnectionEnd;
  }

  public ProtonSender getLink() {
    return sender;
  }
}
