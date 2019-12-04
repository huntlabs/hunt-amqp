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

module hunt.amqp.ProtonClientOptions;

import hunt.collection.LinkedHashSet;
import hunt.collection.Set;
import hunt.net.ProxyOptions;
import hunt.net.OpenSSLEngineOptions;
//import io.vertx.core.buffer.Buffer;
//import io.vertx.core.json.JsonObject;
//import io.vertx.core.net.JdkSSLEngineOptions;
//import io.vertx.core.net.JksOptions;
//import io.vertx.core.net.KeyCertOptions;
//import io.vertx.core.net.NetClientOptions;
//import io.vertx.core.net.OpenSSLEngineOptions;
//import io.vertx.core.net.PemKeyCertOptions;
//import io.vertx.core.net.PemTrustOptions;
//import io.vertx.core.net.PfxOptions;
//import io.vertx.core.net.ProxyOptions;
//import io.vertx.core.net.SSLEngineOptions;
//import io.vertx.core.net.TrustOptions;
import hunt.String;
import hunt.net.NetClientOptions;
import std.json;
import hunt.Exceptions;
import hunt.logging;
import core.time;
import hunt.collection.Map;
import hunt.collection.LinkedHashMap;
import std.variant;

import hunt.amqp.generated.ProtonClientOptionsConverter;
/**
 * Options for configuring {@link hunt.amqp.ProtonClient} connect operations.
 */
//@DataObject(generateConverter = true, publicConverter = false)
class ProtonClientOptions : NetClientOptions {

  private Set!string enabledSaslMechanisms;// = new LinkedHashSet<>();
  private int heartbeat;
  private int maxFrameSize;
  private string virtualHost;
  private string sniServerName;

  this() {
    super();
    setHostnameVerificationAlgorithm("HTTPS");
    enabledSaslMechanisms = new LinkedHashSet!string;
  }

  /**
   * Copy constructor
   *
   * @param other  the options to copy
   */
  this(ProtonClientOptions other) {
    super(other);
    this.enabledSaslMechanisms = new LinkedHashSet!string(other.enabledSaslMechanisms);
    this.heartbeat = other.heartbeat;
    this.maxFrameSize = other.maxFrameSize;
    this.virtualHost = other.virtualHost;
    this.sniServerName = other.sniServerName;
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
    ProtonClientOptionsConverter.fromJson(mp, this);
    super(this);
  }

  /**
   * Convert to JSON
   *
   * @return the JSON
   */
  public JSONValue toJson() {
    implementationMissing(false);
    JSONValue tmp;
    return tmp;
     //JSONValue json = super.toJson();
     //ProtonClientOptionsConverter.toJson(this, json);
     //return json;
  }

  /**
   * Get the mechanisms the client should be restricted to use.
   *
   * @return the mechanisms, or null/empty set if there is no restriction in place
   */
  public Set!string getEnabledSaslMechanisms() {
    return enabledSaslMechanisms;
  }

  /**
   * Adds a mechanism name that the client may use during SASL negotiation.
   *
   * @param saslMechanism
   *          the sasl mechanism name .
   * @return a reference to this, so the API can be used fluently
   */
  public ProtonClientOptions addEnabledSaslMechanism(string saslMechanism) {
   // Objects.requireNonNull(saslMechanism, "Mechanism must not be null");
    if (saslMechanism.length == 0)
    {
        logError("Mechanism must not be null");
    }
    enabledSaslMechanisms.add(saslMechanism);
    return this;
  }

  override
  public ProtonClientOptions setSendBufferSize(int sendBufferSize) {
    super.setSendBufferSize(sendBufferSize);
    return this;
  }

  override
  public ProtonClientOptions setReceiveBufferSize(int receiveBufferSize) {
    super.setReceiveBufferSize(receiveBufferSize);
    return this;
  }

  override
  public ProtonClientOptions setReuseAddress(bool reuseAddress) {
    super.setReuseAddress(reuseAddress);
    return this;
  }

  override
  public ProtonClientOptions setTrafficClass(int trafficClass) {
    super.setTrafficClass(trafficClass);
    return this;
  }

  override
  public ProtonClientOptions setTcpNoDelay(bool tcpNoDelay) {
    super.setTcpNoDelay(tcpNoDelay);
    return this;
  }

  override
  public ProtonClientOptions setTcpKeepAlive(bool tcpKeepAlive) {
    super.setTcpKeepAlive(tcpKeepAlive);
    return this;
  }

  override
  public ProtonClientOptions setSoLinger(int soLinger) {
    super.setSoLinger(soLinger);
    return this;
  }

  override
  public ProtonClientOptions setIdleTimeout(Duration idleTimeout) {
    super.setIdleTimeout(idleTimeout);
    return this;
  }

