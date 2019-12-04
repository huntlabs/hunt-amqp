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
module hunt.amqp.ProtonQoS;

import hunt.Enum;
import std.concurrency : initOnce;

class ProtonQoS  :  AbstractEnum!string{
  //AT_MOST_ONCE,
  //AT_LEAST_ONCE

   static ProtonQoS  AT_MOST_ONCE() {
       __gshared ProtonQoS  inst;
       return initOnce!inst(new ProtonQoS("AT_MOST_ONCE",0));
   }

  static ProtonQoS  AT_LEAST_ONCE() {
    __gshared ProtonQoS  inst;
    return initOnce!inst(new ProtonQoS("AT_LEAST_ONCE",1));
  }

  this(string name, int i)
  {
    super(name,i);
  }
}
