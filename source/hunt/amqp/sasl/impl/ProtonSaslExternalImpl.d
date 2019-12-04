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
module hunt.amqp.sasl.impl.ProtonSaslExternalImpl;
import hunt.amqp.sasl.impl.ProtonSaslMechanismImpl;
import hunt.amqp.sasl.ProtonSaslMechanism;

class ProtonSaslExternalImpl : ProtonSaslMechanismImpl {

  public static  string MECH_NAME = "EXTERNAL";

  public byte[] getInitialResponse() {
    return EMPTY;
  }

  public byte[] getChallengeResponse(byte[] challenge) {
    return EMPTY;
  }

  public int getPriority() {
    return PRIORITY.HIGHER.getValue();
  }

  public string getName() {
    return MECH_NAME;
  }

  public bool isApplicable(string username, string password) {
    return true;
  }
}
