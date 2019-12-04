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
module hunt.amqp.sasl.SaslSystemException;

//import javax.security.sasl.SaslException;
//
///**
// * Indicates that a SASL handshake has failed with a {@code sys}, {@code sys-perm}, or {@code sys-temp}
// * outcome code as defined by
// * <a href="http://docs.oasis-open.org/amqp/core/v1.0/os/amqp-core-security-v1.0-os.html#type-sasl-code">
// * AMQP Version 1.0, Section 5.3.3.6</a>.
// */
//class SaslSystemException extends SaslException {
//
//  private static final long serialVersionUID = 1L;
//  private final boolean permanent;
//
//  /**
//   * Creates an exception indicating a system error.
//   *
//   * @param permanent {@code true} if the error is permanent and requires
//   *                  (manual) intervention.
//   *
//   */
//  public SaslSystemException(boolean permanent) {
//    this(permanent, null);
//  }
//
//  /**
//   * Creates an exception indicating a system error with a detail message.
//   *
//   * @param permanent {@code true} if the error is permanent and requires
//   *                  (manual) intervention.
//   * @param detail A message providing details about the cause
//   *               of the problem.
//   */
//  public SaslSystemException(boolean permanent, String detail) {
//    super(detail);
//    this.permanent = permanent;
//  }
//
//  /**
//   * Checks if the condition that caused this exception is of a permanent nature.
//   *
//   * @return {@code true} if the error condition is permanent.
//   */
//  public final boolean isPermanent() {
//    return permanent;
//  }
//}
