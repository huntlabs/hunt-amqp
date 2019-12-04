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
module hunt.amqp.sasl.ProtonSaslAuthenticatorFactory;

import hunt.amqp.sasl.ProtonSaslAuthenticator;
interface ProtonSaslAuthenticatorFactory {

  /**
   * Create a ProtonSaslAuthenticator for use with a connection.
   *
   * @return the authenticator
   */
  ProtonSaslAuthenticator create();
}