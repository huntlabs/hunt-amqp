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
module hunt.amqp.ProtonHelper;

import hunt.amqp.ProtonDelivery;

import hunt.proton.Proton;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.messaging.Accepted;
import hunt.proton.amqp.messaging.AmqpValue;
import hunt.proton.amqp.messaging.Modified;
import hunt.proton.amqp.messaging.Rejected;
import hunt.proton.amqp.messaging.Released;
import hunt.proton.amqp.transport.ErrorCondition;
import hunt.proton.message.Message;

import hunt.net.AsyncResult;
import hunt.String;
import hunt.Boolean;

/**
 * @author <a href="http://hiramchirino.com">Hiram Chirino</a>
 */
interface ProtonHelper {

    /**
     * Creates a bare Message object.
     *
     * @return the message
     */
    static Message message() {
        return Proton.message();
    }

    /**
     * Creates a Message object with the given String contained as an AmqpValue body.
     *
     * @param body
     *          the string to set as an AmqpValue body
     * @return the message
     */
    static Message message(String bd) {
        Message value = message();
        value.setBody(new AmqpValue(bd));
        return value;
    }

    /**
     * Creates a Message object with the given String contained as an AmqpValue body, and the 'to' address set as given.
     *
     * @param address
     *          the 'to' address to set
     * @param body
     *          the string to set as an AmqpValue body
     * @return the message
     */
    static Message message(String address, String bd) {
        Message value = message(bd);
        value.setAddress(address);
        return value;
    }

    /**
     * Create an ErrorCondition with the given error condition value and error description string.
     *
     * See the AMQP specification
     * <a href="http://docs.oasis-open.org/amqp/core/v1.0/os/amqp-core-transport-v1.0-os.html#type-amqp-error">error
     * sections</a> for details of various standard error condition values.
     *
     * For useful condition value constants, see {@link hunt.proton.amqp.transport.AmqpError AmqpError},
     * {@link hunt.proton.amqp.transport.ConnectionError ConnectionError},
     * {@link hunt.proton.amqp.transport.SessionError SessionError} and
     * {@link hunt.proton.amqp.transport.LinkError LinkError}.
     *
     * @param condition
     *          the error condition value
     * @param description
     *          String description of the error, may be null
     * @return the condition
     */
    static ErrorCondition condition(Symbol condition, String description) {
        return new ErrorCondition(condition, description);
    }

    /**
     * Create an ErrorCondition with the given error condition value (which will be converted to the required Symbol type)
     * and error description string.
     *
     * See {@link #condition(Symbol, String)} for more details.
     *
     * @param condition
     *          the error condition value, to be converted to a Symbol
     * @param description
     *          String description of the error, may be null
     * @return the condition
     */
    static ErrorCondition condition(String condition, String description) {
        return ProtonHelper.condition(Symbol.valueOf((cast(string)(condition.getBytes()))),
                description);
    }

    /**
     * Creates a byte[] for use as a delivery tag by UTF-8 converting the given string.
     *
     * @param tag
     *          the string to convert
     * @return byte[] for use as tag
     */
    static byte[] tag(String tag) {
        return tag.getBytes();
    }

    /**
     * Accept the given delivery by applying Accepted disposition state, and optionally settling.
     *
     * @param delivery
     *          the delivery to update
     * @param settle
     *          whether to settle
     * @return the delivery
     */
    static ProtonDelivery accepted(ProtonDelivery delivery, bool settle) {
        delivery.disposition(Accepted.getInstance(), settle);
        return delivery;
    }

    /**
     * Reject the given delivery by applying Rejected disposition state, and optionally settling.
     *
     * @param delivery
     *          the delivery to update
     * @param settle
     *          whether to settle
     * @return the delivery
     */
    static ProtonDelivery rejected(ProtonDelivery delivery, bool settle) {
        delivery.disposition(new Rejected(), settle);
        return delivery;
    }

    /**
     * Release the given delivery by applying Released disposition state, and optionally settling.
     *
     * @param delivery
     *          the delivery to update
     * @param settle
     *          whether to settle
     * @return the delivery
     */
    static ProtonDelivery released(ProtonDelivery delivery, bool settle) {
        delivery.disposition(Released.getInstance(), settle);
        return delivery;
    }

    /**
     * Modify the given delivery by applying Modified disposition state, with deliveryFailed and underliverableHere flags
     * as given, and optionally settling.
     *
     * @param delivery
     *          the delivery to update
     * @param settle
     *          whether to settle
     * @param deliveryFailed
     *          whether the delivery should be treated as failed
     * @param undeliverableHere
     *          whether the delivery is considered undeliverable by the related receiver
     * @return the delivery
     */
    static ProtonDelivery modified(ProtonDelivery delivery, bool settle,
            bool deliveryFailed, bool undeliverableHere) {
        Modified modified = new Modified();
        modified.setDeliveryFailed(new Boolean(deliveryFailed));
        modified.setUndeliverableHere(new Boolean(undeliverableHere));

        delivery.disposition(modified, settle);
        return delivery;
    }

    static AsyncResult!T future(T)(T value, ErrorCondition err) {
        if (err.getCondition() !is null) {
            return failedResult!(T)(new Exception(err.toString()));
        } else {
            return succeededResult!(T)(value);
        }
    }
}
