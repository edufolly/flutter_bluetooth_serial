import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;

  List<BluetoothDevice> _devices = [];

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    List<BluetoothDevice> devices = [];

    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException {
      // platformVersion = 'Failed to get platform version.';
    }

    bluetooth.onStateChanged().listen((msg) => print(msg));

    bluetooth.onRead().listen((msg) => print(msg));

    if (!mounted) return;
    setState(() {
      _devices = devices;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter Bluetooth Serial'),
        ),
        body: ListView(
          children: _devices
              .map((device) => ListTile(
                    title: Text(device.name),
                    subtitle: Text(device.address),
                    trailing: RaisedButton(
                        onPressed: () {
                          _connect(device);
                        },
                        child:
                            Text(device.connected ? "Disconnect" : "Connect")),
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _connect(BluetoothDevice device) async {
    var connected = await bluetooth.connect(device);
    print(connected);
  }
}
