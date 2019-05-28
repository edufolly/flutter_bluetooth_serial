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

  Future<bool> get isOn async => await _methodChannel.invokeMethod('isOn');
  Future<bool> get isEnabled async => await _methodChannel.invokeMethod('isEnabled');

  static const EventChannel _stateChannel = const EventChannel('$namespace/state');
  Stream<BluetoothStatus> onStateChanged() => _stateChannel.receiveBroadcastStream().map((data) => BluetoothStatus.fromUnderlyingValue(data));

  Future<BluetoothStatus> get state async => BluetoothStatus.fromUnderlyingValue(await _methodChannel.invokeMethod('getState'));




  /* Settings */
  /// Tries to enable Bluetooth interface (if disabled). 
  /// Probably results in asking user for confirmation.
  Future<bool> requestEnable() async => await _methodChannel.invokeMethod('requestEnable');

  /// Tries to disable Bluetooth interface (if enabled).
  Future<bool> requestDisable() async => await _methodChannel.invokeMethod('requestDisable');

  /// Opens the Bluetooth platform system settings.
  Future<void> openSettings() async => await _methodChannel.invokeMethod('openSettings');

  // @TODO . add `discoverableName` (get/set)
  // @TODO . add `requestDiscoverable`



  /* Discovering devices */
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
      onListen: () {},
      onCancel: () async {
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


  // Connection
  Future<bool> get isConnected async => await _methodChannel.invokeMethod('isConnected');

  Future<void> connect(BluetoothDevice device) => connectToAddress(device.address);
  Future<void> connectToAddress(String address) => _methodChannel.invokeMethod('connect', {"address": address});

  Future<void> disconnect() => _methodChannel.invokeMethod('disconnect');

  static const EventChannel _readChannel = const EventChannel('$namespace/read');
  Stream<Uint8List> onRead() => _readChannel.receiveBroadcastStream().map((list) => list as Uint8List);

  Future<void> write(String message) => _methodChannel.invokeMethod('write', {'message': message});

  Future<void> writeBytes(Uint8List message) => _methodChannel.invokeMethod('writeBytes', {'message': message});
}
