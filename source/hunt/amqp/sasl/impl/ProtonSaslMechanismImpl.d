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
module hunt.amqp.sasl.impl.ProtonSaslMechanismImpl;

import hunt.amqp.sasl.ProtonSaslMechanism;

abstract class ProtonSaslMechanismImpl : ProtonSaslMechanism {

  protected static  byte[] EMPTY;

  private string username;
  private string password;

  override
  public int opCmp(ProtonSaslMechanism other) {

    if (getPriority() < other.getPriority()) {
      return -1;
    } else if (getPriority() > other.getPriority()) {
      return 1;
    }

    return 0;
  }

  public ProtonSaslMechanism setUsername(string value) {
    this.username = value;
    return this;
  }

  public string getUsername() {
    return username;
  }

  public ProtonSaslMechanism setPassword(string value) {
    this.password = value;
    return this;
  }

  public string getPassword() {
    return this.password;
  }

  override
  public string toString() {
    return "SASL-" ~ getName();
  }
}
