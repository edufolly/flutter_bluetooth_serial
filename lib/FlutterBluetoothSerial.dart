part of flutter_bluetooth_serial;

class FlutterBluetoothSerial {
  // Plugin
  static const String namespace = 'flutter_bluetooth_serial';

  static final MethodChannel _methodChannel = const MethodChannel('$namespace/methods');
  final StreamController<MethodCall> _methodStreamController = new StreamController.broadcast();
  Stream<MethodCall> get _methodStream => _methodStreamController.stream;
  FlutterBluetoothSerial._() {
    _methodChannel.setMethodCallHandler((MethodCall call) { _methodStreamController.add(call); });
  }

  static FlutterBluetoothSerial _instance = new FlutterBluetoothSerial._();
  static FlutterBluetoothSerial get instance => _instance;



  /* Status */
  /// Checks is the Bluetooth interface avaliable on host device.
  Future<bool> get isAvailable async => await _methodChannel.invokeMethod('isAvailable');

  /// Describes is the Bluetooth interface enabled on host device.
  Future<bool> get isEnabled async => await _methodChannel.invokeMethod('isEnabled');
  
  /// Checks is the Bluetooth interface enabled on host device.
  @Deprecated('Use `isEnabled` instead')
  Future<bool> get isOn async => await _methodChannel.invokeMethod('isOn');

  static final EventChannel _stateChannel = const EventChannel('$namespace/state');

  /// Allows monitoring the Bluetooth adapter state changes.
  Stream<BluetoothState> onStateChanged() => _stateChannel.receiveBroadcastStream().map((data) => BluetoothState.fromUnderlyingValue(data));

  /// State of the Bluetooth adapter.
  Future<BluetoothState> get state async => BluetoothState.fromUnderlyingValue(await _methodChannel.invokeMethod('getState'));



  /* Adapter settings and general */
  /// Tries to enable Bluetooth interface (if disabled). 
  /// Probably results in asking user for confirmation.
  Future<bool> requestEnable() async => await _methodChannel.invokeMethod('requestEnable');

  /// Tries to disable Bluetooth interface (if enabled).
  Future<bool> requestDisable() async => await _methodChannel.invokeMethod('requestDisable');

  /// Opens the Bluetooth platform system settings.
  Future<void> openSettings() async => await _methodChannel.invokeMethod('openSettings');

  // @TODO . add `discoverableName` (get/set)
  // @TODO . add `requestDiscoverable`



  /* Discovering and bonding devices */
  /// Checks bond state for given address (might be from system cache).
  Future<BluetoothBondState> getBondStateForAddress(String address) async {
    return BluetoothBondState.fromUnderlyingValue(await _methodChannel.invokeMethod('getDeviceBondState', {"address": address}));
  }

  /// Starts bonding with device with given address. 
  /// Returns true if bonded, false if canceled.
  /// 
  /// `pin` or `passkeyConfirm` could be used to automate the bonding process.
  /// Note: `passkeyConfirm` will probably not work, since 3rd party apps cannot
  /// get `BLUETOOTH_PRIVILEGED` permission (at least on newest Androids).
  Future<bool> bondDeviceAtAddress(String address, {String pin, bool passkeyConfirm = false}) async {
    return await _methodChannel.invokeMethod('bondDevice', {"address": address, "pin": pin, "passkeyConfirm": passkeyConfirm});
  }

  /// Returns list of bonded devices.
  Future<List<BluetoothDevice>> getBondedDevices() async {
    final List list = await _methodChannel.invokeMethod('getBondedDevices');
    return list.map((map) => BluetoothDevice.fromMap(map)).toList();
  }

  static final EventChannel _discoveryChannel = const EventChannel('$namespace/discovery');

  /// Describes is the dicovery process of Bluetooth devices running.
  Future<bool> get isDiscovering async => await _methodChannel.invokeMethod('isDiscovering');

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

    yield* controller.stream.map((map) => BluetoothDiscoveryResult.fromMap(map));
  }

  /// Cancels the discovery
  Future<void> cancelDiscovery() async => await _methodChannel.invokeMethod('cancelDiscovery');


  /* Connecting and connection */
  // Default connection methods
  BluetoothConnection _defaultConnection;

  @Deprecated('Use `BluetoothConnection.isEnabled` instead')
  Future<bool> get isConnected async => 
    Future.value(_defaultConnection == null ? false : _defaultConnection.isConnected);

  @Deprecated('Use `BluetoothConnection.toAddress(device.address)` instead')
  Future<void> connect(BluetoothDevice device) => connectToAddress(device.address);

  @Deprecated('Use `BluetoothConnection.toAddress(address)` instead')
  Future<void> connectToAddress(String address) => Future(() async {
    _defaultConnection = await BluetoothConnection.toAddress(address);
  });

  @Deprecated('Use `BluetoothConnection.finish` or `BluetoothConnection.close` instead')
  Future<void> disconnect() => _defaultConnection.finish();

  @Deprecated('Use `BluetoothConnection.input` instead')
  Stream<Uint8List> onRead() => _defaultConnection.input;

  @Deprecated('Use `BluetoothConnection.output` with some decoding (such as `ascii.decode` for strings) instead')
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
