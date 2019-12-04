module hunt.amqp.generated.ProtonServerOptionsConverter;

//import io.vertx.core.json.JsonObject;
//import io.vertx.core.json.JsonArray;
//import java.time.Instant;
//import java.time.format.DateTimeFormatter;
import std.json;
import std.variant;
import hunt.collection.Map;
import hunt.collection.LinkedHashMap;
import hunt.amqp.ProtonServerOptions;

/**
 * Converter and mapper for {@link io.vertx.proton.ProtonServerOptions}.
 * NOTE: This class has been automatically generated from the {@link io.vertx.proton.ProtonServerOptions} original class using Vert.x codegen.
 */
//class ProtonServerOptionsConverter {
//
//   static void fromJson(Map!(string, Variant) json, ProtonServerOptions obj) {
//    foreach (MapEntry!(string, Variant) member ; json) {
//      switch (member.getKey()) {
//        case "heartbeat":
//           JSONValue js = *(member.getValue()).peek!JSONValue;
//          if (js !is null) {
//            obj.setHeartbeat(cast(int)js.integer());
//          }
//          break;
//        case "maxFrameSize":
//            JSONValue js = *(member.getValue()).peek!JSONValue;
//          if (js !is null) {
//            obj.setMaxFrameSize(cast(int)js.integer());
//          }
//          break;
//         default:
//          break;
//      }
//    }
//  }
//
//   static void toJson(ProtonServerOptions obj, JSONValue json) {
//       Map!(string, Variant) mp = new LinkedHashMap!(string,Variant)();
//       foreach (string key, value; json)
//       {
//           mp.put(key,value);
//       }
//    toJson(obj, mp);
//  }
//
//   static void toJson(ProtonServerOptions obj, Map!(string, Variant) json) {
//    json.put("heartbeat", obj.getHeartbeat());
//    json.put("maxFrameSize", obj.getMaxFrameSize());
//  }
//}
