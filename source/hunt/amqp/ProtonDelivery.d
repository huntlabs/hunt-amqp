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
module hunt.amqp.ProtonDelivery;

import hunt.proton.amqp.transport.DeliveryState;
import hunt.proton.engine.Record;
import hunt.Boolean;

/**
 * @author <a href="http://tfox.org">Tim Fox</a>
 */
interface ProtonDelivery {

  /**
   * Updates the DeliveryState, and optionally settle the delivery as well.
   *
   * Has no effect if the delivery was previously locally settled.
   *
   * @param state
   *          the delivery state to apply
   * @param settle
   *          whether to {@link #settle()} the delivery at the same time
   * @return itself
   */
  ProtonDelivery disposition(DeliveryState state, bool settle);

  /**
   * Gets the current local state for the delivery.
   *
   * @return the delivery state
   */
  DeliveryState getLocalState();

  /**
   * Gets the current remote state for the delivery.
   *
   * @return the remote delivery state
   */
  DeliveryState getRemoteState();

  /**
   * Settles the delivery locally.
   *
   * @return the delivery
   */
  ProtonDelivery settle();

  /**
   * Gets whether the delivery was locally settled yet.
   *
   * @return whether the delivery is locally settled
   */
  bool isSettled();

  /**
   * Gets whether the delivery was settled by the remote peer yet.
   *
   * @return whether the delivery is remotely settled
   */
  bool remotelySettled();

  /**
   * Retrieves the attachments record, upon which application items can be set/retrieved.
   *
   * @return the attachments
   */
  Record attachments();

  /**
   * Gets the delivery tag for this delivery
   *
   * @return the tag
   */
  byte[] getTag();

  /**
   * Gets the message format for the current delivery.
   *
   * @return the message format
   */
  int getMessageFormat();
}
