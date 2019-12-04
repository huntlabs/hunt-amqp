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
module hunt.amqp.sasl.impl.ProtonSaslPlainImpl;

import hunt.amqp.sasl.impl.ProtonSaslMechanismImpl;
import hunt.amqp.sasl.ProtonSaslMechanism;

class ProtonSaslPlainImpl : ProtonSaslMechanismImpl {

  public static  string MECH_NAME = "PLAIN";

  public int getPriority() {
    return PRIORITY.LOWER.getValue();
  }

  public string getName() {
    return MECH_NAME;
  }

  public byte[] getInitialResponse() {

    string username = getUsername();
    string password = getPassword();

    if (username is null) {
      username = "";
    }

    if (password is null) {
      password = "";
    }

    byte[] usernameBytes = cast(byte[])username;
    byte[] passwordBytes = cast(byte[])password;
    byte[] data = new byte[usernameBytes.length + passwordBytes.length + 2];
    //System.arraycopy(usernameBytes, 0, data, 1, usernameBytes.length);
    data[1 .. 1+usernameBytes.length] = usernameBytes[0 ..usernameBytes.length];
    //System.arraycopy(passwordBytes, 0, data, 2 + usernameBytes.length, passwordBytes.length);
    data[2 + usernameBytes.length .. 2 + usernameBytes.length + passwordBytes.length] = passwordBytes[0 ..passwordBytes.length ];
    return data;
  }

  public byte[] getChallengeResponse(byte[] challenge) {
    return EMPTY;
  }

  public bool isApplicable(string username, string password) {
    return username !is null && username.length > 0 && password !is null && password.length > 0;
  }
}
