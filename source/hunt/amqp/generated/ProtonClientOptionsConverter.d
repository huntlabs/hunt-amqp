module hunt.amqp.generated.ProtonClientOptionsConverter;

//import io.vertx.core.json.JsonObject;
//import io.vertx.core.json.JsonArray;
//import java.time.Instant;
//import java.time.format.DateTimeFormatter;
import hunt.String;
import hunt.collection.Map;
import std.json;
import hunt.amqp.ProtonClientOptions;
import hunt.Number;
import hunt.collection.LinkedHashMap;
import std.variant;
/**
 * Converter and mapper for {@link io.vertx.proton.ProtonClientOptions}.
 * NOTE: This class has been automatically generated from the {@link io.vertx.proton.ProtonClientOptions} original class using Vert.x codegen.
 */
class ProtonClientOptionsConverter {

    //foreach (size_t index, value; jv)
    //{
    //    static assert(is(typeof(value) == JSONValue));
    //    assert(value.type == JSONType.integer);
    //    assertNotThrown(value.integer);
    //    assert(index == (value.integer-3));
    //}
 //*b.peek!(int)
   static void fromJson(Map!(string, Variant) json, ProtonClientOptions obj) {
    foreach (MapEntry!(string, Variant) member ; json) {
      switch (member.getKey()) {
        case "enabledSaslMechanisms":
          JSONValue js = *(member.getValue()).peek!JSONValue;
          if (js.type() == JSONType.array) {
            foreach (size_t index, value; js)
            {
                string t = (value.str);
                obj.addEnabledSaslMechanism(t);
            }
            //((Iterable<Object>)member.getValue()).forEach( item -> {
            //  if (item instanceof String)
            //    obj.addEnabledSaslMechanism((String)item);
            //});
          }
          break;
        case "heartbeat":
          JSONValue js = *(member.getValue()).peek!JSONValue;
          //int num = *(member.getValue()).peek!int;
          //if (js !is null) {
            obj.setHeartbeat(cast(int)js.integer);
          //}
          break;
        case "maxFrameSize":
            JSONValue js = *(member.getValue()).peek!JSONValue;
          // int num = *(member.getValue()).peek!int;
         // if (js !is null) {
            obj.setMaxFrameSize(cast(int)js.integer);
          //}
          break;
        case "sniServerName":
          JSONValue js = *(member.getValue()).peek!JSONValue;
          //string str = *(member.getValue()).peek!string;
         // if (js !is null) {
            obj.setSniServerName(js.str);
          //}
          break;
        case "virtualHost":
         JSONValue js = *(member.getValue()).peek!JSONValue;
         //string str = *(member.getValue()).peek!string;
          //if (js !is null) {
            obj.setVirtualHost(js.str);
          //}
          break;
         default:
          break;
      }
    }
  }

   static void toJson(ProtonClientOptions obj, JSONValue json) {
       Map!(string, Variant) mp = new LinkedHashMap!(string,Variant)();
       foreach (string key, value; json)
       {
           Variant tmp = value;
           mp.put(key,tmp);
       }
        toJson(obj, mp);
  }

   static void toJson(ProtonClientOptions obj, Map!(string, Variant) json) {
    if (obj.getEnabledSaslMechanisms() !is null) {
      string [] arry;
      foreach(string str ;  obj.getEnabledSaslMechanisms())
      {
            arry ~= str;
      }
      JSONValue array = JSONValue(arry);
    //  obj.getEnabledSaslMechanisms().forEach(item -> array.add(item));
      Variant ar = array;
      json.put("enabledSaslMechanisms", ar);
    }
    Variant hb = obj.getHeartbeat();
    json.put("heartbeat", hb);
    Variant mx = obj.getMaxFrameSize();
    json.put("maxFrameSize", mx);
    if (obj.getSniServerName().length != 0) {
      Variant sn =   obj.getSniServerName();
      json.put("sniServerName", sn);
    }
    if (obj.getVirtualHost().length != 0) {
      Variant vh =   obj.getVirtualHost();
      json.put("virtualHost", vh);
    }
  }
}
