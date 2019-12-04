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
module hunt.amqp.sasl.impl.ProtonSaslMechanismFinderImpl;

import hunt.collection.ArrayList;
import hunt.collection.Collections;
import hunt.collection.List;
import hunt.collection.Set;
import hunt.logging;
import hunt.amqp.sasl.ProtonSaslMechanism;
import hunt.amqp.sasl.ProtonSaslMechanismFactory;
import hunt.amqp.sasl.impl.ProtonSaslPlainImpl;
import hunt.amqp.sasl.impl.ProtonSaslAnonymousImpl;
import hunt.amqp.sasl.impl.ProtonSaslPlainFactoryImpl;
import hunt.amqp.sasl.impl.ProtonSaslAnonymousFactoryImpl;
import hunt.amqp.sasl.impl.ProtonSaslExternalImpl;
import hunt.amqp.sasl.impl.ProtonSaslExternalFactoryImpl;

class ProtonSaslMechanismFinderImpl {

  //private static Logger LOG = LoggerFactory.getLogger(ProtonSaslMechanismFinderImpl.class);

  /**
   * Attempts to find a matching Mechanism implementation given a list of supported mechanisms from a remote peer. Can
   * return null if no matching Mechanisms are found.
   *
   * @param username
   *          the username, or null if there is none
   * @param password
   *          the password, or null if there is none
   * @param mechRestrictions
   *          The possible mechanism(s) to which the client should restrict its mechanism selection to if offered by the
   *          server, or null/empty if there is no restriction
   * @param remoteMechanisms
   *          list of mechanism names that are supported by the remote peer.
   *
   * @return the best matching Mechanism for the supported remote set.
   */
  public static ProtonSaslMechanism findMatchingMechanism(string username, string password,
                                                          Set!string mechRestrictions, string [] remoteMechanisms) {

    ProtonSaslMechanism match = null;
    List!ProtonSaslMechanism found = new ArrayList!ProtonSaslMechanism();

    foreach (string remoteMechanism ; remoteMechanisms) {
      ProtonSaslMechanismFactory factory = findMechanismFactory(remoteMechanism);
      if (factory !is null) {
        ProtonSaslMechanism mech = factory.createMechanism();
        if (mechRestrictions !is null && !mechRestrictions.isEmpty() && !mechRestrictions.contains(remoteMechanism)) {
          //if (LOG.isTraceEnabled()) {
          //  LOG.trace("Skipping " + remoteMechanism + " mechanism because it is not in the configured mechanisms restriction set");
          //}
        } else if (mech.isApplicable(username, password)) {
          found.add(mech);
        } else {
          //if (LOG.isTraceEnabled()) {
          //  LOG.trace("Skipping " + mech + " mechanism because the available credentials are not sufficient");
          //}
        }
      }
    }

    if (!found.isEmpty()) {
      // Sorts by priority using mechanism comparison and return the last value in
      // list which is the mechanism deemed to be the highest priority match.
     // Collections.sort(found);
      match = found.get(found.size() - 1);
    }

    //if (LOG.isTraceEnabled()) {
    //  LOG.trace("Best match for SASL auth was: " + match);
    //}

    return match;
  }

  /**
   * Searches for a mechanism factory by using the scheme from the given name.
   *
   * @param name
   *          The name of the authentication mechanism to search for.
   *
   * @return a mechanism factory instance matching the name, or null if none was created.
   */
  protected static ProtonSaslMechanismFactory findMechanismFactory(string name) {
    if (name is null || name.length ==0) {
     // LOG.warn("No SASL mechanism name was specified");
      logError("No SASL mechanism name was specified");
      return null;
    }

    ProtonSaslMechanismFactory factory = null;

    // TODO: make it pluggable?
    if (ProtonSaslPlainImpl.MECH_NAME == (name)) {
      factory = new ProtonSaslPlainFactoryImpl();
    } else if (ProtonSaslAnonymousImpl.MECH_NAME == (name)) {
      factory = new ProtonSaslAnonymousFactoryImpl();
    } else if (ProtonSaslExternalImpl.MECH_NAME == (name)) {
      factory = new ProtonSaslExternalFactoryImpl();
    }

    return factory;
  }
}
