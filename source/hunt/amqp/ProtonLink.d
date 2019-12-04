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
module hunt.amqp.ProtonLink;


import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.UnsignedLong;
import hunt.proton.amqp.transport.ErrorCondition;
import hunt.proton.amqp.transport.Source;
import hunt.proton.amqp.transport.Target;
import hunt.amqp.Handler;
import hunt.collection.Map;
import hunt.amqp.ProtonQoS;
import hunt.amqp.ProtonSession;
import hunt.proton.engine.Record;
/**
 * @author <a href="http://tfox.org">Tim Fox</a>
 */
interface ProtonLink(T) {

  /**
   * Opens the AMQP link, i.e. allows the Attach frame to be emitted. Typically used after any additional configuration
   * is performed on the object.
   *
   * For locally initiated links, the {@link #openHandler(Handler)} may be used to handle the peer sending their Attach
   * frame.
   *
   * @return the link
   */
  T open();

  /**
   * Closes the AMQP link, i.e. allows the Detach frame to be emitted with closed=true set.
   *
   * If the closure is being locally initiated, the {@link #closeHandler(Handler)} should be used to handle the peer
   * sending their Detach frame with closed=true (and {@link #detachHandler(Handler)} can be used to handle the peer
   * sending their Detach frame with closed=false). When use of the link is complete, i.e it is locally and
   * remotely closed, {@link #free()} must be called to ensure related resources can be tidied up.
   *
   * @return the link
   */
  T close();

  /**
   * Detaches the AMQP link, i.e. allows the Detach frame to be emitted with closed=false.
   *
   * If the detach is being locally initiated, the {@link #detachHandler(Handler)} should be used to handle the peer
   * sending their Detach frame with closed=false (and {@link #closeHandler(Handler)} can be used to handle the peer
   * sending their Detach frame with closed=true). When use of the link is complete, i.e it is locally and
   * remotely detached, {@link #free()} must be called to ensure related resources can be tidied up.
   *
   * @return the link
   */
  T detach();

  /**
   * Sets a handler for when an AMQP Attach frame is received from the remote peer.
   *
   * Typically used by clients, servers rely on {@link ProtonConnection#senderOpenHandler(Handler)} and
   * {@link ProtonConnection#receiverOpenHandler(Handler)}.
   *
   * @param remoteOpenHandler
   *          the handler
   * @return the link
   */
  T openHandler(Handler!T remoteOpenHandler);
 // T openHandler();
  /**
   * Sets a handler for when an AMQP Detach frame with closed=true is received from the remote peer.
   *
   * @param remoteCloseHandler
   *          the handler
   * @return the link
   */
   T closeHandler(Handler!T remoteCloseHandler);
 // T closeHandler();

  /**
   * Sets a handler for when an AMQP Detach frame with closed=false is received from the remote peer.
   *
   * @param remoteDetachHandler
   *          the handler
   * @return the link
   */
  T detachHandler(Handler!T remoteDetachHandler);
  //T detachHandler();

  /**
   * Gets the local QOS config.
   *
   * @return the QOS config
   */
  ProtonQoS getQoS();

  /**
   * Sets the local QOS config.
   *
   * @param qos
   *          the QOS to configure
   * @return the link
   */
  T setQoS(ProtonQoS qos);

  /**
   * Gets the remote QOS config.
   *
   * @return the QOS config
   */
  ProtonQoS getRemoteQoS();

  /**
   * Check whether the link is locally open.
   *
   * @return whether the link is locally open.
   */
  bool isOpen();

  /**
   * Retrieves the attachments record, upon which application items can be set/retrieved.
   *
   * @return the attachments
   */
  Record attachments();

  /**
   * Gets the current local target config.
   *
   * @return the target
   */
  Target getTarget();

  /**
   * Sets the current local target config. Only useful to call before the link has locally opened.
   *
   * @param target
   *          the target
   * @return the link
   */
  T setTarget(Target target);

  /**
   * Gets the current remote target config. Only useful to call after the link has remotely opened.
   *
   * @return the target
   */
  Target getRemoteTarget();

  /**
   * Gets the current local source config.
   *
   * @return the source
   */
  Source getSource();

  /**
   * Sets the current local source config. Only useful to call before the link has locally opened.
   *
   * @param source
   *          the source
   * @return the link
   */
  T setSource(Source source);

