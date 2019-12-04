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

module hunt.amqp.ProtonTransportOptions;

//import io.vertx.codegen.annotations.DataObject;
//import io.vertx.core.json.JsonObject;
import std.json;
import hunt.amqp.generated.ProtonTransportOptionsConverter;
import hunt.collection.Map;
import hunt.collection.LinkedHashMap;
import std.variant;
/**
 * Options for configuring transport layer
 */
//@DataObject(generateConverter = true, publicConverter = false)
class ProtonTransportOptions {

  private int heartbeat;
  private int maxFrameSize;

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
    ProtonTransportOptionsConverter.fromJson(mp, this);
  }

  /**
   * Convert to JSON
   *
   * @return the JSON
   */
  public JSONValue toJson() {
    JSONValue json ;
    ProtonTransportOptionsConverter.toJson(this, json);
    return json;
  }

  /**
   * Set the heart beat as maximum delay between sending frames for the remote peers.
   * If no frames are received within 2 * heart beat, the connection is closed
   *
   * @param heartbeat The maximum delay in milliseconds.
   * @return current ProtonTransportOptions instance.
   */
  public ProtonTransportOptions setHeartbeat(int heartbeat) {
    this.heartbeat = heartbeat;
    return this;
  }

  /**
   * Returns the heart beat as maximum delay between sending frames for the remote peers.
   *
   * @return The maximum delay in milliseconds.
   */
  public int getHeartbeat() {
    return this.heartbeat;
  }

  /**
   * Sets the maximum frame size for the connection.
   * <p>
   * If this property is not set explicitly, a reasonable default value is used.
   * <p>
   * Setting this property to a negative value will result in no maximum frame size being announced at all.
   *
   * @param maxFrameSize The frame size in bytes.
   * @return This instance for setter chaining.
   */
  public ProtonTransportOptions setMaxFrameSize(int maxFrameSize) {
    if (maxFrameSize < 0) {
      this.maxFrameSize = -1;
    } else {
      this.maxFrameSize = maxFrameSize;
    }
    return this;
  }

  /**
   * Gets the maximum frame size for the connection.
   * <p>
   * If this property is not set explicitly, a reasonable default value is used.
   *
   * @return The frame size in bytes or -1 if no limit is set.
   */
  public int getMaxFrameSize() {
    return maxFrameSize;
  }

  override size_t toHash() @safe nothrow
  {
    int prime = 31;
    int result = 1;
    result = prime * result + heartbeat;
    result = prime * result + maxFrameSize;
    return cast(size_t)result;
  }

  override
  public bool opEquals (Object obj) {
    if (this == obj) {
      return true;
    }

    if (obj is null ){
      return false;
    }

    ProtonTransportOptions other = cast(ProtonTransportOptions) obj;
    if (this.heartbeat != other.heartbeat) {
      return false;
    }
    if (this.maxFrameSize != other.maxFrameSize) {
      return false;
    }

    return true;
  }
}
