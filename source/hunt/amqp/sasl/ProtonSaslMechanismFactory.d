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
module hunt.amqp.sasl.ProtonSaslMechanismFactory;
import hunt.amqp.sasl.ProtonSaslMechanism;

interface ProtonSaslMechanismFactory {

  /**
   * Creates an instance of the authentication mechanism implementation.
   *
   * @return a new mechanism instance.
   */
  ProtonSaslMechanism createMechanism();

  /**
   * Get the name of the mechanism supported by the factory
   *
   * @return the name of the mechanism
   */
  string getMechanismName();
}
