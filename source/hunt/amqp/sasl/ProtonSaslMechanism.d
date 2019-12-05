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
module hunt.amqp.sasl.ProtonSaslMechanism;

import  hunt.util.Common;
import  hunt.Enum;
import std.concurrency : initOnce;

class PRIORITY  : AbstractEnum!PRIORITY
{
  //LOWEST(0), LOWER(1), LOW(2), MEDIUM(3), HIGH(4), HIGHER(5), HIGHEST(6);

  static PRIORITY  LOWEST() {
    __gshared PRIORITY  inst;
    return initOnce!inst(new PRIORITY("LOWEST" ,0));
  }

  static PRIORITY  LOWER() {
    __gshared PRIORITY  inst;
    return initOnce!inst(new PRIORITY("LOWER" ,1));
  }
  static PRIORITY  LOW() {
    __gshared PRIORITY  inst;
    return initOnce!inst(new PRIORITY("LOW" ,2));
  }

  static PRIORITY  MEDIUM() {
    __gshared PRIORITY  inst;
    return initOnce!inst(new PRIORITY("MEDIUM" ,3));
  }

  static PRIORITY  HIGH() {
    __gshared PRIORITY  inst;
    return initOnce!inst(new PRIORITY("HIGH" ,4));
  }

  static PRIORITY  HIGHER() {
    __gshared PRIORITY  inst;
    return initOnce!inst(new PRIORITY("HIGHER" ,5));
  }

  static PRIORITY  HIGHEST() {
    __gshared PRIORITY  inst;
    return initOnce!inst(new PRIORITY("HIGHEST" ,6));
  }


  private int value;

  this(string name , int value) {
    super(name ,value);
    this.value = value;
  }

  public int getValue() {
    return value;
  }

};


interface ProtonSaslMechanism : Comparable!ProtonSaslMechanism {

  /**
   * Relative priority values used to arrange the found SASL mechanisms in a preferred order where the level of security
   * generally defines the preference.
   */


  /**
   * @return return the relative priority of this SASL mechanism.
   */
  int getPriority();

  /**
   * @return the well known name of this SASL mechanism.
   */
  string getName();

  /**
   * Create an initial response based on selected mechanism.
   *
   * May be null if there is no initial response.
   *
   * @return the initial response, or null if there isn't one.
   * @throws SaslException
   *           if an error occurs computing the response.
   */
  byte[] getInitialResponse() ;

  /**
   * Create a response based on a given challenge from the remote peer.
   *
   * @param challenge
   *          the challenge that this Mechanism should response to.
   *
   * @return the response that answers the given challenge.
   * @throws SaslException
   *           if an error occurs computing the response.
   */
  byte[] getChallengeResponse(byte[] challenge);

  /**
   * Sets the user name value for this Mechanism. The Mechanism can ignore this value if it does not utilize user name
   * in it's authentication processing.
   *
   * @param username
   *          The user name given.
   * @return the mechanism.
   */
  ProtonSaslMechanism setUsername(string username);

  /**
   * Returns the configured user name value for this Mechanism.
   *
   * @return the currently set user name value for this Mechanism.
   */
  string getUsername();

  /**
   * Sets the password value for this Mechanism. The Mechanism can ignore this value if it does not utilize a password
   * in it's authentication processing.
   *
   * @param username
   *          The user name given.
   * @return the mechanism.
   */
  ProtonSaslMechanism setPassword(string username);

  /**
   * Returns the configured password value for this Mechanism.
   *
   * @return the currently set password value for this Mechanism.
   */
  string getPassword();

  /**
   * Checks whether a given mechanism is suitable for use in light of the available credentials.
   *
   * @param username
   *          the username
   * @param password
   *          the password
   * @return whether mechanism is applicable
   */
  bool isApplicable(string username, string password);
}
