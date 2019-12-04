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
module hunt.amqp.streams.ProtonPublisher;

import hunt.proton.amqp.transport.Source;
import hunt.proton.amqp.transport.Target;
import hunt.amqp.streams.Publisher;

/*
 * An AMQP consumer, presented as a reactive streams Publisher
 */
interface ProtonPublisher(T) : Publisher!T {

  /**
   * Retrieves the address from the remote source details. Should only be called in callbacks such
   * as on onSubscribe() to ensure detail is populated and safe threading.
   *
   * @return the remote address, or null if there was none.
   */
  string getRemoteAddress();

  /**
   * Sets the local Source details. Only useful to call before subscribing.
   *
   * @param source
   *          the source
   * @return the publisher
   */
  ProtonPublisher!T setSource(Source source);

  /**
   * Retrieves the local Source details for access or customisation.
   *
   * @return the local Source, or null if there was none.
   */
  Source getSource();

  /**
   * Sets the local Target details. Only useful to call before subscribing.
   *
   * @param target
   *          the target
   * @return the publisher
   */
  ProtonPublisher!T setTarget(Target target);

  /**
   * Retrieves the local Target details for access or customisation.
   *
   * @return the local Target, or null if there was none.
   */
  Target getTarget();

  /**
   * Retrieves the remote Source details. Should only be called in callbacks such
   * as on onSubscribe() to ensure detail is populated and safe threading.
   *
   * @return the remote Source, or null if there was none.
   */
  Source getRemoteSource();

  /**
   * Retrieves the remote Target details. Should only be called in callbacks such
   * as on onSubscribe() to ensure detail is populated and safe threading.
   *
   * @return the remote Target, or null if there was none.
   */
  Target getRemoteTarget();
}