  //override
  //public ProtonClientOptions setIdleTimeoutUnit(TimeUnit idleTimeoutUnit) {
  //  super.setIdleTimeoutUnit(idleTimeoutUnit);
  //  return this;
  //}

  override
  public ProtonClientOptions setSsl(bool ssl) {
    super.setSsl(ssl);
    return this;
  }

  //override
  //public ProtonClientOptions setKeyStoreOptions(JksOptions options) {
  //  super.setKeyStoreOptions(options);
  //  return this;
  //}
  //
  //override
  //public ProtonClientOptions setPfxKeyCertOptions(PfxOptions options) {
  //  super.setPfxKeyCertOptions(options);
  //  return this;
  //}
  //
  //override
  //public ProtonClientOptions setPemKeyCertOptions(PemKeyCertOptions options) {
  //  super.setPemKeyCertOptions(options);
  //  return this;
  //}
  //
  //override
  //public ProtonClientOptions setTrustStoreOptions(JksOptions options) {
  //  super.setTrustStoreOptions(options);
  //  return this;
  //}
  //
  //override
  //public ProtonClientOptions setPemTrustOptions(PemTrustOptions options) {
  //  super.setPemTrustOptions(options);
  //  return this;
  //}
  //
  //override
  //public ProtonClientOptions setPfxTrustOptions(PfxOptions options) {
  //  super.setPfxTrustOptions(options);
  //  return this;
  //}

  //override
  //public ProtonClientOptions addEnabledCipherSuite(string suite) {
  //  super.addEnabledCipherSuite(suite);
  //  return this;
  //}

  //override
  //public ProtonClientOptions addCrlPath(String crlPath)  {
  //  super.addCrlPath(crlPath);
  //  return this;
  //}
  //
  //override
  //public ProtonClientOptions addCrlValue(Buffer crlValue)  {
  //  super.addCrlValue(crlValue);
  //  return this;
  //}

  override
  public ProtonClientOptions setTrustAll(bool trustAll) {
    super.setTrustAll(trustAll);
    return this;
  }

  override
  public ProtonClientOptions setConnectTimeout(Duration connectTimeout) {
    super.setConnectTimeout(connectTimeout);
    return this;
  }

  override
  public ProtonClientOptions setReconnectAttempts(int attempts) {
    super.setReconnectAttempts(attempts);
    return this;
  }

  override
  public ProtonClientOptions setReconnectInterval(Duration interval) {
    super.setReconnectInterval(interval);
    return this;
  }

  override size_t toHash() @safe nothrow
  {
    int prime = 31;

    int result = cast(int)super.toHash();
    result = prime * result + cast(int)enabledSaslMechanisms.toHash();
    result = prime * result + this.heartbeat;
    result = prime * result + this.maxFrameSize;
    result = prime * result + (this.virtualHost !is null ? cast(int)this.virtualHost.hashOf : 0);
    result = prime * result + (this.sniServerName !is null ? cast(int)this.sniServerName.hashOf : 0);

    return cast(size_t)result;
  }

  override
  public bool opEquals (Object obj) {
    if (this == obj) {
      return true;
    }

    if (obj is null){
      return false;
    }

    //if (!super.equals(obj)) {
    //  return false;
    //}

    ProtonClientOptions other = cast(ProtonClientOptions) obj;
    if ((enabledSaslMechanisms != other.enabledSaslMechanisms)){
      return false;
    }
    if (this.heartbeat != other.heartbeat) {
      return false;
    }
    if (this.maxFrameSize != other.maxFrameSize) {
      return false;
    }
    if ((this.virtualHost != other.virtualHost)) {
      return false;
    }
    if ((this.sniServerName != other.sniServerName)) {
      return false;
    }

    return true;
  }

  override
  public ProtonClientOptions setUseAlpn(bool useAlpn) {
    throw new UnsupportedOperationException();
  }

  //override
  //public ProtonClientOptions addEnabledSecureTransportProtocol(String protocol) {
  //  super.addEnabledSecureTransportProtocol(protocol);
  //  return this;
  //}

  override
  public ProtonClientOptions setHostnameVerificationAlgorithm(string hostnameVerificationAlgorithm) {
    super.setHostnameVerificationAlgorithm(hostnameVerificationAlgorithm);
    return this;
  }

  //override
  //public ProtonClientOptions setKeyCertOptions(KeyCertOptions options) {
  //  super.setKeyCertOptions(options);
  //  return this;
  //}

  override
  public ProtonClientOptions setLogActivity(bool logEnabled) {
    super.setLogActivity(logEnabled);
    return this;
  }

  override
  public ProtonClientOptions setMetricsName(string metricsName) {
    super.setMetricsName(metricsName);
    return this;
  }

  override
  public ProtonClientOptions setProxyOptions(ProxyOptions proxyOptions) {
    super.setProxyOptions(proxyOptions);
    return this;
  }

