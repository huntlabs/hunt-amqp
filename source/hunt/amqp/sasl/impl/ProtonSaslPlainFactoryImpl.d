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
module hunt.amqp.sasl.impl.ProtonSaslPlainFactoryImpl;

import hunt.amqp.sasl.ProtonSaslMechanism;
import hunt.amqp.sasl.ProtonSaslMechanismFactory;
import hunt.amqp.sasl.impl.ProtonSaslPlainImpl;


class ProtonSaslPlainFactoryImpl : ProtonSaslMechanismFactory {

  public ProtonSaslMechanism createMechanism() {
    return new ProtonSaslPlainImpl();
  }

  public string getMechanismName() {
    return ProtonSaslPlainImpl.MECH_NAME;
  }
}
