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
module hunt.amqp.sasl.impl.ProtonSaslExternalFactoryImpl;

import hunt.amqp.sasl.ProtonSaslMechanism;
import hunt.amqp.sasl.ProtonSaslMechanismFactory;
import hunt.amqp.sasl.impl.ProtonSaslExternalImpl;

class ProtonSaslExternalFactoryImpl : ProtonSaslMechanismFactory {

  public ProtonSaslMechanism createMechanism() {
    return new ProtonSaslExternalImpl();
  }

  public string getMechanismName() {
    return ProtonSaslExternalImpl.MECH_NAME;
  }
}
