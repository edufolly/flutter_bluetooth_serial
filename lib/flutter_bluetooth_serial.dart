import 'dart:async';

import 'package:flutter/services.dart';

///
///
///
class FlutterBluetoothSerial {
  static const int STATE_OFF = 10;
  static const int STATE_TURNING_ON = 11;
  static const int STATE_ON = 12;
  static const int STATE_TURNING_OFF = 13;
  static const int STATE_BLE_TURNING_ON = 14;
  static const int STATE_BLE_ON = 15;
  static const int STATE_BLE_TURNING_OFF = 16;
  static const int ERROR = -1;
  static const int CONNECTED = 1;
  static const int DISCONNECTED = 0;

  static const String namespace = 'flutter_bluetooth_serial';

  static const MethodChannel _channel =
      const MethodChannel('$namespace/methods');

  static const EventChannel _readChannel =
      const EventChannel('$namespace/read');

  static const EventChannel _stateChannel =
      const EventChannel('$namespace/state');

  final StreamController<MethodCall> _methodStreamController =
      new StreamController.broadcast();

  Stream<MethodCall> get _methodStream => _methodStreamController.stream;

  FlutterBluetoothSerial._() {
    _channel.setMethodCallHandler((MethodCall call) {
      _methodStreamController.add(call);
    });
  }

  static FlutterBluetoothSerial _instance = new FlutterBluetoothSerial._();

  static FlutterBluetoothSerial get instance => _instance;

  Stream<int> onStateChanged() =>
      _stateChannel.receiveBroadcastStream().map((buffer) => buffer);

  Stream<String> onRead() =>
      _readChannel.receiveBroadcastStream().map((buffer) => buffer.toString());

  Future<bool> get isAvailable async =>
      await _channel.invokeMethod('isAvailable');

  Future<bool> get isOn async => await _channel.invokeMethod('isOn');

  Future<bool> get isConnected async =>
      await _channel.invokeMethod('isConnected');

  Future<bool> get openSettings async =>
      await _channel.invokeMethod('openSettings');

  Future<List> getBondedDevices() async {
    final List list = await _channel.invokeMethod('getBondedDevices');
    return list.map((map) => BluetoothDevice.fromMap(map)).toList();
  }

  Future<dynamic> connect(BluetoothDevice device) =>
      _channel.invokeMethod('connect', device.toMap());

  Future<dynamic> disconnect() => _channel.invokeMethod('disconnect');

  Future<dynamic> write(String message) =>
      _channel.invokeMethod('write', {'message': message});
}

///
///
///
class BluetoothDevice {
  final String name;
  final String address;
  final int type;
  bool connected = false;

  BluetoothDevice.fromMap(Map map)
      : name = map['name'],
        address = map['address'],
        type = map['type'];

  Map<String, dynamic> toMap() => {
        'name': this.name,
        'address': this.address,
        'type': this.type,
        'connected': this.connected,
      };
}
