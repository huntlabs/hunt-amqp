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
module hunt.amqp.impl.ProtonSaslClientAuthenticatorImpl;

import hunt.collection.Set;

//import javax.security.sasl.AuthenticationException;
//import javax.security.sasl.SaslException;

import hunt.amqp.sasl.MechanismMismatchException;
import hunt.amqp.sasl.ProtonSaslAuthenticator;
import hunt.proton.engine.Sasl;
import hunt.proton.engine.Transport;

import hunt.amqp.Handler;
import hunt.amqp.ProtonConnection;
import hunt.amqp.sasl.ProtonSaslMechanism;
import hunt.amqp.sasl.SaslSystemException;
import hunt.amqp.sasl.impl.ProtonSaslMechanismFinderImpl;
import hunt.net.Connection;
import hunt.Exceptions;
import hunt.logging;

alias NetSocket = hunt.net.Connection;
/**
 * Manage the client side of the SASL authentication process.
 */
class ProtonSaslClientAuthenticatorImpl : ProtonSaslAuthenticator {

  private Sasl sasl;
  private  string username;
  private  string password;
  private ProtonSaslMechanism mechanism;
  private Set!string mechanismsRestriction;
  private Handler!ProtonConnection handler;
  private NetSocket.Connection socket;
  private ProtonConnection connection;
  private bool _succeeded;

  /**
   * Create the authenticator and initialize it.
   *
   * @param username
   *          The username provide credentials to the remote peer, or null if there is none.
   * @param password
   *          The password provide credentials to the remote peer, or null if there is none.
   * @param allowedSaslMechanisms
   *          The possible mechanism(s) to which the client should restrict its mechanism selection to if offered by the
   *          server, or null/empty if no restriction.
   * @param handler
   *          The handler to convey the result of the SASL process to.
   *          The async result will succeed if the SASL handshake completed successfully, it will fail with
   *          <ul>
   *          <li>a {@link MechanismMismatchException} if this client does not support any of the SASL
   *          mechanisms offered by the server,</li>
   *          <li>a {@link SaslSystemException} if the SASL handshake fails with either of the
   *          {@link SaslOutcome#PN_SASL_SYS}, {@link SaslOutcome#PN_SASL_TEMP} or
   *          {@link SaslOutcome#PN_SASL_PERM} outcomes,</li>
   *          <li>a {@code javax.security.sasl.AuthenticationException} if the handshake fails with
   *          the {@link SaslOutcome#PN_SASL_AUTH} outcome or</li>
   *          <li>a generic {@code javax.security.sasl.SaslException} if the handshake fails due to
   *          any other reason.</li>
   *          </ul>
   */
  this(string username, string password, Set!string allowedSaslMechanisms ,Handler!ProtonConnection handler) {
    this.handler = handler;
    this.username = username;
    this.password = password;
    this.mechanismsRestriction = allowedSaslMechanisms;
  }

  public void init(NetSocket.Connection socket, ProtonConnection protonConnection, Transport transport) {
    this.socket = socket;
    this.connection = protonConnection;
    this.sasl = transport.sasl();
    sasl.client();
  }

  public void process(Handler!bool completionHandler) {
    if (sasl is null) {
      throw new IllegalStateException("Init was not called with the associated transport");
    }

    bool done = false;
    _succeeded = false;

    try {
      switch (sasl.getState()) {
      case SaslState.PN_SASL_IDLE:
        handleSaslInit();
        break;
      case SaslState.PN_SASL_STEP:
        handleSaslStep();
        break;
      case SaslState.PN_SASL_FAIL:
        handleSaslFail();
        break;
      case SaslState.PN_SASL_PASS:
        done = true;
        _succeeded = true;
        version(HUNT_DEBUG) logInfo("PN_SASL_PASS !!!");
        handler.handle(connection);
        break;
      default:
        break;
      }
    } catch (Exception e) {
      done = true;
      try {
        if (socket !is null) {
          socket.close();
        }
      } finally {
      //  handler.handle(Future.failedFuture(e));
      }
    }

    completionHandler.handle(done);
  }

  public bool succeeded() {
    return _succeeded;
  }

  private void handleSaslInit() {
    string[] remoteMechanisms = sasl.getRemoteMechanisms();
    if (remoteMechanisms !is null && remoteMechanisms.length != 0) {
      mechanism = ProtonSaslMechanismFinderImpl.findMatchingMechanism( username, password, mechanismsRestriction,
      remoteMechanisms);
      if (mechanism !is null) {
        mechanism.setUsername( username);
        mechanism.setPassword( password);

        sasl.setMechanisms( [ mechanism.getName()]);
        byte[] response = mechanism.getInitialResponse();
      //  if (response !is null) {
          sasl.send( response, 0, cast(int)(response.length));
        //}
      } else {
        //  throw new MechanismMismatchException(
        //      "Could not find a suitable SASL mechanism for the remote peer using the available credentials.",
        //      remoteMechanisms);
        //}
        logError( "Could not find a suitable SASL mechanism for the remote peer using the available credentials.");
      }
    }
  }

  private void handleSaslStep()  {
    if (sasl.pending() != 0) {
      byte[] challenge = new byte[sasl.pending()];
      sasl.recv(challenge, 0, cast(int)challenge.length);
      byte[] response = mechanism.getChallengeResponse(challenge);
      sasl.send(response, 0, cast(int)response.length);
    }
  }

  private void handleSaslFail() {

    SaslOutcome tmp = sasl.getOutcome();
    if (tmp == SaslOutcome.PN_SASL_AUTH)
    {
      logError("Failed to authenticate");
    }
    else if (tmp == SaslOutcome.PN_SASL_SYS || tmp == SaslOutcome.PN_SASL_TEMP)
    {
      logError("SASL handshake failed due to a transient error");
    }
    else if (tmp == SaslOutcome.PN_SASL_PERM)
    {
      logError("SASL handshake failed due to an unrecoverable error");
    }else
    {
      logError("SASL handshake failed");
    }

    //switch(sasl.getOutcome()) {
    //case PN_SASL_AUTH:
    //    logError("Failed to authenticate");
    //    break;
    // // throw new SaslSystemException("Failed to authenticate");
    //case PN_SASL_SYS:
    //  goto case;
    //case PN_SASL_TEMP:
    //    logError("SASL handshake failed due to a transient error");
    //    break;
    // // throw new SaslSystemException(false, "SASL handshake failed due to a transient error");
    //case PN_SASL_PERM:
    //     logError("SASL handshake failed due to an unrecoverable error");
    //     break;
    // // throw new SaslSystemException(true, "SASL handshake failed due to an unrecoverable error");
    //default:
    //      logError("SASL handshake failed");
    //     break;
    // // throw new SaslException("SASL handshake failed");
    //}
  }
}
