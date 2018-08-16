import 'dart:async';

import 'package:flutter/services.dart';

class FlutterBluetoothSerial {
  static const String namespace = 'flutter_bluetooth_serial';

  static const MethodChannel _channel =
      const MethodChannel('$namespace/methods');

  static const EventChannel _readChannel =
      const EventChannel('$namespace/readChannel');

  static Future<List> get bondedDevices async {
    final List list = await _channel.invokeMethod('getBondedDevices');
    return list.map((map) => BluetoothDevice.fromMap(map)).toList();
  }

  static Future<String> get connect async {
    return await _channel.invokeMethod('connect');
  }
}

class BluetoothDevice {
  final String name;
  final String address;
  final int type;

  BluetoothDevice.fromMap(Map map)
      : name = map['name'],
        address = map['address'],
        type = map['type'];
}
