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
module hunt.amqp.impl.ProtonReadableBufferImpl;

import hunt.collection.ByteBuffer;

import hunt.proton.codec.ReadableBuffer;
import hunt.proton.codec.WritableBuffer;
import hunt.text.Charset;
import hunt.net.buffer.ByteBuf;

/**
 * Proton ReadableBuffer implementation that wraps a Netty ByteBuf
 */
class ProtonReadableBufferImpl : ReadableBuffer {

  private ByteBuf buffer;

  this(ByteBuf buffer) {
    this.buffer = buffer;
  }

  public ByteBuf getBuffer() {
    return buffer;
  }

  
  public int capacity() {
    return buffer.capacity();
  }

  
  public bool hasArray() {
    return buffer.hasArray();
  }

  
  public byte[] array() {
    return buffer.array();
  }

  
  public int arrayOffset() {
    return buffer.arrayOffset();
  }

  
  public ReadableBuffer reclaimRead() {
    return this;
  }

  
  public byte get() {
    return buffer.readByte();
  }

  
  public byte get(int index) {
    return buffer.getByte(index);
  }

  
  public int getInt() {
    return buffer.readInt();
  }

  
  public long getLong() {
    return buffer.readLong();
  }

  
  public short getShort() {
    return buffer.readShort();
  }

  
  public float getFloat() {
    return buffer.readFloat();
  }

  
  public double getDouble() {
    return buffer.readDouble();
  }

  
  public ReadableBuffer get(byte[] target, int offset, int length) {
    buffer.readBytes(target, offset, length);
    return this;
  }

  
  public ReadableBuffer get(byte[] target) {
    buffer.readBytes(target);
    return this;
  }

  
  public ReadableBuffer get(WritableBuffer target) {
    int start = target.position();

    if (buffer.hasArray()) {
      target.put(buffer.array(), buffer.arrayOffset() + buffer.readerIndex(), buffer.readableBytes());
    } else {
      target.put(buffer.nioBuffer());
    }

    int written = target.position() - start;

    buffer.readerIndex(buffer.readerIndex() + written);

    return this;
  }

  
  public ReadableBuffer slice() {
    return new ProtonReadableBufferImpl(buffer.slice());
  }

  
  public ReadableBuffer flip() {
    buffer.setIndex(0, buffer.readerIndex());
    return this;
  }

  
  public ReadableBuffer limit(int limit) {
    buffer.writerIndex(limit);
    return this;
  }

  
  public int limit() {
    return buffer.writerIndex();
  }

  
  public ReadableBuffer position(int position) {
    buffer.readerIndex(position);
    return this;
  }

  int opCmp(ReadableBuffer o)
  {
      return buffer.readableBytes -  (cast(ProtonReadableBufferImpl)o).buffer.readableBytes ;
  }
  
  public int position() {
    return buffer.readerIndex();
  }

  
  public ReadableBuffer mark() {
    buffer.markReaderIndex();
    return this;
  }

  
  public ReadableBuffer reset() {
    buffer.resetReaderIndex();
    return this;
  }

  
  public ReadableBuffer rewind() {
    buffer.readerIndex(0);
    return this;
  }

  
  public ReadableBuffer clear() {
    buffer.setIndex(0, buffer.capacity());
    return this;
  }

  
  public int remaining() {
    return buffer.readableBytes();
  }

  
  public bool hasRemaining() {
    return buffer.isReadable();
  }

  
  public ReadableBuffer duplicate() {
    return new ProtonReadableBufferImpl(buffer.duplicate());
  }

  
  public ByteBuffer byteBuffer() {
    return buffer.nioBuffer();
  }

  
  public string readUTF8()  {
    return buffer.toString(StandardCharsets.UTF_8);
  }

  
  public string readString() {
    return buffer.toString(StandardCharsets.UTF_8);
  }
}
