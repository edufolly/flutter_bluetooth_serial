part of flutter_bluetooth_serial;

class FlutterBluetoothSerial {
  // Plugin
  static const String namespace = 'flutter_bluetooth_serial';

  static FlutterBluetoothSerial _instance = new FlutterBluetoothSerial._();
  static FlutterBluetoothSerial get instance => _instance;

  static final MethodChannel _methodChannel =
      const MethodChannel('$namespace/methods');

  FlutterBluetoothSerial._() {
    _methodChannel.setMethodCallHandler((MethodCall call) {
      switch (call.method) {
        case 'handlePairingRequest':
          if (_pairingRequestHandler != null) {
            return _pairingRequestHandler(
                BluetoothPairingRequest.fromMap(call.arguments));
          }
          return null;
          break;

        default:
          throw 'unknown common code method - not implemented';
          break;
      }
    });
  }

  /* Status */
  /// Checks is the Bluetooth interface avaliable on host device.
  Future<bool> get isAvailable async =>
      await _methodChannel.invokeMethod('isAvailable');

  /// Describes is the Bluetooth interface enabled on host device.
  Future<bool> get isEnabled async =>
      await _methodChannel.invokeMethod('isEnabled');

  /// Checks is the Bluetooth interface enabled on host device.
  @Deprecated('Use `isEnabled` instead')
  Future<bool> get isOn async => await _methodChannel.invokeMethod('isOn');

  static final EventChannel _stateChannel =
      const EventChannel('$namespace/state');

  /// Allows monitoring the Bluetooth adapter state changes.
  Stream<BluetoothState> onStateChanged() => _stateChannel
      .receiveBroadcastStream()
      .map((data) => BluetoothState.fromUnderlyingValue(data));

  /// State of the Bluetooth adapter.
  Future<BluetoothState> get state async => BluetoothState.fromUnderlyingValue(
      await _methodChannel.invokeMethod('getState'));

  /// Returns the hardware address of the local Bluetooth adapter.
  ///
  /// Does not work for third party applications starting at Android 6.0.
  Future<String> get address => _methodChannel.invokeMethod("getAddress");

  /// Returns the friendly Bluetooth name of the local Bluetooth adapter.
  ///
  /// This name is visible to remote Bluetooth devices.
  ///
  /// Does not work for third party applications starting at Android 6.0.
  Future<String> get name => _methodChannel.invokeMethod("getName");

  /// Sets the friendly Bluetooth name of the local Bluetooth adapter.
  ///
  /// This name is visible to remote Bluetooth devices.
  ///
  /// Valid Bluetooth names are a maximum of 248 bytes using UTF-8 encoding,
  /// although many remote devices can only display the first 40 characters,
  /// and some may be limited to just 20.
  ///
  /// Does not work for third party applications starting at Android 6.0.
  Future<bool> changeName(String name) =>
      _methodChannel.invokeMethod("setName", {"name": name});

  /* Adapter settings and general */
  /// Tries to enable Bluetooth interface (if disabled).
  /// Probably results in asking user for confirmation.
  Future<bool> requestEnable() async =>
      await _methodChannel.invokeMethod('requestEnable');

  /// Tries to disable Bluetooth interface (if enabled).
  Future<bool> requestDisable() async =>
      await _methodChannel.invokeMethod('requestDisable');

  /// Opens the Bluetooth platform system settings.
  Future<void> openSettings() async =>
      await _methodChannel.invokeMethod('openSettings');

  /* Discovering and bonding devices */
  /// Checks bond state for given address (might be from system cache).
  Future<BluetoothBondState> getBondStateForAddress(String address) async {
    return BluetoothBondState.fromUnderlyingValue(await _methodChannel
        .invokeMethod('getDeviceBondState', {"address": address}));
  }

  /// Starts outgoing bonding (pairing) with device with given address.
  /// Returns true if bonded, false if canceled or failed gracefully.
  ///
  /// `pin` or `passkeyConfirm` could be used to automate the bonding process,
  /// using provided pin or confirmation if necessary. Can be used only if no
  /// pairing request handler is already registered.
  ///
  /// Note: `passkeyConfirm` will probably not work, since 3rd party apps cannot
  /// get `BLUETOOTH_PRIVILEGED` permission (at least on newest Androids).
  Future<bool> bondDeviceAtAddress(String address,
      {String pin, bool passkeyConfirm}) async {
    if (pin != null || passkeyConfirm != null) {
      if (_pairingRequestHandler != null) {
        throw "pairing request handler already registered";
      }
      setPairingRequestHandler((BluetoothPairingRequest request) async {
        Future.delayed(Duration(seconds: 1), () {
          setPairingRequestHandler(null);
        });
        if (pin != null) {
          switch (request.pairingVariant) {
            case PairingVariant.Pin:
              return pin;
            default:
              // Other pairing variant requested, ignoring pin
              break;
          }
        }
        if (passkeyConfirm != null) {
          switch (request.pairingVariant) {
            case PairingVariant.Consent:
            case PairingVariant.PasskeyConfirmation:
              return passkeyConfirm;
            default:
              // Other pairing variant requested, ignoring confirming
              break;
          }
        }
        // Other pairing variant used, cannot automate
        return null;
      });
    }
    return await _methodChannel
        .invokeMethod('bondDevice', {"address": address});
  }

