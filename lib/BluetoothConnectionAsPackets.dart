import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

/// Helper class for packets communication between Bluetooth devices.
class BluetoothConnectionAsPackets {
  /// Basic `BluetoothConnection` that `BluetoothConnectionAsPackets` were constructed from.
  BluetoothConnection connection;

  /// Chunks of `Uint8List` (as they come via `BluetoothConnection`)
  ListQueue<Uint8List> _chunks = ListQueue();

  /// Remaining bytes of first chunk after parsing last packet.
  /// 
  /// Zero means that no bytes are remaining, and the first chunk in `_chunks`
  /// is fresh one. Above zero means how many bytes should be omitted in the
  /// first chunk.
  int _remainingBytes = 0;

  /// Handler for incoming packets. Setable via `onPacket`. 
  /// 
  /// Warning: If equal to `null`, packets handling is just halted!
  Function _packetHandler;

  /// Handler for end of packets event. Setable via `onPacket`.
  Function _doneHandler;

  /// Describes is connection alive.
  bool get isConnected => connection.isConnected;

  /// Constructs `BluetoothConnectionAsPackets` by consuming `BluetoothConnection`.
  BluetoothConnectionAsPackets.fromConnection(BluetoothConnection connection) :
    this.connection = connection
  {
    this.connection.input.listen((Uint8List data) {
      _chunks.add(data);

      if (_packetHandler == null) { // @WARN if packet handler null, packets handling is just halted!
        return null;
      }

      while (true) {
        int usedChunksCount = 1;
        Iterator<Uint8List> chunksIt = _chunks.iterator..moveNext();

        Iterable<int> bytes = (
          _remainingBytes == 0 ? 
            chunksIt.current : 
            chunksIt.current.skip(_remainingBytes)
        );
        int length = bytes.length;

        // Make sure we have enough for header
        while (length < 4) {
          if (!chunksIt.moveNext()) {
            // Waiting for more data to read at least the packet header
            return null;
          }

          bytes = bytes.followedBy(chunksIt.current);
          length += chunksIt.current.length;
          usedChunksCount += 1;
        }

        // Parse packet header
        int packetDataLength;
        int packetType;
        {
          Iterator<int> headerIt = bytes.iterator;

          // Read packet type
          headerIt.moveNext();
          packetType = headerIt.current << 8;
          headerIt.moveNext();
          packetType += headerIt.current;

          // Read packet data length
          headerIt.moveNext();
          packetDataLength = headerIt.current << 8;
          headerIt.moveNext();
          packetDataLength += headerIt.current;
        }
        length -= 4;
        bytes = bytes.skip(4);

        // Take iterable for rest (packet data)
        while (true) {
          int diff = length - packetDataLength;
          if (diff >= 0) {
            // Call the packet handler
            _packetHandler(packetType, UnmodifiableListView(bytes.take(packetDataLength)));

            if (diff > 0) {
              // Some still left, do not remove it
              usedChunksCount -= 1;
              _remainingBytes = diff;
            }

            // Remove all used chunks
            if (usedChunksCount == _chunks.length) {
              // If that's all - remove used chunks and done
              _chunks.clear();
              return null;
            }
            else {
              // Remove all used chunks and continue
              while (--usedChunksCount != 0) {
                _chunks.removeFirst();
              }
              break;
            }
          }

          if (!chunksIt.moveNext()) {
            // Waiting for more data to read the packet data
            return null;
          }

          bytes = bytes.followedBy(chunksIt.current);
          length += chunksIt.current.length;
          usedChunksCount += 1;
        }
      }
    }).onDone(() {
      if (_doneHandler != null) {
        // Call the onDone handler
        _doneHandler();
      }
    });
  }

  /// Should be called to make sure the connection is closed and resources are freed (sockets/channels).
  dispose() {
    connection.dispose();
  }

  /// Replaces incoming packet event handler.
  /// 
  /// Passed `handler` function is called when next full packet (with all 
  /// the data) is received. `data` argument may be null, if there was no
  /// data (packet length equal to 0).
  /// 
  /// Warning: Data iteratable passed to `handler` is using non-mutable view 
  /// of underlying buffer - to provide better performance. Keep that in mind
  /// when using the data in asynchronous manner. You might want to either 
  /// parse/load the data in sychronous manner or copy the iterable.
  void onPacket(void handler(int type, Iterable<int> data)) {
    _packetHandler = handler;
  }

  /// Sends given packet `type` with given `data` attached.
  /// 
  /// Note: `type` must be 16 bit integer. `data` length is limited to 65535.
  Future<void> sendPacket(int type, [Uint8List data]) async {
    if (data == null) {
      connection.output.add(Uint8List.fromList([
        (type >> 8) & 0xFF, 
        type & 0xFF, 
        0, 
        0
      ]));
    }
    else {
      connection.output.add(Uint8List.fromList([
        (type >> 8) & 0xFF, 
        type & 0xFF, 
        (data.length >> 8) & 0xFF, 
        data.length & 0xFF
      ]));
      connection.output.add(data);
    }
    await connection.output.allSent;
  }

  ////////////////////////////////////////

  /// Replaces end of packet event handler.
  /// 
  /// Passed `handler` function is called when connection closes, 
  /// so there will be no more packets to read.
  void onDone(void handler()) {
    _doneHandler = handler;
  }  

  /// Closes connection (rather immediately), in result should also disconnect.
  Future<void> close() => connection.close();

  /// Closes connection (rather immediately), in result should also disconnect.
  @Deprecated('Use `close` instead')
  Future<void> cancel() => connection.close();

  /// Closes connection (rather gracefully), in result should also disconnect.
  Future<void> finish() => connection.finish();
}
