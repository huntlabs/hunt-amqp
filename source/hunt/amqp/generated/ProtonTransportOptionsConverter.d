module hunt.amqp.generated.ProtonTransportOptionsConverter;

//import io.vertx.core.json.JsonObject;
//import io.vertx.core.json.JsonArray;
//import java.time.Instant;
//import java.time.format.DateTimeFormatter;

import hunt.collection.Map;
import std.json;
import std.variant;
import hunt.amqp.ProtonTransportOptions;
import hunt.collection.LinkedHashMap;
/**
 * Converter and mapper for {@link io.vertx.proton.ProtonTransportOptions}.
 * NOTE: This class has been automatically generated from the {@link io.vertx.proton.ProtonTransportOptions} original class using Vert.x codegen.
 */
class ProtonTransportOptionsConverter {

   static void fromJson(Map!(string, Variant) json, ProtonTransportOptions obj) {
    foreach (MapEntry!(string, Variant) member ; json) {
      switch (member.getKey()) {
        case "heartbeat":
          JSONValue js = *(member.getValue()).peek!JSONValue;
          //if (js !is null) {
            obj.setHeartbeat(cast(int)js.integer);
          //}
          break;
        case "maxFrameSize":
          JSONValue js = *(member.getValue()).peek!JSONValue;
          //if (js !is null) {
            obj.setMaxFrameSize(cast(int)js.integer);
          //}
          break;
        default:
          break;
      }
    }
  }

   static void toJson(ProtonTransportOptions obj, JSONValue json) {
       Map!(string, Variant) mp = new LinkedHashMap!(string,Variant)();
       foreach (string key, value; json)
       {
           Variant tmp = value;
           mp.put(key,tmp);
       }
       toJson(obj, mp);
  }

   static void toJson(ProtonTransportOptions obj, Map!(string, Variant) json) {
     Variant hb =obj.getHeartbeat();
    json.put("heartbeat", hb);
     Variant mx = obj.getMaxFrameSize();
    json.put("maxFrameSize", mx);
  }
}
