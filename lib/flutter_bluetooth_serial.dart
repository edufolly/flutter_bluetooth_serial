import 'dart:async';

import 'package:flutter/services.dart';

class FlutterBluetoothSerial {
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

  Stream<String> onStateChanged() =>
      _stateChannel.receiveBroadcastStream().map((buffer) => buffer.toString());

  Stream<String> onRead() =>
      _readChannel.receiveBroadcastStream().map((buffer) => buffer.toString());

  Future<bool> get isAvailable => _channel.invokeMethod('isAvailable');

  Future<bool> get isOn => _channel.invokeMethod('isOn');

  Future<List> getBondedDevices() async {
    final List list = await _channel.invokeMethod('getBondedDevices');
    return list.map((map) => BluetoothDevice.fromMap(map)).toList();
  }

  Future<dynamic> connect(BluetoothDevice device) =>
      _channel.invokeMethod('connect', device.toMap());
}

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
        'connected': this.connected
      };
}
