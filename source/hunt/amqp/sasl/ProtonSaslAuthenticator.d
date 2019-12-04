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
module hunt.amqp.sasl.ProtonSaslAuthenticator;

import hunt.amqp.Handler;
import hunt.amqp.ProtonConnection;
import hunt.proton.engine.Transport;
import hunt.net.Connection;

alias NetSocket = hunt.net.Connection;

interface ProtonSaslAuthenticator {

  void init(Connection socket, ProtonConnection protonConnection, Transport transport);

  /**
   * Process the SASL authentication cycle until such time as an outcome is determined. This should be called by the
   * managing entity until a completion handler result value is true indicating that the handshake has completed
   * (successfully or otherwise). The result can then be verified by calling {@link #succeeded()}.
   *
   * Any processing of the connection and/or transport objects MUST occur on the calling {@link Context}, and the
   * completion handler MUST be invoked on this same context also. If the completion handler is called on another
   * context an {@link IllegalStateException} will be thrown.
   *
   * @param completionHandler
   *          handler to call when processing of the current state is complete. Value given is true if the SASL
   *          handshake completed.
   */
  void process(Handler!bool completionHandler);

  /**
   * Once called after process finished it returns true if the authentication succeeded.
   *
   * @return true if auth succeeded
   */
  bool succeeded();
}