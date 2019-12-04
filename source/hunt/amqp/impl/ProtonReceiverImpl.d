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
module hunt.amqp.impl.ProtonReceiverImpl;

import hunt.amqp.ProtonMessageHandler;
import hunt.amqp.ProtonReceiver;
import hunt.proton.Proton;
import hunt.proton.amqp.messaging.Modified;
import hunt.proton.amqp.transport.Source;
import hunt.proton.codec.CompositeReadableBuffer;
import hunt.proton.codec.ReadableBuffer;
import hunt.proton.engine.Delivery;
import hunt.proton.engine.Receiver;
import hunt.proton.engine.Session;
import hunt.proton.message.impl.MessageImpl;
import hunt.amqp.Handler;
import hunt.Object;
import hunt.amqp.ProtonHelper;
import hunt.amqp.impl.ProtonLinkImpl;
import hunt.amqp.impl.ProtonDeliveryImpl;
import hunt.Long;
import hunt.Exceptions;
import hunt.logging;
import hunt.Boolean;

/**
 * @author <a href="http://hiramchirino.com">Hiram Chirino</a>
 */
class ProtonReceiverImpl : ProtonLinkImpl!ProtonReceiver , ProtonReceiver {


  private ProtonMessageHandler _handler;
  private int prefetch = 1000;
  private Handler!Void drainCompleteHandler;
  private Long drainTimeoutTaskId = null;
  private Session session;
  private int maxFrameSize;
  private long sessionIncomingCapacity;
  private long windowFullThreshhold;

  this(Receiver receiver) {
    super(receiver);
    session = receiver.getSession();
    sessionIncomingCapacity = session.getIncomingCapacity();
    maxFrameSize = session.getConnection().getTransport().getMaxFrameSize();
    windowFullThreshhold = sessionIncomingCapacity - maxFrameSize;
  }

  override
  public ProtonReceiverImpl self() {
    return this;
  }

  private Receiver getReceiver() {
    return cast(Receiver) link;
  }

  public int recv(byte[] bytes, int offset, int size) {
    return getReceiver().recv(bytes, offset, size);
  }

  override
  public string getRemoteAddress() {
    Source remoteSource = getRemoteSource();

    return remoteSource is null ? null : cast(string)(remoteSource.getAddress().getBytes());
  }

  public ProtonReceiver drain(long timeout ,Handler!Void completionHandler) {
    if (prefetch > 0) {
      throw new IllegalStateException("Manual credit management not available while prefetch is non-zero");
    }

    //if (completionHandler is null) {
    //  throw new IllegalArgumentException("A completion handler must be provided");
    //}
    //
    //if (drainCompleteHandler !is null) {
    //  throw new IllegalStateException("A previous drain operation has not yet completed");
    //}

    if ((getCredit() - getQueued()) <= 0) {
      // We have no remote credit
      if (getQueued() == 0) {
        // All the deliveries have been processed, drain is a no-op, nothing to do but complete.
        //completionHandler.handle(Future.succeededFuture());

      } else {
          // There are still deliveries to process, wait for them to be.
          setDrainHandlerAndTimeoutTask(timeout);
      }
    } else {
      setDrainHandlerAndTimeoutTask(timeout);

      getReceiver().drain(0);
      flushConnection();
    }

    return this;
  }

  private void setDrainHandlerAndTimeoutTask(long delay) {
    implementationMissing(false);
   // if(delay > 0) {
   //   Vertx vertx = Vertx.currentContext().owner();
   //   drainTimeoutTaskId = vertx.setTimer(delay, x -> {
   //     drainTimeoutTaskId = null;
   //     drainCompleteHandler = null;
   //     completionHandler.handle(Future.failedFuture("Drain attempt timed out"));
   //   });
   // }
  }

  override
  public ProtonReceiver flow(int credits){
    flow(credits, true);
    return this;
  }

  private void flow(int credits, bool checkPrefetch) {
    if (checkPrefetch && prefetch > 0) {
      throw new IllegalStateException("Manual credit management not available while prefetch is non-zero");
    }

    //if (drainCompleteHandler !is null) {
    //  throw new IllegalStateException("A previous drain operation has not yet completed");
    //}

    getReceiver().flow(credits);
    flushConnection();
  }

  public bool draining() {
    return getReceiver().draining();
  }

  public ProtonReceiver setDrain(bool drain) {
    getReceiver().setDrain(drain);
    return this;
  }

  override
  public ProtonReceiver handler(ProtonMessageHandler handler) {
    this._handler = handler;
    onDelivery();
    return this;
  }

  private void flushConnection() {
    getSession().getConnectionImpl().flush();
  }

  /////////////////////////////////////////////////////////////////////////////
  //
  // Implementation details hidden from public api.
  //
  /////////////////////////////////////////////////////////////////////////////

  private bool autoAccept = true;
  private CompositeReadableBuffer splitContent;

