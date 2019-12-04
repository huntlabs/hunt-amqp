module hunt.amqp.generated.ProtonLinkOptionsConverter;

//import io.vertx.core.json.JsonObject;
//import io.vertx.core.json.JsonArray;

import hunt.amqp.ProtonLinkOptions;
import hunt.collection.Map;
import hunt.String;
import hunt.Boolean;
import std.json;
import hunt.collection.LinkedHashMap;
import std.variant;
/**

 * Converter and mapper for {@link io.vertx.proton.ProtonLinkOptions}.
 * NOTE: This class has been automatically generated from the {@link io.vertx.proton.ProtonLinkOptions} original class using Vert.x codegen.
 */
class ProtonLinkOptionsConverter {
   static void fromJson(Map!(string, Variant) json, ProtonLinkOptions obj) {
    foreach (MapEntry!(string, Variant)  member ; json) {
      switch (member.getKey()) {
        case "dynamic":
         JSONValue js = *(member.getValue()).peek!JSONValue;
          //bool b = *(member.getValue()).peek!bool;
          //if (js !is null) {
            obj.setDynamic(js.boolean);
          //}
          break;
        case "linkName":
        JSONValue js = *(member.getValue()).peek!JSONValue;
          //string s = *(member.getValue()).peek!string;
          //if (js !is null) {
            obj.setLinkName(js.str);
          //}
          break;
        default:
          break;
      }
    }
  }

    //   foreach (string key, value; jv)
    //{
    //    static assert(is(typeof(value) == JSONValue));
    //    assert(key == "key");
    //    assert(value.type == JSONType.string);
    //    assertNotThrown(value.str);
    //    assert(value.str == "value");
    //}

   static void toJson(ProtonLinkOptions obj, JSONValue json) {
       Map!(string, Variant) mp = new LinkedHashMap!(string,Variant)();
       foreach (string key, value; json)
       {
           Variant tmp = value;
           mp.put(key,tmp);
       }
       toJson(obj, mp);
  }

   static void toJson(ProtonLinkOptions obj, Map!(string, Variant) json) {
     Variant dy =    obj.isDynamic();
    json.put("dynamic",  dy);
    if (obj.getLinkName().length != 0) {
      Variant ln =   obj.getLinkName();
      json.put("linkName", ln);
    }
  }
}
