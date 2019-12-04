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
module hunt.amqp.streams.impl.ProtonPublisherImpl;

import hunt.collection.ArrayList;
//import java.util.concurrent.atomic.AtomicBoolean;

import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.messaging.Released;
import hunt.proton.amqp.messaging.TerminusDurability;
import hunt.proton.amqp.messaging.TerminusExpiryPolicy;
import hunt.proton.amqp.transport.Source;
import hunt.proton.amqp.transport.Target;
import hunt.amqp.streams.Subscriber;
import hunt.amqp.streams.Subscription;

import hunt.amqp.ProtonLinkOptions;
import hunt.amqp.ProtonReceiver;
import hunt.amqp.impl.ProtonConnectionImpl;
import hunt.amqp.streams.Delivery;
import hunt.amqp.streams.ProtonPublisher;
import hunt.amqp.streams.ProtonPublisherOptions;
import hunt.net.Connection;
import std.concurrency : initOnce;
import hunt.Exceptions;
import hunt.amqp.impl.ProtonClientImpl;
import hunt.amqp.Handler;
import hunt.amqp.ProtonMessageHandler;
import hunt.amqp.ProtonDelivery;
import hunt.proton.message.Message;
import std.algorithm;
import hunt.logging;
import hunt.Long;
import hunt.math.Helper;

import hunt.proton.amqp.messaging.Source;
import hunt.amqp.streams.impl.DeliveryImpl;
import hunt.Boolean;

class ProtonPublisherImpl : ProtonPublisher!Delivery {

 // private static  Symbol SHARED = Symbol.valueOf("shared");
 // private static  Symbol GLOBAL = Symbol.valueOf("global");

   static Symbol  SHARED() {
     __gshared Symbol  inst;
     return initOnce!inst(Symbol.valueOf("shared"));
   }

   static Symbol  GLOBAL() {
     __gshared Symbol  inst;
     return initOnce!inst(Symbol.valueOf("global"));
   }

  private Connection connCtx;
  private  ProtonConnectionImpl conn;
 // private  AtomicBoolean subscribed = new AtomicBoolean();
  private bool subscribed ;
  private AmqpSubscription subscription;
  private ProtonReceiver receiver;
  private bool emitOnConnectionEnd = true;
  private int maxOutstandingCredit = 1000;

  private bool durable;

  this(string address, ProtonConnectionImpl conn, ProtonPublisherOptions options) {
    this.connCtx = conn.getContext();
    this.conn = conn;

    ProtonLinkOptions linkOptions = new ProtonLinkOptions();
    if(options.getLinkName() !is null) {
      linkOptions.setLinkName(options.getLinkName());
    }

    receiver = conn.createReceiver(address, linkOptions);
    receiver.setAutoAccept(false);
    receiver.setPrefetch(0);

    if(options.getMaxOutstandingCredit() > 0) {
      maxOutstandingCredit = options.getMaxOutstandingCredit();
    }

    //hunt.proton.amqp.messaging.Source
    hunt.proton.amqp.messaging.Source.Source source = cast(hunt.proton.amqp.messaging.Source.Source) receiver.getSource();
    durable = options.isDurable();
    if(durable) {
      source.setExpiryPolicy(TerminusExpiryPolicy.NEVER);
      source.setDurable(TerminusDurability.UNSETTLED_STATE);
    }

    if(options.isDynamic()) {
      source.setAddress(null);
      source.setDynamic(new Boolean(true));
    }

    ArrayList!Symbol capabilities = new ArrayList!Symbol();
    if(options.isShared()) {
      capabilities.add(SHARED);
    }
    if(options.isGlobal()) {
      capabilities.add(GLOBAL);
    }

    if(!capabilities.isEmpty()) {
    //  Symbol[] caps = capabilities.toArray(new Symbol[capabilities.size()]);
      source.setCapabilities(capabilities);
    }
  }

  
  public void subscribe(Subscriber!Delivery subscriber) {
    //LOG.trace("Subscribe called");
    //Objects.requireNonNull(subscriber, "A subscriber must be supplied");

        //if(subscribed = (true)) {
        //  throw new IllegalStateException("Only a single susbcriber supported, and subscribe already called.");
        //}

    //if(subscribed.getAndSet(true)) {
    //  throw new IllegalStateException("Only a single susbcriber supported, and subscribe already called.");
    //}

    subscription = new AmqpSubscription(subscriber);

    //ConnectionEventBaseHandler handler =  cast(ConnectionEventBaseHandler)connCtx.getHandler();

   // receiver.closeHandler()

    receiver.closeHandler(
      new class Handler!ProtonReceiver{
          void handle(ProtonReceiver o)
          {
            receiver.close();
          }
      }
    );

    receiver.detachHandler(
      new class Handler!ProtonReceiver{
        void handle(ProtonReceiver o)
        {
          receiver.detach();
        }
      }
    );

    receiver.openHandler(
      new class Handler!ProtonReceiver{
        void handle(ProtonReceiver o)
        {
          subscription.indicateSubscribed();
        }
      }
    );

   receiver.handler(
       new class ProtonMessageHandler{
         void handle(ProtonDelivery delivery, Message message)
         {
           Delivery envelope = new DeliveryImpl(message, delivery, connCtx);
           if(!subscription.onNextWrapper(envelope)){
             delivery.disposition(Released.getInstance(), true);
           }
         }
       }
   );

     receiver.open();


    //connCtx.runOnContext(x-> {
    //  conn.addEndHandler(v -> {
    //    if(emitOnConnectionEnd) {
    //      subscription.indicateError(new Exception("Connection closed: " + conn.getContainer()));
    //    }
    //  });
    //
    //  receiver.closeHandler(res-> {
    //    subscription.indicateError(new Exception("Link closed unexpectedly"));
    //    receiver.close();
    //  });
    //
    //  receiver.detachHandler(res-> {
    //    subscription.indicateError(new Exception("Link detached unexpectedly"));
    //    receiver.detach();
    //  });
    //
    //  receiver.openHandler(res -> {
    //    subscription.indicateSubscribed();
    //  });
    //
    //  receiver.handler((delivery, message) -> {
    //    Delivery envelope = new DeliveryImpl(message, delivery, connCtx);
    //    if(!subscription.onNextWrapper(envelope)){
    //      delivery.disposition(Released.getInstance(), true);
    //    }
    //  });
    //
    //  receiver.open();
    //});
  }

