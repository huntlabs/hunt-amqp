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
module hunt.amqp.streams.ProtonSubscriber;

import hunt.proton.amqp.transport.Source;
import hunt.proton.amqp.transport.Target;
import hunt.amqp.streams.Subscriber;

/*
 * An AMQP producer, presented as a reactive streams Subscriber
 */
interface ProtonSubscriber(T) : Subscriber!T {

  /**
   * Sets the local Target details. Only useful to call before subscribing.
   *
   * @param target
   *          the target
   * @return the subscriber
   */
  ProtonSubscriber!T setTarget(Target target);

  /**
   * Retrieves the local Target details for access or customisation.
   *
   * @return the local Target, or null if there was none.
   */
  Target getTarget();

  /**
   * Sets the local Source details. Only useful to call before subscribing.
   *
   * @param source
   *          the source
   * @return the subscriber
   */
  ProtonSubscriber!T setSource(Source source);

  /**
   * Retrieves the local Source details for access or customisation.
   *
   * @return the local Source, or null if there was none.
   */
  Source getSource();
}