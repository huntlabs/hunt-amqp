/*
* Copyright 2016, 2017 the original author or authors.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/
module hunt.amqp.impl.ProtonClientImpl;

//import java.util.Objects;
//import java.util.concurrent.atomic.AtomicBoolean;
//
//import io.vertx.core.AsyncResult;
//import io.vertx.core.Future;
//import io.vertx.core.Handler;
//import io.vertx.core.Vertx;
//import io.vertx.core.VertxException;
//import io.vertx.core.impl.ContextInternal;
//import io.vertx.core.impl.logging.Logger;
//import io.vertx.core.impl.logging.LoggerFactory;
//import io.vertx.core.net.NetClient;
import hunt.amqp.ProtonClient;
import hunt.amqp.ProtonClientOptions;
import hunt.amqp.ProtonConnection;
import hunt.amqp.ProtonTransportOptions;
import hunt.amqp.impl.ProtonConnectionImpl;
import hunt.amqp.Handler;
import hunt.collection.ByteBuffer;
import hunt.net.NetClient;
import hunt.net.NetUtil;
import hunt.net;
import hunt.logging;
import hunt.amqp.impl.ProtonSaslClientAuthenticatorImpl;
import hunt.amqp.ProtonReceiver;
import hunt.amqp.ProtonMessageHandler;
import hunt.amqp.ProtonDelivery;
import hunt.proton.message.Message;
import hunt.proton.amqp.messaging.Section;
import hunt.proton.amqp.messaging.AmqpValue;
import hunt.String;
import std.stdio;
import hunt.amqp.ProtonSender;
import hunt.amqp.ProtonHelper;
import core.thread;
/**
 * @author <a href="http://tfox.org">Tim Fox</a>
 * @author <a href="http://hiramchirino.com">Hiram Chirino</a>
 */


class ConnectionEventBaseHandler : NetConnectionHandler
{
    alias ConnCallBack = void delegate( Connection connection);
    alias MsgCallBack = void delegate(Connection connection ,ByteBuffer message);

    private {
        ProtonClientOptions _options;
        string _host;
        string _username;
        string _password;
        NetClient   _client;
        MsgCallBack _msgCallBack;
        ConnCallBack _closeCallBack;
        Handler!ProtonConnection _handler;
    }


    this (ProtonClientOptions options , string host , NetClient client, string name, string pwd ,Handler!ProtonConnection handler)
    {
        this._options = options;
        this._host = host;
        _client = client;
        _username = name;
        _password = pwd;
        _handler = handler;
    }

    override
    void connectionOpened(Connection connection) {
        string virtualHost = _options.getVirtualHost() !is null ? _options.getVirtualHost() : _host;
        ProtonConnectionImpl conn = new ProtonConnectionImpl(virtualHost,connection);

        ProtonSaslClientAuthenticatorImpl authenticator = new ProtonSaslClientAuthenticatorImpl(_username, _password,
        _options.getEnabledSaslMechanisms() ,_handler);

        ProtonTransportOptions transportOptions = new ProtonTransportOptions();
        transportOptions.setHeartbeat(_options.getHeartbeat());
        transportOptions.setMaxFrameSize(_options.getMaxFrameSize());

        conn.bindClient(_client, authenticator, transportOptions);

        // Need to flush here to get the SASL process going, or it will wait until calls on the connection are processed
        // later (e.g open()).
        version(HUNT_DEBUG) logInfof("Connection %d done", connection.getId());
        conn.flush();

       // Thread.sleep(1.seconds);


       // conn.open();
        //string address = "queue://foo";
        //
        //conn.createReceiver(address).handler(
        //    new class ProtonMessageHandler {
        //        void handle(ProtonDelivery delivery, Message message)
        //        {
        //              Section bd = message.getBody();
        //   // if (body instanceof AmqpValue) {
        //              String content = (cast(AmqpValue) bd).getValue();
        //              writefln("Received message with content: %s " , cast(string)(content.getBytes()));
        //    //}
        //        }
        //    }
        //).open();
        //
        //
        //ProtonSender sender = conn.createSender(null);
        //Message message = ProtonHelper.message(new String(address), new String("Hello World from client"));
        //sender.open();
        //sender.send(message, new class Handler!ProtonDelivery
        //{
        //    void handle(ProtonDelivery var1)
        //    {
        //        writefln("The message was received by the server: remote state=" );
        //    }
        //});

        //private static void helloWorldSendAndConsumeExample(ProtonConnection connection) {
        //  connection.open();
        //
        //  // Receive messages from queue "foo" (using an ActiveMQ style address as example).
        //  String address = "queue://foo";
        //
        //  connection.createReceiver(address).handler((delivery, msg) -> {
        //    Section body = msg.getBody();
        //    if (body instanceof AmqpValue) {
        //      String content = (String) ((AmqpValue) body).getValue();
        //      System.out.println("Received message with content: " + content);
        //    }
        //    // By default, the receiver automatically accepts (and settles) the delivery
        //    // when the handler returns, if no other disposition has been applied.
        //    // To change this and always manage dispositions yourself, use the
        //    // setAutoAccept method on the receiver.
        //  }).open();
        //
        //  // Create an anonymous (no address) sender, have the message carry its destination
        //  ProtonSender sender = connection.createSender(null);
        //
        //  // Create a message to send, have it carry its destination for use with the anonymous sender
        //  Message message = message(address, "Hello World from client");
        //
        //  // Can optionally add an openHandler or sendQueueDrainHandler
        //  // to await remote sender open completing or credit to send being
        //  // granted. But here we will just buffer the send immediately.
        //  sender.open();
        //  System.out.println("Sending message to server");
        //  sender.send(message, delivery -> {
        //	System.out.println(String.format("The message was received by the server: remote state=%s, remotely settled=%s",
        //	delivery.getRemoteState(), delivery.remotelySettled()));
        //  });
        //}

    }

