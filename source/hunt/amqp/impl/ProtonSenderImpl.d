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
module hunt.amqp.impl.ProtonSenderImpl;

import hunt.proton.amqp.transport.SenderSettleMode;
import hunt.proton.amqp.transport.Target;
import hunt.proton.codec.ReadableBuffer;
import hunt.proton.engine.Delivery;
import hunt.proton.engine.Sender;
import hunt.proton.message.Message;
import hunt.proton.message.impl.MessageImpl;

import hunt.amqp.ProtonDelivery;
import hunt.amqp.ProtonSender;
import hunt.amqp.impl.ProtonLinkImpl;
import hunt.amqp.Handler;
import hunt.Exceptions;
import hunt.Integer;
import hunt.amqp.impl.ProtonWritableBufferImpl;
import hunt.amqp.impl.ProtonReadableBufferImpl;
import hunt.amqp.impl.ProtonDeliveryImpl;
import hunt.logging;

/**
 * @author <a href="http://hiramchirino.com">Hiram Chirino</a>
 */
class ProtonSenderImpl : ProtonLinkImpl!ProtonSender, ProtonSender {

    private Handler!ProtonSender drainHandler;
    private bool anonymousSender;
    private bool autoSettle = true;
    private int tag = 1;
    private bool autoDrained = true;

    this(Sender sender) {
        super(sender);
    }

    private Sender sender() {
        return cast(Sender) link;
    }

    override ProtonDelivery send(Message message) {
        return send(message, null);
    }

    override ProtonDelivery send(Message message, Handler!ProtonDelivery onUpdated) {
        return send(generateTag(), message, onUpdated);
    }

    private byte[] generateTag() {
        int value = tag++;
        byte[] binary = new byte[Integer.BYTES];
        setInt(binary, value);
        return binary;
    }

    private static void setInt(byte[] binary, int value) {
        binary[0] = cast(byte)(value >>> 24);
        binary[1] = cast(byte)(value >>> 16);
        binary[2] = cast(byte)(value >>> 8);
        binary[3] = cast(byte) value;
    }

    override ProtonDelivery send(byte[] tag, Message message) {
        return send(tag, message, null);
    }

    override ProtonDelivery send(byte[] tag, Message message, Handler!ProtonDelivery onUpdated) {
        if (anonymousSender && message.getAddress() is null) {
            throw new IllegalArgumentException(
                    "Message must have an address when using anonymous sender.");
        }
        // TODO: prevent odd combination of onRecieved callback + SenderSettleMode.SETTLED, or just allow it?
        version (HUNT_AMQP_DEBUG)
            logInfof("tag: %s", tag);
        Delivery delivery = sender().delivery(tag); // start a new delivery..
        ProtonWritableBufferImpl buffer = new ProtonWritableBufferImpl();
        MessageImpl msg = cast(MessageImpl) message;
        msg.encode(buffer);
        ReadableBuffer encoded = new ProtonReadableBufferImpl(buffer.getBuffer());

        int ll = sender().sendNoCopy(encoded); // 55
        if (link.getSenderSettleMode() == SenderSettleMode.SETTLED) {
            delivery.settle();
        }
        sender().advance(); // ends the delivery.

        ProtonDeliveryImpl protonDeliveryImpl = new ProtonDeliveryImpl(delivery);
        if (onUpdated !is null) {
            protonDeliveryImpl.setAutoSettle(autoSettle);
            protonDeliveryImpl.handler(onUpdated);
        } else {
            protonDeliveryImpl.setAutoSettle(true);
        }
        version (HUNT_AMQP_DEBUG)
            logInfof("send");
        getSession().getConnectionImpl().flush();

        return protonDeliveryImpl;
    }

    override bool isAutoSettle() {
        return autoSettle;
    }

    override ProtonSender setAutoSettle(bool autoSettle) {
        this.autoSettle = autoSettle;
        return this;
    }

    bool isAnonymousSender() {
        return anonymousSender;
    }

    void setAnonymousSender(bool anonymousSender) {
        this.anonymousSender = anonymousSender;
    }

    override ProtonSenderImpl self() {
        return this;
    }

    override bool sendQueueFull() {
        return link.getRemoteCredit() <= 0;
    }

    override ProtonSender sendQueueDrainHandler(Handler!ProtonSender drainHandler) {
        this.drainHandler = drainHandler;
        handleLinkFlow();
        return this;
    }

    override void handleLinkFlow() {
        if (link.getRemoteCredit() > 0 && drainHandler !is null) {
            drainHandler.handle(this);
        }

        if (autoDrained && getDrain()) {
            drained();
        }
    }

    override bool isAutoDrained() {
        return autoDrained;
    }

    override ProtonSender setAutoDrained(bool autoDrained) {
        this.autoDrained = autoDrained;
        return this;
    }

    override int drained() {
        return super.drained();
    }

    override string getRemoteAddress() {
        Target remoteTarget = getRemoteTarget();

        return remoteTarget is null ? null : (cast(string)(remoteTarget.getAddress().getBytes()));
    }

}
