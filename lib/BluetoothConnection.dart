part of flutter_bluetooth_serial;

/// Represents ongoing Bluetooth connection to remote device.
class BluetoothConnection {
  // Note by PsychoX at 2019-08-19 while working on issue #60:
  // Fixed and then tested whole thing multiple times:
  // - [X] basic `connect`, use `output`/`input` and `disconnect` by local scenario,
  // - [X] fail on connecting to device that isn't listening,
  // - [X] working `output` if no `listen`ing to `input`,
  // - [X] closing by local if no `input` written,
  // - [X] closing by local if no `listen`ing to `input` (this was the #60),
  // - [X] closing by remote if no `input` written,
  // - [X] closing by remote if no `listen`ing to `input`,
  //    It works, but library user is notifed either by error on `output.add` or
  //    by observing `connection.isConnected`. In "normal" conditions user can
  //    listen to `input` even just for the `onDone` to proper detect closing.
  //

  /// This ID identifies real full `BluetoothConenction` object on platform side code.
  final int _id;

  final EventChannel _readChannel;
  StreamSubscription<Uint8List> _readStreamSubscription;
  StreamController<Uint8List> _readStreamController;

  /// Stream sink used to read from the remote Bluetooth device
  ///
  /// `.onDone` could be used to detect when remote device closes the connection.
  ///
  /// You should use some encoding to receive string in your `.listen` callback, for example `ascii.decode(data)` or `utf8.encode(data)`.
  Stream<Uint8List> input;

  /// Stream sink used to write to the remote Bluetooth device
  ///
  /// You should use some encoding to send string, for example `.add(ascii.encode('Hello!'))` or `.add(utf8.encode('Cześć!))`.
  _BluetoothStreamSink<Uint8List> output;

  /// Describes is stream connected.
  bool get isConnected => output.isConnected;

  BluetoothConnection._consumeConnectionID(int id)
      : this._id = id,
        this._readChannel =
            EventChannel('${FlutterBluetoothSerial.namespace}/read/$id') {
    _readStreamController = StreamController<Uint8List>();

    _readStreamSubscription =
        _readChannel.receiveBroadcastStream().cast<Uint8List>().listen(
              _readStreamController.add,
              onError: _readStreamController.addError,
              onDone: this.close,
            );

    input = _readStreamController.stream;
    output = _BluetoothStreamSink<Uint8List>(id);
  }

  /// Returns connection to given address.
  static Future<BluetoothConnection> toAddress(String address) async {
    // Sorry for pseudo-factory, but `factory` keyword disallows `Future`.
    return BluetoothConnection._consumeConnectionID(await FlutterBluetoothSerial
        ._methodChannel
        .invokeMethod('connect', {"address": address}));
  }

  /// Should be called to make sure the connection is closed and resources are freed (sockets/channels).
  void dispose() {
    finish();
  }

  /// Closes connection (rather immediately), in result should also disconnect.
  Future<void> close() {
    return Future.wait([
      output.close(),
      _readStreamSubscription.cancel(),
      (!_readStreamController.isClosed)
          ? _readStreamController.close()
          : Future.value(/* Empty future */)
    ], eagerError: true);
  }

  /// Closes connection (rather immediately), in result should also disconnect.
  @Deprecated('Use `close` instead')
  Future<void> cancel() => this.close();

  /// Closes connection (rather gracefully), in result should also disconnect.
  Future<void> finish() async {
    await output.allSent;
    close();
  }
}

/// Helper class for sending responses.
class _BluetoothStreamSink<Uint8List> extends StreamSink<Uint8List> {
  final int _id;

  /// Describes is stream connected.
  bool isConnected = true;

  /// Chain of features, the variable represents last of the futures.
  Future<void> _chainedFutures = Future.value(/* Empty future :F */);

  Future<dynamic> _doneFuture;

  /// Exception to be returend from `done` Future, passed from `add` function or related.
  dynamic exception;

  _BluetoothStreamSink(this._id) {
    // `_doneFuture` must be initialized here because `close` must return the same future.
    // If it would be in `done` get body, it would result in creating new futures every call.
    _doneFuture = Future(() async {
      // @TODO ? is there any better way to do it? xD this below is weird af
      while (this.isConnected) {
        await Future.delayed(Duration(milliseconds: 111));
      }
      if (this.exception != null) {
        throw this.exception;
      }
    });
  }

  /// Adds raw bytes to the output sink.
  ///
  /// The data is sent almost immediately, but if you want to be sure,
  /// there is `this.allSent` that provides future which completes when
  /// all added data are sent.
  ///
  /// You should use some encoding to send string, for example `ascii.encode('Hello!')` or `utf8.encode('Cześć!)`.
  ///
  /// Might throw `StateError("Not connected!")` if not connected.
  @override
  void add(Uint8List data) {
    if (!isConnected) {
      throw StateError("Not connected!");
    }

    _chainedFutures = _chainedFutures.then((_) async {
      if (!isConnected) {
        throw StateError("Not connected!");
      }

      await FlutterBluetoothSerial._methodChannel
          .invokeMethod('write', {'id': _id, 'bytes': data});
    }).catchError((e) {
      this.exception = e;
      close();
    });
  }

  /// Unsupported - this ouput sink cannot pass errors to platfom code.
  @override
  void addError(Object error, [StackTrace stackTrace]) {
    throw UnsupportedError(
        "BluetoothConnection output (response) sink cannot receive errors!");
  }

  @override
  Future addStream(Stream<Uint8List> stream) => Future(() async {
        // @TODO ??? `addStream`, "alternating simultaneous addition" problem (read below)
        // If `onDone` were called some time after last `add` to the stream (what is okay),
        // this `addStream` function might wait not for the last "own" addition to this sink,
        // but might wait for last addition at the moment of the `onDone`.
        // This can happen if user of the library would use another `add` related function
        // while `addStream` still in-going. We could do something about it, but this seems
        // not to be so necessary since `StreamSink` specifies that `addStream` should be
        // blocking for other forms of `add`ition on the sink.
        var completer = Completer();
        stream.listen(this.add).onDone(completer.complete);
        await completer.future;
        await _chainedFutures; // Wait last* `add` of the stream to be fulfilled
      });

  @override
  Future close() {
    isConnected = false;
    return this.done;
  }

  @override
  Future get done => _doneFuture;

  /// Returns a future which is completed when the sink sent all added data,
  /// instead of only if the sink got closed.
  ///
  /// Might fail with an error in case if some occured while sending the data.
  /// Typical error could be `StateError("Not connected!")` which could happen
  /// if disconnected in middle of sending (queued) `add`ed data.
  ///
  /// Otherwise, the returned future will complete when either:
  Future get allSent => Future(() async {
        // Simple `await` can't get job done here, because the `_chainedFutures` member
        // in one access time provides last Future, then `await`ing for it allows the library
        // user to add more futures on top of the waited-out Future.
        Future lastFuture;
        do {
          lastFuture = this._chainedFutures;
          await lastFuture;
        } while (lastFuture != this._chainedFutures);

        if (this.exception != null) {
          throw this.exception;
        }

        this._chainedFutures =
            Future.value(); // Just in case if Dart VM is retarded
      });
}
