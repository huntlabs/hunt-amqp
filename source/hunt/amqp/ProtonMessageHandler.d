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
module hunt.amqp.ProtonMessageHandler;

import hunt.proton.message.Message;
import hunt.amqp.ProtonDelivery;
/**
 * @author <a href="http://hiramchirino.com">Hiram Chirino</a>
 */
interface ProtonMessageHandler {

  /**
   * Handler to process messages and their related deliveries.
   *
   * @param delivery
   *          the delivery used to carry the message
   * @param message
   *          the message
   */
  void handle(ProtonDelivery delivery, Message message);
}