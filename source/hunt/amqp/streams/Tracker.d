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
module hunt.amqp.streams.Tracker;
import hunt.proton.amqp.transport.DeliveryState;
import hunt.proton.message.Message;

import hunt.amqp.Handler;
import hunt.amqp.streams.impl.TrackerImpl;

interface Tracker {

  /**
   * Creates a tracker for sending a message.
   *
   * @param message
   *          the message
   * @return the tracker
   */
  static Tracker create(Message message) {
    return new TrackerImpl(message, null);
  }

  /**
   * Creates a tracker for sending a message, providing a handler that is
   * called when disposition updates are received for the message delivery.
   *
   * @param message
   *          the message
   * @param onUpdated
   *          the onUpdated handler
   * @return the tracker
   */
  static Tracker create(Message message, Handler!Tracker onUpdated) {
    return new TrackerImpl(message, onUpdated);
  }

  // ===========================

  /**
   * Retrieves the message being tracked.
   *
   * @return the message
   */
  Message message();

  /**
   * Returns whether the message was accepted.
   *
   * Equivalent to: tracker.getRemoteState() instanceof Accepted;
   *
   * @return true if the message was accepted.
   */
  bool isAccepted();

  /**
   * Returns whether the message was settled by the peer.
   *
   * @return true if the message was settled.
   */
  bool isRemotelySettled();

  /**
   * Gets the current remote state for the delivery.
   *
   * @return the remote delivery state
   */
  DeliveryState getRemoteState();
}
