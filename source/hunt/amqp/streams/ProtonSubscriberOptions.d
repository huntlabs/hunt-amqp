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
module hunt.amqp.streams.ProtonSubscriberOptions;


/**
 * Options for configuring Subscriber attributes.
 */
class ProtonSubscriberOptions {
  private string linkName;

  this() {
  }

  /**
   * Sets the link name to be used for the producer.
   *
   * @param linkName the name to use
   * @return the options
   */
  public ProtonSubscriberOptions setLinkName(string linkName) {
    this.linkName = linkName;
    return this;
  }

  public string getLinkName() {
    return linkName;
  }

  override size_t toHash() @safe nothrow
  {
     int prime = 31;

    int result = 1;
    result = prime * result + cast(int)(linkName.hashOf);

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

    ProtonSubscriberOptions other = cast(ProtonSubscriberOptions) obj;
    if ((linkName != other.linkName)){
      return false;
    }

    return true;
  }
}
