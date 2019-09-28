
const { BluetoothSerialPortServer } = require('bluetooth-serial-port');
const assert = require('assert');

require('./BaseIterable.js').registerIn(Array, Buffer);
const SkipIterable = require('./SkipIterable.js');
const TakeIterable = require('./TakeIterable.js');
const ChainedIterables = require('./ChainedIterables.js');
SkipIterable.registerIn(Array, Buffer, ChainedIterables, TakeIterable);
TakeIterable.registerIn(Array, Buffer, ChainedIterables, SkipIterable);
ChainedIterables.registerIn(Array, Buffer, SkipIterable, TakeIterable);

/// 
class BluetoothPacketsServerPort {
    constructor() {
        let self = this;
        this._serialPortServer = new BluetoothSerialPortServer();

        this._chunks = [];
        this._remainingBytes = 0;

        this.onPacket = undefined;
        this.onClosed = undefined;

        this._serialPortServer.on('data', (buffer) => {
            self._chunks.push(buffer);

            if (!(self.onPacket instanceof Function)) { // @WARN if packet handler null, packets handling is just halted!
                return null;
            }

            while (true) {
                let usedChunksCount = 1;
                let chunksIt = self._chunks.iterator;
                
                let nextChunk = chunksIt.next().value;
                let bytes = (
                    self._remainingBytes == 0 ? 
                        nextChunk : 
                        nextChunk.skip(self._remainingBytes)
                );
                let length = bytes.length;

                // Make sure we have enough for header
                while (length < 4) {
                    const result = chunksIt.next();
                    if (result.done) {
                        // Waiting for more data to read even the packet header
                        return;
                    }

                    bytes = bytes.chain(result.value);
                    length += result.value.length;
                    usedChunksCount += 1;
                }

                // Parse packet header
                let packetDataLength;
                let packetType;
                {
                    let headerIt = bytes.iterator;

                    // Read packet type
                    packetType = headerIt.next().value << 8;
                    packetType += headerIt.next().value;

                    // Read packet data length
                    packetDataLength = headerIt.next().value << 8;
                    packetDataLength += headerIt.next().value;
                }
                length -= 4;
                bytes = bytes.skip(4);

                // Take iterable for rest (packet data)
                while (true) {
                    const diff = length - packetDataLength;
                    if (diff >= 0) {
                        // Call the packet handler
                        self.onPacket(packetType, bytes.take(packetDataLength));

                        if (diff > 0) {
                            // Some still left, do not remove it
                            usedChunksCount -= 1;
                            self._remainingBytes = diff;
                        }

                        if (usedChunksCount == self._chunks.length) {
                            // If that's all - remove used chunks and done
                            self._chunks = [];
                            return;
                        }
                        else {
                            // Remove all used chunks and continue
                            self._chunks.splice(0, usedChunksCount);
                            break;
                        }
                    }

                    const result = chunksIt.next();
                    if (result.done) {
                        // Waiting for more data to read the packet data
                        return;
                    }

                    bytes = bytes.chain(result.value);
                    length += result.value.length;
                    usedChunksCount += 1;
                }
            }
        });

        this._serialPortServer.on('closed', () => {
            if (self.onClosed instanceof Function) {
                self.onClosed();
            }
        });
    }

    sendPacket(type, data) {
        if (data) {
            assert(data instanceof Buffer);
            this._serialPortServer.write(Buffer.from([
                (type >> 8) & 0xFF, 
                type & 0xFF, 
                (data.length >> 8) & 0xFF, 
                data.length & 0xFF
            ]), (e) => {});
            this._serialPortServer.write(data, (e) => {});
        }
        else {
            // No data packet
            this._serialPortServer.write(Buffer.from([
                (type >> 8) & 0xFF, 
                type & 0xFF, 
                0,
                0
            ]), (e) => {});
        }
    }

    ////////////////////////////////////////

    listen(onConnected, onError, options) {
        this._serialPortServer.listen(onConnected, onError, options);
    }

    close() {
        this._serialPortServer.close();
    }

    disconnectClient() {
        this._serialPortServer.disconnectClient();
    }

    get isOpen() {
        return this._serialPortServer.isOpen();
    }
}

module.exports = BluetoothPacketsServerPort;
