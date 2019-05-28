part of flutter_bluetooth_serial;

class FlutterBluetoothSerial {
  // Plugin
  static const String namespace = 'flutter_bluetooth_serial';

  static const MethodChannel _methodChannel = const MethodChannel('$namespace/methods');
  final StreamController<MethodCall> _methodStreamController = new StreamController.broadcast();
  Stream<MethodCall> get _methodStream => _methodStreamController.stream;
  FlutterBluetoothSerial._() {
    _methodChannel.setMethodCallHandler((MethodCall call) { _methodStreamController.add(call); });
  }

  static FlutterBluetoothSerial _instance = new FlutterBluetoothSerial._();
  static FlutterBluetoothSerial get instance => _instance;



  // Status
  Future<bool> get isAvailable async => await _methodChannel.invokeMethod('isAvailable');

  Future<bool> get isOn async => await _methodChannel.invokeMethod('isOn');
  Future<bool> get isEnabled async => await _methodChannel.invokeMethod('isEnabled');

  static const EventChannel _stateChannel = const EventChannel('$namespace/state');
  Stream<BluetoothStatus> onStateChanged() => _stateChannel.receiveBroadcastStream().map((data) => BluetoothStatus.fromUnderlyingValue(data));

  Future<BluetoothStatus> get state async => BluetoothStatus.fromUnderlyingValue(await _methodChannel.invokeMethod('getState'));



  // Settings
  Future<bool> requestEnable() async => await _methodChannel.invokeMethod('requestEnable');
  Future<bool> requestDisable() async => await _methodChannel.invokeMethod('requestDisable');

  Future<void> openSettings() async => await _methodChannel.invokeMethod('openSettings');

  Future<List<BluetoothDevice>> getBondedDevices() async {
    final List list = await _methodChannel.invokeMethod('getBondedDevices');
    return list.map((map) => BluetoothDevice.fromMap(map)).toList();
  }



  // Discovery
  static const EventChannel _discoveryChannel = const EventChannel('$namespace/discovery');

  Future<bool> get isDiscovering async => await _methodChannel.invokeMethod('isDiscovering');

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

  Future<bool> cancelDiscovery() async => await _methodChannel.invokeMethod('cancelDiscovery');



  // Connection
  Future<bool> get isConnected async =>
    await _methodChannel.invokeMethod('isConnected');

  Future<void> connect(BluetoothDevice device) => _methodChannel.invokeMethod('connect', {"address": device.address});
  Future<void> connectToAddress(String address) => _methodChannel.invokeMethod('connect', {"address": address});

  Future<void> disconnect() => _methodChannel.invokeMethod('disconnect');

  static const EventChannel _readChannel = const EventChannel('$namespace/read');
  Stream<Uint8List> onRead() => _readChannel.receiveBroadcastStream().map((list) => list as Uint8List);

  Future<void> write(String message) => _methodChannel.invokeMethod('write', {'message': message});

  Future<void> writeBytes(Uint8List message) => _methodChannel.invokeMethod('writeBytes', {'message': message});
}
