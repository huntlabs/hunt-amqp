import std.stdio;
import hunt.amqp.ProtonReceiver;
import hunt.amqp.ProtonMessageHandler;
import hunt.amqp.ProtonDelivery;
import hunt.proton.message.Message;
import hunt.proton.amqp.messaging.Section;
import hunt.proton.amqp.messaging.AmqpValue;
import hunt.String;
import hunt.amqp.ProtonSender;
import hunt.amqp.ProtonHelper;
import hunt.amqp.ProtonClient;
import hunt.amqp.Handler;
import hunt.amqp.ProtonConnection;
import hunt.proton.engine.Connection;
import hunt.proton.engine.Session;
import hunt.proton.engine.Sender;
import hunt.amqp.impl.ProtonSenderImpl;
import hunt.proton.engine.Record;
import hunt.Assert ;
import hunt.String;
import hunt.logging;
void testAttachments() {
    //Connection conn = Connection.Factory.create();
    //Session sess = conn.session();
    //Sender s = sess.sender("name");
	//
    //ProtonSenderImpl sender = new ProtonSenderImpl(s);
	//
    //Record attachments = sender.attachments();
    //assertNotNull("Expected attachments but got null", attachments);
    //assertSame("Got different attachments on subsequent call", attachments, sender.attachments());
	//
    //String key = "My-Connection-Key";
	//
    //assertNull("Expected attachment to be null", attachments.get(key, Connection.class));
    //attachments.set(key, Connection.class, conn);
    //assertNotNull("Expected attachment to be returned", attachments.get(key, Connection.class));
    //assertSame("Expected attachment to be given object", conn, attachments.get(key, Connection.class));
	Connection conn = Connection.Factory.create();
	Session sess = conn.session();
	Sender s = sess.sender("name");

	ProtonSenderImpl sender = new ProtonSenderImpl(s);
	assertTrue(sender.isAutoSettle());
  }

void main()
{
	//testAttachments;

	version(HUNT_DEBUG)
	{
	}

	ProtonClient client = ProtonClient.create();
	client.connect("127.0.0.1",5673,
	new class Handler!ProtonConnection {
		void handle(ProtonConnection connection)
		{

			connection.open();
			logInfof("ttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttt");
			string address = "queue://foo";

			connection.createReceiver(address).handler(
			new class ProtonMessageHandler {
				void handle(ProtonDelivery delivery, Message message)
				{
					Section bd = message.getBody();
					if (cast(AmqpValue) bd !is null) {
					String content = (cast(AmqpValue) bd).getValue();
					writefln("Received message with content: %s " , cast(string)(content.getBytes()));
					}
				}
			}
			).open();


			ProtonSender sender = connection.createSender(null);
			Message message = ProtonHelper.message(new String(address), new String("Hello World from client"));
			sender.open();
			sender.send(message, new class Handler!ProtonDelivery
			{
				void handle(ProtonDelivery var1)
				{
					writefln("The message was received by the server: remote state=" );
				}
			});
		}
	}
	);

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