  // ==================================================

  class AmqpSubscription : Subscription {

    private Subscriber!Delivery subcriber;
    //private  AtomicBoolean cancelled = new AtomicBoolean();
    //private  AtomicBoolean completed = new AtomicBoolean();
    private bool cancelled;
    private bool completed;
    private long outstandingRequests = 0;

    this(Subscriber!Delivery sub) {
      this.subcriber = sub;
    }

    private bool onNextWrapper(Delivery next) {
      if(!completed&& !cancelled){
        subcriber.onNext(next);

        // Now top up credits if still needed
        outstandingRequests = outstandingRequests - 1;

        if(!cancelled) {
          int currentCredit = receiver.getCredit();
          if(currentCredit < (maxOutstandingCredit * 0.5) && outstandingRequests > currentCredit) {
            int creditLimit = cast(int) min(outstandingRequests, maxOutstandingCredit);

            int credits = creditLimit - currentCredit;
            if(credits > 0) {
              //if (LOG.isTraceEnabled()) {
              //  LOG.trace("Updating credit for outstanding requests: " + credits);
              //}
              logInfo("Updating credit for outstanding requests");
              flowCreditIfNeeded(credits);
            }
          }
        }

        return true;
      } else {
       // LOG.trace("skipped calling onNext, already completed or cancelled");
        logInfo("skipped calling onNext, already completed or cancelled");
        return false;
      }
    }

    
    public void request(long n) {
      if(n <= 0 && !cancelled) {
        logError("non-positive subscription request, requests must be > 0");
        //connCtx.runOnContext(x -> {
        //  indicateError(new IllegalArgumentException("non-positive subscription request, requests must be > 0"));
        //});
      } else if(!cancelled) {

          if(n == Long.MAX_VALUE) {
            outstandingRequests = Long.MAX_VALUE;
          } else {
            try {
              outstandingRequests = MathHelper.addExact(n, outstandingRequests);
            } catch (ArithmeticException ae) {
              outstandingRequests = Long.MAX_VALUE;
            }
          }

          if(cancelled) {
           // LOG.trace("Not sending more credit, subscription cancelled since request was originally scheduled");
            logInfo("Not sending more credit, subscription cancelled since request was originally scheduled");
            return;
          }

          flowCreditIfNeeded(n);


        //connCtx.runOnContext(x -> {
        //  if (LOG.isTraceEnabled()) {
        //    LOG.trace("Processing request: " + n);
        //  }
        //
        //  if(n == Long.MAX_VALUE) {
        //    outstandingRequests = Long.MAX_VALUE;
        //  } else {
        //    try {
        //      outstandingRequests = Math.addExact(n, outstandingRequests);
        //    } catch (ArithmeticException ae) {
        //      outstandingRequests = Long.MAX_VALUE;
        //    }
        //  }
        //
        //  if(cancelled.get()) {
        //    LOG.trace("Not sending more credit, subscription cancelled since request was originally scheduled");
        //    return;
        //  }
        //
        //  flowCreditIfNeeded(n);
        //});
      }
    }

