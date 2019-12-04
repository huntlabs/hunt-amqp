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
module hunt.amqp.streams.Delivery;
import hunt.proton.amqp.transport.DeliveryState;
import hunt.proton.message.Message;

interface Delivery {

  /**
   * Retrieve the message object carried by this delivery.
   *
   * @return the message
   */
  Message message();

  /**
   * Accepts (and settles) this message delivery.
   *
   * Equivalent to calling disposition(Accepted.getInstance(), true);
   *
   * @return the delivery
   */
  Delivery accept();

  /**
   * Updates the DeliveryState, and optionally settle the delivery as well.
   *
   * @param state
   *          the delivery state to apply
   * @param settle
   *          whether to settle the delivery at the same time
   * @return the delivery
   */
  Delivery disposition(DeliveryState state, bool settle);
}
