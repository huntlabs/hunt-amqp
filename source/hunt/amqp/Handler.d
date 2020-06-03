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

module hunt.amqp.Handler;

import hunt.net.AsyncResult;
import hunt.Object;
import hunt.Functions;

alias AsyncResultHandler(T) = Action1!(AsyncResult!T);
alias VoidAsyncHandler = AsyncResultHandler!Void;
alias VoidAsyncResult = AsyncResult!Void;


interface Handler(E) {
    void handle(E var1);
}
