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
module hunt.amqp.impl.ProtonSaslServerAuthenticatorImpl;

import hunt.amqp.ProtonConnection;
import hunt.amqp.sasl.ProtonSaslAuthenticator;
import hunt.proton.engine.Sasl;
import hunt.proton.engine.Transport;

import hunt.amqp.sasl.impl.ProtonSaslAnonymousImpl;

/**
 * Manage the SASL authentication process
 */
//class ProtonSaslServerAuthenticatorImpl : ProtonSaslAuthenticator {
//
//  private Sasl sasl;
//  private boolean succeeded;
//
//  @Override
//  public void init(NetSocket socket, ProtonConnection protonConnection, Transport transport) {
//    this.sasl = transport.sasl();
//    sasl.server();
//    sasl.allowSkip(false);
//    sasl.setMechanisms(ProtonSaslAnonymousImpl.MECH_NAME);
//    succeeded = false;
//  }
//
//  @Override
//  public void process(Handler<Boolean> completionHandler) {
//    if (sasl is null) {
//      throw new IllegalStateException("Init was not called with the associated transport");
//    }
//
//    boolean done = false;
//    String[] remoteMechanisms = sasl.getRemoteMechanisms();
//    if (remoteMechanisms.length > 0) {
//      String chosen = remoteMechanisms[0];
//      if (ProtonSaslAnonymousImpl.MECH_NAME.equals(chosen)) {
//        sasl.done(SaslOutcome.PN_SASL_OK);
//        succeeded = true;
//      } else {
//        sasl.done(SaslOutcome.PN_SASL_AUTH);
//      }
//      done = true;
//    }
//
//    completionHandler.handle(done);
//  }
//
//  @Override
//  public boolean succeeded() {
//    return succeeded;
//  }
//}
