/*
 * Copyright 2018 the original author or authors.
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
module hunt.amqp.impl.ProtonWritableBufferImpl;

import hunt.collection.ByteBuffer;

import hunt.proton.codec.ReadableBuffer;
import hunt.proton.codec.WritableBuffer;
import hunt.net.buffer.Unpooled;
import hunt.net.buffer.ByteBuf;
import  hunt.text.Charset;
//import io.netty.buffer.ByteBuf;
//import io.netty.buffer.Unpooled;

/**
 * Proton WritableBuffer implementation that wraps a Netty ByteBuf
 */
class ProtonWritableBufferImpl : WritableBuffer {

  public static  int INITIAL_CAPACITY = 1024;

  public ByteBuf nettyBuffer;

  this() {
    this(INITIAL_CAPACITY);
  }

  this(int initialCapacity) {
    nettyBuffer = Unpooled.buffer(initialCapacity);
  }

  this(ByteBuf buffer) {
    nettyBuffer = buffer;
  }

  public ByteBuf getBuffer() {
    return nettyBuffer;
  }

  override
  public void put(byte b) {
    nettyBuffer.writeByte(b);
  }

  override
  public void putFloat(float f) {
    nettyBuffer.writeFloat(f);
  }

  override
  public void putDouble(double d) {
    nettyBuffer.writeDouble(d);
  }

  override
  public void put(byte[] src, int offset, int length) {
    nettyBuffer.writeBytes(src, offset, length);
  }

  override
  public void put(ByteBuffer payload) {
    nettyBuffer.writeBytes(payload);
  }

  public void put(ByteBuf payload) {
    nettyBuffer.writeBytes(payload);
  }

  override
  public void putShort(short s) {
    nettyBuffer.writeShort(s);
  }

  override
  public void putInt(int i) {
    nettyBuffer.writeInt(i);
  }

  override
  public void putLong(long l) {
    nettyBuffer.writeLong(l);
  }

  override
  public bool hasRemaining() {
    return nettyBuffer.writerIndex() < nettyBuffer.maxCapacity();
  }

  override
  public int remaining() {
    return nettyBuffer.maxCapacity() - nettyBuffer.writerIndex();
  }

  override
  public void ensureRemaining(int remaining) {
    nettyBuffer.ensureWritable(remaining);
  }

  override
  public int position() {
    return nettyBuffer.writerIndex();
  }

  override
  public void position(int position) {
    nettyBuffer.writerIndex(position);
  }

  override
  public int limit() {
    return nettyBuffer.capacity();
  }

  override
  public void put(ReadableBuffer buffer) {
    buffer.get(this);
  }

  override
  public void put(string value) {
    nettyBuffer.writeCharSequence(value,StandardCharsets.UTF_8);
  }
}
