import 'dart:async';

import 'package:flutter/services.dart';

class FlutterBluetoothSerial {
  static const MethodChannel _channel =
      const MethodChannel('flutter_bluetooth_serial/methods');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<List> get bondedDevices async {
    return await _channel.invokeMethod('getBondedDevices');
  }
}