  void onDelivery() {
    if (this._handler is null) {
      return;
    }

    Receiver receiver = getReceiver();
    Delivery delivery = receiver.current();

    if (delivery !is null) {

      if(delivery.isAborted()) {
        handleAborted(receiver, delivery);
        return;
      }

      if (delivery.isPartial()) {
        handlePartial(receiver, delivery);

        // Delivery is not yet completely received,
        // return and allow further frames to arrive.
        return;
      }

      // Complete prior partial content if needed, or grab it all.
      ReadableBuffer data = receiver.recv();
      if(splitContent !is null) {
        data = completePartial(data);
      }

      receiver.advance();

      MessageImpl msg = cast(MessageImpl) Proton.message();
      ProtonDeliveryImpl delImpl = new ProtonDeliveryImpl(delivery);
      try {
        msg.decode(data);
      } catch (Throwable t) {
        logError("Unable to decode message, undeliverable");
        handleDecodeFailure(receiver, delImpl);
        return;
      }

      _handler.handle(delImpl, msg);

      if (autoAccept && delivery.getLocalState() is null) {
        ProtonHelper.accepted(delImpl, true);
      }

      if (prefetch > 0) {
        // Replenish credit if prefetch is configured.
        // TODO: batch credit replenish, optionally flush if exceeding a given threshold?
        flow(1, false);
      } else {
        processForDrainCompletion();
      }
    }
  }

  private void handleDecodeFailure(Receiver receiver, ProtonDeliveryImpl delImpl) {
    Modified modified = new Modified();
    modified.setDeliveryFailed(new Boolean(true));
    modified.setUndeliverableHere(new Boolean(true));

    delImpl.disposition(modified, true);

    if(!receiver.getDrain()) {
      flow(1, false);
    } else {
      processForDrainCompletion();
    }
  }

  private void handleAborted(Receiver receiver, Delivery delivery) {
    splitContent = null;

    receiver.advance();
    delivery.settle();

    if(!receiver.getDrain()) {
      flow(1, false);
    } else {
      processForDrainCompletion();
    }
  }

  private void handlePartial( Receiver receiver,  Delivery delivery) {
    if (sessionIncomingCapacity <= 0 || maxFrameSize <= 0 || session.getIncomingBytes() < windowFullThreshhold) {
      // No window, or there is still capacity, so do nothing.
    } else {
      // The session window could be effectively full, we need to
      // read part of the delivery content to ensure there is
      // room made for receiving more of the delivery.
      if(delivery.available() > 0) {
        ReadableBuffer buff = receiver.recv();

        if(splitContent is null && cast(CompositeReadableBuffer)buff !is null) {
          // Its a composite and there is no prior partial content, use it.
          splitContent = cast(CompositeReadableBuffer) buff;
        } else {
          int remaining = buff.remaining();
          if(remaining > 0) {
            if (splitContent is null) {
              splitContent = new CompositeReadableBuffer();
            }

            byte[] chunk = new byte[remaining];
            buff.get(chunk);

            splitContent.append(chunk);
          }
        }
      }
    }
  }

  private ReadableBuffer completePartial( ReadableBuffer Content) {
    int pending = Content.remaining();
    if(pending > 0) {
      byte[] chunk = new byte[pending];
      Content.get(chunk);

      splitContent.append(chunk);
    }

    ReadableBuffer data = splitContent;
    splitContent = null;

    return data;
  }

  override
  public bool isAutoAccept() {
    return autoAccept;
  }

  override
  public ProtonReceiver setAutoAccept(bool autoAccept) {
    this.autoAccept = autoAccept;
    return this;
  }

  override
  public ProtonReceiver setPrefetch(int messages) {
    if (messages < 0) {
      throw new IllegalArgumentException("Value must not be negative");
    }

    prefetch = messages;
    return this;
  }

  override
  public int getPrefetch() {
    return prefetch;
  }

  override
  public ProtonReceiver open() {
    super.open();
    if (prefetch > 0) {
      // Grant initial credit if prefetching.
      flow(prefetch, false);
    }

    return this;
  }

  override
  void handleLinkFlow(){
    processForDrainCompletion();
  }

  private void processForDrainCompletion() {
    //implementationMissing(false);
    Handler!Void h = drainCompleteHandler;
    if(h !is null && getCredit() <= 0 && getQueued() <= 0) {
      bool timeoutTaskCleared = false;

      Long timerId = drainTimeoutTaskId;
      if(timerId !is null) {
        //Vertx vertx = Vertx.currentContext().owner();
       // timeoutTaskCleared = vertx.cancelTimer(timerId);
        timeoutTaskCleared = true;
      } else {
        timeoutTaskCleared = true;
      }

      drainTimeoutTaskId = null;
      drainCompleteHandler = null;

      if(timeoutTaskCleared) {
        h.handle(new Boolean(true));
      }
    }
  }
}