    private void flowCreditIfNeeded(long n) {
      int currentCredit = receiver.getCredit();
      if(currentCredit < maxOutstandingCredit) {
        int limit = maxOutstandingCredit - currentCredit;
        int addedCredit  = cast(int) min(n, limit);

        if(addedCredit > 0) {
          if(!completed) {
            //if (LOG.isTraceEnabled()) {
            //  LOG.trace("Flowing additional credits : " + addedCredit);
            //}
            receiver.flow(addedCredit);
          } else {
            logInfo("Skipping flowing additional credits as already completed");
            //if (LOG.isTraceEnabled()) {
            //  LOG.trace("Skipping flowing additional credits as already completed: " + addedCredit);
            //}
          }
        }
      }
    }

    
    public void cancel() {
      if (!cancelled) {
        cancelled = true;

        receiver.closeHandler(
        new class Handler!ProtonReceiver{
          void handle(ProtonReceiver o)
          {
            indicateCompletion();
            receiver.close();
          }
        }
        );

        receiver.detachHandler(
        new class Handler!ProtonReceiver{
          void handle(ProtonReceiver o)
          {
            indicateCompletion();
            receiver.detach();
          }
        }
        );

        if (durable) {
          receiver.detach();
        } else {
          receiver.close();
        }


        //  connCtx.runOnContext(x -> {
        //    LOG.trace("Cancelling");
        //    receiver.closeHandler(y -> {
        //      indicateCompletion();
        //      receiver.close();
        //    });
        //    receiver.detachHandler(y -> {
        //      indicateCompletion();
        //      receiver.detach();
        //    });
        //
        //    if(durable) {
        //      receiver.detach();
        //    } else {
        //      receiver.close();
        //    }
        //  });
        //} else {
        //  LOG.trace("Cancel no-op, already called.");
        //}
      }
    }
    private void indicateError(Throwable t) {
      if(!completed){
        completed = true;
        Subscriber!Delivery sub = subcriber;
        subcriber = null;
        if(sub !is null && !cancelled) {
          //LOG.trace("Indicating error");
          logError("Indicating error");
          sub.onError(t);
        } else {
          //LOG.trace("Skipping error indication, no sub or already cancelled");
          logError("Skipping error indication, no sub or already cancelled");
        }
      }
      else {
        //LOG.trace("indicateError no-op, already completed");
        logInfo("indicateError no-op, already completed");
      }
    }

    private void indicateSubscribed() {
      if(!completed){
        logInfo("Indicating subscribed");
        if(subcriber !is null) {
          subcriber.onSubscribe(this);
        }
      } else {
        logInfo("indicateSubscribed no-op, already completed");
      }
    }

    private void indicateCompletion() {
      if(!completed){
        completed = true;
        Subscriber!Delivery sub = subcriber;
        subcriber = null;

        bool canned = cancelled;
        if(sub !is null && ((outstandingRequests > 0  && canned) || !canned)) {
          logInfo("Indicating completion");
          sub.onComplete();
        } else {
          logInfo("Skipping completion indication");
        }
      } else {
        logInfo("indicateCompletion no-op, already completed");
      }
    }
  }

  public bool isEmitOnConnectionEnd() {
    return emitOnConnectionEnd;
  }

  public void setEmitOnConnectionEnd(bool emitOnConnectionEnd) {
    this.emitOnConnectionEnd = emitOnConnectionEnd;
  }

  public ProtonReceiver getLink() {
    return receiver;
  }

  // ==================================================

  
  public ProtonPublisher!Delivery setSource(hunt.proton.amqp.transport.Source.Source source) {
    receiver.setSource(source);
    return this;
  }

  
  public hunt.proton.amqp.transport.Source.Source getSource() {
    return receiver.getSource();
  }

  
  public ProtonPublisher!Delivery setTarget(Target target) {
    receiver.setTarget(target);
    return this;
  }

  
  public Target getTarget() {
    return receiver.getTarget();
  }

  
  public hunt.proton.amqp.transport.Source.Source getRemoteSource() {
    return receiver.getRemoteSource();
  }

  
  public Target getRemoteTarget() {
    return receiver.getRemoteTarget();
  }

  
  public string getRemoteAddress() {
    hunt.proton.amqp.transport.Source.Source remoteSource = getRemoteSource();

    return remoteSource is null ? null : (cast(string)(remoteSource.getAddress().getBytes()));
  }
}
