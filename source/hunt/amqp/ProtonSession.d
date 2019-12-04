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
module hunt.amqp.ProtonSession;

import hunt.amqp.Handler;
import hunt.proton.amqp.transport.ErrorCondition;
import hunt.proton.engine.Record;
import hunt.amqp.ProtonReceiver;
import hunt.String;
import hunt.amqp.ProtonLinkOptions;
import hunt.amqp.ProtonSender;
import hunt.amqp.ProtonConnection;
/**
 * @author <a href="http://tfox.org">Tim Fox</a>
 */
interface ProtonSession {

  /**
   * Creates a receiver used to consumer messages from the given node address.
   *
   * @param address
   *          The source address to attach the consumer to.
   *
   * @return the (unopened) consumer.
   */
  ProtonReceiver createReceiver(string address);

  /**
   * Creates a receiver used to consumer messages from the given node address.
   *
   * @param address
   *          The source address to attach the consumer to.
   * @param receiverOptions
   *          The options for this receiver.
   *
   * @return the (unopened) consumer.
   */
  ProtonReceiver createReceiver(string address, ProtonLinkOptions receiverOptions);

  /**
   * Creates a sender used to send messages to the given node address. If no address (i.e null) is specified then a
   * sender will be established to the 'anonymous relay' and each message must specify its destination address.
   *
   * @param address
   *          The target address to attach to, or null to attach to the anonymous relay.
   *
   * @return the (unopened) sender.
   */
  ProtonSender createSender(string address);

  /**
   * Creates a sender used to send messages to the given node address. If no address (i.e null) is specified then a
   * sender will be established to the 'anonymous relay' and each message must specify its destination address.
   *
   * @param address
   *          The target address to attach to, or null to attach to the anonymous relay.
   * @param senderOptions
   *          The options for this sender.
   *
   * @return the (unopened) sender.
   */
  ProtonSender createSender(string address, ProtonLinkOptions senderOptions);

  /**
   * Opens the AMQP session, i.e. allows the Begin frame to be emitted. Typically used after any additional
   * configuration is performed on the object.
   *
   * For locally initiated sessions, the {@link #openHandler(Handler)} may be used to handle the peer sending their
   * Begin frame.
   *
   * @return the session
   */
  ProtonSession open();

  /**
   * Closed the AMQP session, i.e. allows the End frame to be emitted.
   *
   * If the closure is being locally initiated, the {@link #closeHandler(Handler)} may be used to handle the peer
   * sending their End frame. When use of the session is complete, i.e it is locally and
   * remotely closed, {@link #free()} must be called to ensure related resources can be tidied up.
   *
   * @return the session
   */
  ProtonSession close();

  /**
   * Retrieves the attachments record, upon which application items can be set/retrieved.
   *
   * @return the attachments
   */
  Record attachments();

  /**
   * Sets the incoming capacity in bytes, used to govern session-level flow control.
   *
   * @param capacity
   *          capacity in bytes
   * @return the session
   */
  ProtonSession setIncomingCapacity(int capacity);

  /**
   * Gets the incoming capacity in bytes, used to govern session-level flow control.
   *
   * @return capacity in bytes
   */
  int getIncomingCapacity();

  /**
   * Gets the connection this session is on.
   *
   * @return the connection
   */
  ProtonConnection getConnection();

  /**
   * Sets the local ErrorCondition object.
   *
   * @param condition
   *          the condition to set
   * @return the session
   */
  ProtonSession setCondition(ErrorCondition condition);

  /**
   * Gets the local ErrorCondition object.
   *
   * @return the condition
   */
  ErrorCondition getCondition();

  /**
   * Gets the remote ErrorCondition object.
   *
   * @return the condition
   */
  ErrorCondition getRemoteCondition();

  /**
   * Sets a handler for when an AMQP Begin frame is received from the remote peer.
   *
   * Typically used by clients, servers rely on {@link ProtonConnection#sessionOpenHandler(Handler)}.
   *
   * @param remoteOpenHandler
   *          the handler
   * @return the session
   */
  ProtonSession openHandler(Handler!ProtonSession remoteOpenHandler);

  /**
   * Sets a handler for when an AMQP End frame is received from the remote peer.
   *
   * @param remoteCloseHandler
   *          the handler
   * @return the session
   */
  ProtonSession closeHandler(Handler!ProtonSession remoteCloseHandler);

  /**
   * Tidies up related session resources when complete with use. Call only after the
   * session is finished with, i.e. locally and remotely closed.
   */
  void free();
}
