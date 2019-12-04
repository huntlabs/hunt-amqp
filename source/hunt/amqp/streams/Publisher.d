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

module hunt.amqp.streams.Publisher;

import std.stdio;
import hunt.amqp.streams.Subscriber;

interface Publisher(T) {
    void subscribe(Subscriber!T var1);
}
