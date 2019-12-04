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
module hunt.amqp.ProtonLinkOptions;

//import io.vertx.codegen.annotations.DataObject;
//import io.vertx.core.json.JsonObject;
import hunt.amqp.generated.ProtonLinkOptionsConverter;
import hunt.Boolean;
import hunt.String;
import std.json;
import hunt.collection.Map;
import hunt.collection.LinkedHashMap;
import std.variant;
/**
 * Options for configuring link attributes.
 */
//@DataObject(generateConverter = true, publicConverter = false)

class ProtonLinkOptions {

    private string linkName;
    private bool dynamic;

    this() {
    }

    /**
     * Create options from JSON
     *
     * @param json  the JSON
     */
    this(JSONValue json) {
    Map!(string, Variant) mp = new LinkedHashMap!(string,Variant)();
    foreach (string key, value; json)
    {
        Variant tmp = value;
        mp.put(key,tmp);
    }
      ProtonLinkOptionsConverter.fromJson(mp, this);
    }

    /**
     * Convert to JSON
     *
     * @return the JSON
     */
    public JSONValue toJson() {
      JSONValue json ;
      ProtonLinkOptionsConverter.toJson(this, json);
      return json;
    }

    public ProtonLinkOptions setLinkName(string linkName) {
        this.linkName = linkName;
        return this;
    }

    public string getLinkName() {
        return linkName;
    }

    /**
     * Sets whether the link remote terminus to be used should indicate it is
     * 'dynamic', requesting the peer names it with a dynamic address.
     * The address provided by the peer can then be inspected using
     * {@link ProtonLink#getRemoteAddress()} (or inspecting the remote
     * terminus details directly) after the link has remotely opened.
     *
     * @param dynamic true if the link should request a dynamic terminus address
     * @return the options
     */
    public ProtonLinkOptions setDynamic(bool dynamic) {
      this.dynamic = dynamic;
      return this;
    }

    public bool isDynamic() {
      return dynamic;
    }
}
