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
module hunt.amqp.streams.ProtonPublisherOptions;


/**
 * Options for configuring Publisher attributes.
 */
class ProtonPublisherOptions {
  private string linkName;
  private bool durable;
  private bool _shared;
  private bool global;
  private bool dynamic;
  private int maxOutstandingCredit;

  this() {
  }

  /**
   * Sets the link name to be used for the subscription.
   *
   * @param linkName the name to use
   * @return the options
   */
  public ProtonPublisherOptions setLinkName(string linkName) {
    this.linkName = linkName;
    return this;
  }

  public string getLinkName() {
    return linkName;
  }

  /**
   * Sets whether the link to be used for the subscription should
   * have 'source' terminus details indicating it is durable, that
   * is a terminus-expiry-policy of "never" and terminus-durability
   * of 2/unsettled-state, and that the link should detach rather than
   * close when cancel is called on the subscription.
   *
   * @param durable true if the subscription should be considered durable
   * @return the options
   */
  public ProtonPublisherOptions setDurable(bool durable) {
    this.durable = durable;
    return this;
  }

  public bool isDurable() {
    return durable;
  }

  /**
   * Sets whether the link to be used for the subscription should
   * have 'source' terminus capability indicating it is 'shared'.
   *
   * @param shared true if the subscription should be considered shared
   * @return the options
   */
  public ProtonPublisherOptions setShared(bool sd) {
    this._shared = sd;
    return this;
  }

  public bool isShared() {
    return _shared;
  }

  /**
   * Sets whether the link to be used for a shared subscription should
   * also have 'source' terminus capability indicating it is 'global',
   * that is its subscription can be shared across connections
   * regardless of their container-id values.
   *
   * @param global true if the subscription should be considered global
   * @return the options
   */
  public ProtonPublisherOptions setGlobal(bool global) {
    this.global = global;
    return this;
  }

  public bool isGlobal() {
    return global;
  }

  /**
   * Sets whether the link to be used for the subscription should indicate
   * a 'dynamic' source terminus, requesting the server peer names it with
   * a dynamic address. The remote address can then be inspected using
   * {@link ProtonPublisher#getRemoteAddress()} (or inspecting the remote
   * source details directly) when the onSubscribe() handler is fired.
   *
   * @param dynamic true if the link should request a dynamic source address
   * @return the options
   */
  public ProtonPublisherOptions setDynamic(bool dynamic) {
    this.dynamic = dynamic;
    return this;
  }

  public bool isDynamic() {
    return dynamic;
  }

  /**
   * Sets the maximum credit the consumer link will leave outstanding at a time.
   * If the total unfilled subscription requests remains below this level, the
   * consumer credit issued will match the unfilled requests. If the requests
   * exceeds this value, the consumer link will cap it and refresh it once the
   * level drops below a threshold or more requests are made. If not set a
   * reasonable default is used.
   *
   * @param maxOutstandingCredit the limit on outstanding consumer credit
   * @return the options
   */
  public ProtonPublisherOptions setMaxOutstandingCredit(int maxOutstandingCredit) {
    this.maxOutstandingCredit = maxOutstandingCredit;

    return this;
  }

  public int getMaxOutstandingCredit() {
    return maxOutstandingCredit;
  }


  override size_t toHash() @trusted nothrow
  {
    int prime = 31;

    int result = 1;
    result = prime * result + cast(int)linkName.hashOf;
    result = prime * result + (durable ? 1231 : 1237);
    result = prime * result + (_shared ? 1231 : 1237);
    result = prime * result + (global ? 1231 : 1237);
    result = prime * result + (dynamic ? 1231 : 1237);
    result = prime * result + maxOutstandingCredit;

    return cast(size_t)result;
  }

  override
  public bool opEquals(Object obj) {
    if (this is obj) {
      return true;
    }

    if (obj is null){
      return false;
    }

    ProtonPublisherOptions other = cast(ProtonPublisherOptions) obj;
    if ((linkName != other.linkName)){
      return false;
    }

    if (durable != other.durable){
      return false;
    }

    if (_shared != other._shared){
      return false;
    }

    if (global != other.global){
      return false;
    }

    if (dynamic != other.dynamic){
      return false;
    }

    if (maxOutstandingCredit != other.maxOutstandingCredit){
      return false;
    }

    return true;
  }
}
