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
module hunt.amqp.ProtonClient;

import hunt.amqp.Handler;
import hunt.amqp.impl.ProtonClientImpl;
import hunt.amqp.ProtonConnection;
import hunt.amqp.ProtonClientOptions;
/**
 * @author <a href="http://tfox.org">Tim Fox</a>
 */
interface ProtonClient {

  /**
   * Create a ProtonClient instance with the given Vertx instance.
   *
   * @param vertx
   *          the vertx instance to use
   * @return the client instance
   */
  static ProtonClient create() {
    return new ProtonClientImpl();
  }

  /**
   * Connect to the given host and port, without credentials.
   *
   * @param host
   *          the host to connect to
   * @param port
   *          the port to connect to
   * @param connectionHandler
   *          handler that will process the result, giving either the (unopened) ProtonConnection or failure cause.
   */
  void connect(string host, int port, Handler!ProtonConnection connectionHandler);

  /**
   * Connect to the given host and port, with credentials (if required by server peer).
   *
   * @param host
   *          the host to connect to
   * @param port
   *          the port to connect to
   * @param username
   *          the user name to use in any SASL negotiation that requires it
   * @param password
   *          the password to use in any SASL negotiation that requires it
   * @param connectionHandler
   *          handler that will process the result, giving either the (unopened) ProtonConnection or failure cause.
   */
  void connect(string host, int port, string username, string password,
               Handler!ProtonConnection connectionHandler);

  /**
   * Connect to the given host and port, without credentials.
   *
   * @param options
   *          the options to apply
   * @param host
   *          the host to connect to
   * @param port
   *          the port to connect to
   * @param connectionHandler
   *          handler that will process the result, giving either the (unopened) ProtonConnection or failure cause.
   */
  void connect(ProtonClientOptions options, string host, int port,
               Handler!ProtonConnection connectionHandler);

  /**
   * Connect to the given host and port, with credentials (if required by server peer).
   *
   * @param options
   *          the options to apply
   * @param host
   *          the host to connect to
   * @param port
   *          the port to connect to
   * @param username
   *          the user name to use in any SASL negotiation that requires it
   * @param password
   *          the password to use in any SASL negotiation that requires it
   * @param connectionHandler
   *          handler that will process the result, giving either the (unopened) ProtonConnection or failure cause.
   */
  void connect(ProtonClientOptions options, string host, int port, string username, string password,
               Handler!ProtonConnection connectionHandler);
}