    override
    void connectionClosed(Connection connection)
    {
        if (_closeCallBack !is null)
        {
            _closeCallBack(connection);
        }
    }

    override
    void messageReceived(Connection connection, Object message) {//ByteBuffer {
        ByteBuffer buf = cast(ByteBuffer)message;
        if(_msgCallBack !is null)
        {
            _msgCallBack(connection,buf);
        }
    }

    override
    void exceptionCaught(Connection connection, Throwable t) {}

    override
    void failedOpeningConnection(int connectionId, Throwable t) { }

    override
    void failedAcceptingConnection(int connectionId, Throwable t) { }

    void setOnConnection(ConnCallBack callback)
    {

    }

    void setOnClosed(ConnCallBack callback)
    {
        _closeCallBack = callback;
    }

    void setOnMessage(MsgCallBack callback)
    {
        _msgCallBack = callback;
    }

}


class ProtonClientImpl : ProtonClient {

  this() {
  }

  public void connect(string host, int port, Handler!ProtonConnection handler) {
    connect(host, port, null, null, handler);
  }

  public void connect(string host, int port, string username, string password,
                      Handler!ProtonConnection handler) {
    connect(new ProtonClientOptions(), host, port, username, password, handler);
  }

  public void connect(ProtonClientOptions options, string host, int port,
                      Handler!ProtonConnection handler) {
    connect(options, host, port, null, null, handler);
  }

  public void connect(ProtonClientOptions options, string host, int port, string username, string password,
                      Handler!ProtonConnection handler) {
    NetClient netClient = NetUtil.createNetClient(options);
    connectNetClient(netClient, host, port, username, password, options, handler);
  }

  private void connectNetClient(NetClient netClient, string host, int port, string username, string password, ProtonClientOptions options,Handler!ProtonConnection handler) {

    string serverName = options.getSniServerName() !is null ? options.getSniServerName() :
    (options.getVirtualHost() !is null ? options.getVirtualHost() : null);

     netClient.setHandler(new ConnectionEventBaseHandler(options, host ,netClient,username, password ,handler));
     netClient.connect(host,port, serverName);

    //netClient.connect(port, host, serverName, res -> {
    //  if (res.succeeded()) {
    //    String virtualHost = options.getVirtualHost() !is null ? options.getVirtualHost() : host;
    //    ProtonConnectionImpl conn = new ProtonConnectionImpl(vertx, virtualHost, (ContextInternal) Vertx.currentContext());
    //    conn.disconnectHandler(h -> {
    //      LOG.trace("Connection disconnected");
    //      if(!connectHandler.isComplete()) {
    //        connectHandler.handle(Future.failedFuture(new VertxException("Disconnected")));
    //      }
    //    });
    //
    //    ProtonSaslClientAuthenticatorImpl authenticator = new ProtonSaslClientAuthenticatorImpl(username, password,
    //            options.getEnabledSaslMechanisms(), connectHandler);
    //
    //    ProtonTransportOptions transportOptions = new ProtonTransportOptions();
    //    transportOptions.setHeartbeat(options.getHeartbeat());
    //    transportOptions.setMaxFrameSize(options.getMaxFrameSize());
    //
    //    conn.bindClient(netClient, res.result(), authenticator, transportOptions);
    //
    //    // Need to flush here to get the SASL process going, or it will wait until calls on the connection are processed
    //    // later (e.g open()).
    //    conn.flush();
    //  } else {
    //    connectHandler.handle(Future.failedFuture(res.cause()));
    //  }
    //});
  }



  //static class ConnectCompletionHandler implements Handler<AsyncResult<ProtonConnection>> {
  //  private AtomicBoolean completed = new AtomicBoolean();
  //  private Handler<AsyncResult<ProtonConnection>> applicationConnectHandler;
  //  private NetClient netClient;
  //
  //  ConnectCompletionHandler(Handler<AsyncResult<ProtonConnection>> applicationConnectHandler, NetClient netClient) {
  //    this.applicationConnectHandler = Objects.requireNonNull(applicationConnectHandler);
  //    this.netClient = Objects.requireNonNull(netClient);
  //  }
  //
  //  public boolean isComplete() {
  //    return completed.get();
  //  }
  //
  //  @Override
  //  public void handle(AsyncResult<ProtonConnection> event) {
  //    if (completed.compareAndSet(false, true)) {
  //      if (event.failed()) {
  //        netClient.close();
  //      }
  //      applicationConnectHandler.handle(event);
  //    }
  //  }
  //}
}