  /**
   * Gets the current remote source config. Only useful to call after the link has remotely opened.
   *
   * @return the target
   */
  Source getRemoteSource();

  /**
   * Gets the session this link is on.
   * @return the session
   */
  ProtonSession getSession();

  /**
   * Retrieves the remote address from the remote terminus (source for receivers, target for senders).
   * Only useful to call after the link has remotely opened.
   *
   * @return the remote address, or null if there was none.
   */
  string getRemoteAddress();

  /**
   * Sets the local ErrorCondition object.
   *
   * @param condition
   *          the condition to set
   * @return the link
   */
  T setCondition(ErrorCondition condition);

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
   * Retrieves the current amount of credit.
   *
   * For a receiver link, the value returned will still include the credits that will be used by any queued
   * incoming messages, use {@link #getQueued()} to assess the number of credits that will be used by queued messages.
   *
   * @return the number of credits
   */
  int getCredit();

  /**
   * Retrieves the current value of link 'drain' flag.
   *
   * @return when the link drain flag is set.
   */
  bool getDrain();

  /**
   * Retrieves the current number of queued messages.
   *
   * For a receiver link, this is the number of messages that have already arrived locally but not yet been processed.
   *
   * @return the number of queues messages
   */
  int getQueued();

  /**
   * Retrieves the link name
   *
   * @return  the link name
   */
  string getName();

  /**
   * Sets the local link max message size, to be conveyed to the peer via the Attach frame
   * when attaching the link to the session. Null or 0 means no limit.
   *
   * Must be called during link setup, i.e. before calling the {@link #open()} method.
   *
   * @param maxMessageSize
   *            the local max message size value, or null to clear. 0 also means no limit.
   */
  void setMaxMessageSize(UnsignedLong maxMessageSize);

  /**
   * Gets the local link max message size.
   *
   * @return the local max message size, or null if none was set. 0 also means no limit.
   *
   * @see #setMaxMessageSize(UnsignedLong)
   */
  UnsignedLong getMaxMessageSize();

  /**
   * Gets the remote link max message size, as conveyed from the peer via the Attach frame
   * when attaching the link to the session.
   *
   * @return the remote max message size conveyed by the peer, or null if none was set. 0 also means no limit.
   */
  UnsignedLong getRemoteMaxMessageSize();


  /**
   * Sets the link properties, to be conveyed to the peer via the Attach frame
   * when attaching the link to the session.
   *
   * Must be called during link setup, i.e. before calling the {@link #open()} method.
   *
   * @param properties the properties of the link to be coveyed to the remote peer.
   */
  void setProperties(Map!(Symbol, Object) properties);

  /**
   * Gets the remote link properties, as conveyed from the peer via the Attach frame
   * when attaching the link to the session.
   *
   * @return the remote link properties conveyed by the peer, or null if none was set.
   */
  Map!(Symbol, Object) getRemoteProperties();


  /**
   * Sets the offered capabilities, to be conveyed to the peer via the Attach frame
   * when attaching the link to the session.
   *
   * Must be called during link setup, i.e. before calling the {@link #open()} method.
   *
   * @param capabilities the capabilities offered to the remote peer.
   */
  void setOfferedCapabilities(Symbol[] capabilities);

  /**
   * Gets the remote offered capabilities, as conveyed from the peer via the Attach frame
   * when attaching the link to the session.
   *
   * @return the remote offered capabilities conveyed by the peer, or null if none was set.
   */
  Symbol[] getRemoteOfferedCapabilities();

  /**
   * Sets the desired capabilities, to be conveyed to the peer via the Attach frame
   * when attaching the link to the session.
   *
   * Must be called during link setup, i.e. before calling the {@link #open()} method.
   *
   * @param capabilities the capabilities desired of the remote peer.
   */
  void setDesiredCapabilities(Symbol[] capabilities);

  /**
   * Gets the remote desired capabilities, as conveyed from the peer via the Attach frame
   * when attaching the link to the session.
   *
   * @return the remote desired capabilities conveyed by the peer, or null if none was set.
   */
  Symbol[] getRemoteDesiredCapabilities();

  /**
   * Tidies up related link resources when complete with use. Call only after the link is
   * finished with, e.g. locally and remotely closed.
   */
  void free();
}