  //override
  //public ProtonClientOptions setTrustOptions(TrustOptions options) {
  //  super.setTrustOptions(options);
  //  return this;
  //}

  //override
  //public ProtonClientOptions setJdkSslEngineOptions(JdkSSLEngineOptions sslEngineOptions) {
  //  super.setJdkSslEngineOptions(sslEngineOptions);
  //  return this;
  //}

  override
  public ProtonClientOptions setOpenSslEngineOptions(OpenSSLEngineOptions sslEngineOptions) {
    super.setOpenSslEngineOptions(sslEngineOptions);
    return this;
  }

  //override
  //public ProtonClientOptions setSslEngineOptions(SSLEngineOptions sslEngineOptions) {
  //  super.setSslEngineOptions(sslEngineOptions);
  //  return this;
  //}

  override
  public ProtonClientOptions setSslHandshakeTimeout(Duration sslHandshakeTimeout) {
    super.setSslHandshakeTimeout(sslHandshakeTimeout);
    return this;
  }

  //override
  //public ProtonClientOptions setSslHandshakeTimeoutUnit(TimeUnit sslHandshakeTimeoutUnit) {
  //  super.setSslHandshakeTimeoutUnit(sslHandshakeTimeoutUnit);
  //  return this;
  //}

  override
  public ProtonClientOptions setLocalAddress(string localAddress) {
    super.setLocalAddress(localAddress);
    return this;
  }

  override
  public ProtonClientOptions setReusePort(bool reusePort) {
    super.setReusePort(reusePort);
    return this;
  }

  override
  public ProtonClientOptions setTcpCork(bool tcpCork) {
    super.setTcpCork(tcpCork);
    return this;
  }

  override
  public ProtonClientOptions setTcpFastOpen(bool tcpFastOpen) {
    super.setTcpFastOpen(tcpFastOpen);
    return this;
  }

  override
  public ProtonClientOptions setTcpQuickAck(bool tcpQuickAck) {
    super.setTcpQuickAck(tcpQuickAck);
    return this;
  }

  //override
  //public ProtonClientOptions removeEnabledSecureTransportProtocol(String protocol) {
  //  super.removeEnabledSecureTransportProtocol(protocol);
  //  return this;
  //}

  //override
  //public ProtonClientOptions setEnabledSecureTransportProtocols(Set<String> enabledSecureTransportProtocols) {
  //  super.setEnabledSecureTransportProtocols(enabledSecureTransportProtocols);
  //  return this;
  //}

  /**
   * Override the hostname value used in the connection AMQP Open frame and TLS SNI server name (if TLS is in use).
   * By default, the hostname specified in {@link ProtonClient#connect} will be used for both, with SNI performed
   * implicit where a FQDN was specified.
   *
   * The SNI server name can also be overridden explicitly using {@link #setSniServerName(String)}.
   *
   * @param virtualHost hostname to set
   * @return  current ProtonClientOptions instance
   */
  public ProtonClientOptions setVirtualHost(string virtualHost) {
    this.virtualHost = virtualHost;
    return this;
  }

  /**
   * Get the virtual host name override for the connection AMQP Open frame and TLS SNI server name (if TLS is in use)
   * set by {@link #setVirtualHost(String)}.
   *
   * @return  the hostname
   */
  public string getVirtualHost() {
    return this.virtualHost;
  }

  /**
   * Explicitly override the hostname to use for the TLS SNI server name.
   *
   * If neither the {@link ProtonClientOptions#setVirtualHost(String) virtualhost} or SNI server name is explicitly
   * overridden, the hostname specified in {@link ProtonClient#connect} will be used, with SNI performed implicitly
   * where a FQDN was specified.
   *
   * This method should typically only be needed to set different values for the [virtual] hostname and SNI server name.
   *
   * @param sniServerName hostname to set as SNI server name
   * @return  current ProtonClientOptions instance
   */
  public ProtonClientOptions setSniServerName(string sniServerName) {
    this.sniServerName = sniServerName;
    return this;
  }

  /**
   * Get the hostname override for TLS SNI Server Name set by {@link #setSniServerName(String)}.
   *
   * @return  the hostname
   */
  public string getSniServerName() {
    return this.sniServerName;
  }

  /**
   * Set the heartbeat (in milliseconds) as maximum delay between sending frames for the remote peers.
   * If no frames are received within 2*heartbeat, the connection is closed
   *
   * @param heartbeat hearthbeat maximum delay
   * @return  current ProtonClientOptions instance
   */
  public ProtonClientOptions setHeartbeat(int heartbeat) {
    this.heartbeat = heartbeat;
    return this;
  }

  /**
   * Return the heartbeat (in milliseconds) as maximum delay between sending frames for the remote peers.
   *
   * @return  hearthbeat maximum delay
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
  public ProtonClientOptions setMaxFrameSize(int maxFrameSize) {
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
}
