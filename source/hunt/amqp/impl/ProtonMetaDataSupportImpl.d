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
module hunt.amqp.impl.ProtonMetaDataSupportImpl;

//import java.io.BufferedReader;
//import java.io.InputStream;
//import java.io.InputStreamReader;
//import java.nio.charset.StandardCharsets;

import hunt.proton.amqp.Symbol;
import std.concurrency : initOnce;

class ProtonMetaDataSupportImpl {

  public static  string PRODUCT = "vertx-proton";
  //public static  Symbol PRODUCT_KEY = Symbol.valueOf("product");
  public static  string VERSION;
  //public static  Symbol VERSION_KEY = Symbol.valueOf("version");

  static Symbol  PRODUCT_KEY() {
    __gshared Symbol  inst;
    return initOnce!inst(Symbol.valueOf("product"));
  }


  static Symbol  VERSION_KEY() {
    __gshared Symbol  inst;
    return initOnce!inst(Symbol.valueOf("version"));
  }

  //static {
  //  string version = "unknown";
  //  try {
  //    InputStream in = null;
  //    String path = ProtonMetaDataSupportImpl.class.getPackage().getName().replace(".", "/");
  //    if ((in = ProtonMetaDataSupportImpl.class.getResourceAsStream("/" + path + "/version.txt")) !is null) {
  //      try (BufferedReader reader = new BufferedReader(new InputStreamReader(in, StandardCharsets.UTF_8));) {
  //        String line = reader.readLine();
  //        if (line !is null && !line.isEmpty()) {
  //          version = line;
  //        }
  //      }
  //    }
  //  } catch (Throwable err) {
  //    LOG.error("Problem determining version details", err);
  //  }

   // VERSION = version;
  //}
}