  /// Removes bond with device with specified address.
  /// Returns true if unbonded, false if canceled or failed gracefully.
  ///
  /// Note: May not work at every Android device!
  Future<bool> removeDeviceBondWithAddress(String address) async =>
      await _methodChannel
          .invokeMethod('removeDeviceBond', {'address': address});

  // Function used as pairing request handler.
  Function _pairingRequestHandler;

  /// Allows listening and responsing for incoming pairing requests.
  ///
  /// Various variants of pairing requests might require different returns:
  /// * `PairingVariant.Pin` or `PairingVariant.Pin16Digits`
  /// (prompt to enter a pin)
  ///   - return string containing the pin for pairing
  ///   - return `false` to reject.
  /// * `BluetoothDevice.PasskeyConfirmation`
  /// (user needs to confirm displayed passkey, no rewriting necessary)
  ///   - return `true` to accept, `false` to reject.
  ///   - there is `passkey` parameter available.
  /// * `PairingVariant.Consent`
  /// (just prompt with device name to accept without any code or passkey)
  ///   - return `true` to accept, `false` to reject.
  ///
  /// If returned null, the request will be passed for manual pairing
  /// using default Android Bluetooth settings pairing dialog.
  ///
  /// Note: Accepting request variant of `PasskeyConfirmation` and `Consent`
  /// will probably fail, because it require Android `setPairingConfirmation`
  /// which requires `BLUETOOTH_PRIVILEGED` permission that 3rd party apps
  /// cannot acquire (at least on newest Androids) due to security reasons.
  ///
  /// Note: It is necessary to return from handler within 10 seconds, since
  /// Android BroadcastReceiver can wait safely only up to that duration.
  void setPairingRequestHandler(
      Future<dynamic> handler(BluetoothPairingRequest request)) {
    if (handler == null) {
      _pairingRequestHandler = null;
      _methodChannel.invokeMethod('pairingRequestHandlingDisable');
      return;
    }
    if (_pairingRequestHandler == null) {
      _methodChannel.invokeMethod('pairingRequestHandlingEnable');
    }
    _pairingRequestHandler = handler;
  }

  /// Returns list of bonded devices.
  Future<List<BluetoothDevice>> getBondedDevices() async {
    final List list = await _methodChannel.invokeMethod('getBondedDevices');
    return list.map((map) => BluetoothDevice.fromMap(map)).toList();
  }

  static final EventChannel _discoveryChannel =
      const EventChannel('$namespace/discovery');

  /// Describes is the dicovery process of Bluetooth devices running.
  Future<bool> get isDiscovering async =>
      await _methodChannel.invokeMethod('isDiscovering');

  /// Starts discovery and provides stream of `BluetoothDiscoveryResult`s.
  Stream<BluetoothDiscoveryResult> startDiscovery() async* {
    StreamSubscription subscription;
    StreamController controller;

    controller = new StreamController(
      onCancel: () {
        // `cancelDiscovery` happens automaticly by platform code when closing event sink
        subscription.cancel();
      },
    );

    await _methodChannel.invokeMethod('startDiscovery');

    subscription = _discoveryChannel.receiveBroadcastStream().listen(
          controller.add,
          onError: controller.addError,
          onDone: controller.close,
        );

    yield* controller.stream
        .map((map) => BluetoothDiscoveryResult.fromMap(map));
  }

  /// Cancels the discovery
  Future<void> cancelDiscovery() async =>
      await _methodChannel.invokeMethod('cancelDiscovery');

  /// Describes is the local device in discoverable mode.
  Future<bool> get isDiscoverable =>
      _methodChannel.invokeMethod("isDiscoverable");

  /// Asks for discoverable mode (probably always prompt for user interaction in fact).
  /// Returns number of seconds acquired or zero if canceled or failed gracefully.
  ///
  /// Duration might be capped to 120, 300 or 3600 seconds on some devices.
  Future<int> requestDiscoverable(int durationInSeconds) async =>
      await _methodChannel
          .invokeMethod("requestDiscoverable", {"duration": durationInSeconds});

  /* Connecting and connection */
  // Default connection methods
  BluetoothConnection _defaultConnection;

  @Deprecated('Use `BluetoothConnection.isEnabled` instead')
  Future<bool> get isConnected async => Future.value(
      _defaultConnection == null ? false : _defaultConnection.isConnected);

  @Deprecated('Use `BluetoothConnection.toAddress(device.address)` instead')
  Future<void> connect(BluetoothDevice device) =>
      connectToAddress(device.address);

  @Deprecated('Use `BluetoothConnection.toAddress(address)` instead')
  Future<void> connectToAddress(String address) => Future(() async {
        _defaultConnection = await BluetoothConnection.toAddress(address);
      });

  @Deprecated(
      'Use `BluetoothConnection.finish` or `BluetoothConnection.close` instead')
  Future<void> disconnect() => _defaultConnection.finish();

  @Deprecated('Use `BluetoothConnection.input` instead')
  Stream<Uint8List> onRead() => _defaultConnection.input;

  @Deprecated(
      'Use `BluetoothConnection.output` with some decoding (such as `ascii.decode` for strings) instead')
  Future<void> write(String message) {
    _defaultConnection.output.add(utf8.encode(message));
    return _defaultConnection.output.allSent;
  }

  @Deprecated('Use `BluetoothConnection.output` instead')
  Future<void> writeBytes(Uint8List message) {
    _defaultConnection.output.add(message);
    return _defaultConnection.output.allSent;
  }
}
