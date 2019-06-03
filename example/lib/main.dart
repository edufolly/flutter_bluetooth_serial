import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

void main() => runApp(new MyApp());

///
///
///
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

///
///
///
class _MyAppState extends State<MyApp> {
  static final TextEditingController _message = new TextEditingController();
   static final TextEditingController _pin = new TextEditingController();
  static final TextEditingController _text = new TextEditingController();

  FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;

  List<BluetoothDevice> _devices = [];
  BluetoothDevice _device;
  bool _isBonded;
  bool _connected = false;
  bool _pressed = false;

  ///
  ///
  ///
  @override
  void initState() {
    super.initState();
    initPlatformState();
    _pin.text = "0000";
  }

  ///
  ///
  ///
  Future<void> initPlatformState() async {
    List<BluetoothDevice> devices = [];

    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException {
      // TODO - Error
    }

    bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case FlutterBluetoothSerial.CONNECTED:
          setState(() {
            _connected = true;
            _pressed = false;
          });
          break;
        case FlutterBluetoothSerial.DISCONNECTED:
          setState(() {
            _connected = false;
            _pressed = false;
          });
          break;
        default:
          // TODO
          print(state);
          break;
      }
    });

    bluetooth.onRead().listen((msg) {
      setState(() {
        print('Read: $msg');
        _text.text += msg;
      });
    });

    bluetooth.onReadByte().listen((dataArray){
      print(dataArray.toString());
    });

    if (!mounted) return;
    setState(() {
      _devices = devices;
    });
  }

  ///
  ///
  ///
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter Bluetooth Serial'),
        ),
        body: Container(
          child: ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Device:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    DropdownButton(
                      items: _getDeviceItems(),
                      onChanged: (value) {
                          _getIsBonded(value).then((bonded){
                            _isBonded = bonded;
                          });

                          setState((){
                            _device = value;
                          });
                      },
                      value: _device,
                    ),
                    Text("isBonded:" + _isBonded.toString()),
                    RaisedButton(
                      onPressed:
                          _pressed ? null : _connected ? _disconnect : _connect,
                      child: Text(_connected ? 'Disconnect' : 'Connect'),
                    ),
                    RaisedButton(
                      onPressed: _scanDevices,
                      child: Text("Scan"),
                      )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 0.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: new TextField(
                        controller: _pin,
                        autocorrect: false,
                        keyboardType: TextInputType.number,
                        decoration: new InputDecoration(
                          border: InputBorder.none,
                          labelText: 'PIN:',
                        ),
                      ),
                    ),
                    RaisedButton(
                      onPressed: _bondDevice,
                      child: Text('Bond'),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 0.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: new TextField(
                        controller: _message,
                        autocorrect: false,
                        keyboardType: TextInputType.text,
                        decoration: new InputDecoration(
                          border: InputBorder.none,
                          labelText: 'Message:',
                        ),
                      ),
                    ),
                    RaisedButton(
                      onPressed: _connected ? _writeTest : null,
                      child: Text('Send'),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: TextField(
                  controller: _text,
                  maxLines: null,
                  enabled: false,
                  decoration: new InputDecoration(
                    border: InputBorder.none,
                    labelText: 'Message:',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///
  ///
  ///
  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devices.isEmpty) {
      items.add(DropdownMenuItem(
        child: Text('NONE'),
      ));
    } else {
      _devices.forEach((device) {
        items.add(DropdownMenuItem(
          child: Text(device.name),
          value: device,
        ));
      });
    }
    return items;
  }

  ///
  ///
  ///
  void _connect() {
    if (_device == null) {
      show('No device selected.');
    } else {
      bluetooth.isConnected.then((isConnected) {
        if (!isConnected) {
          bluetooth.connect(_device).catchError((error) {
            setState(() => _pressed = false);
          });
          setState(() => _pressed = true);
        }
      });
    }
  }

  void _scanDevices() {
    _devices.clear();
    bluetooth.scanDevices().then((items){
        for(var item in items) {
          _devices.add(item);
        }
        setState(() {
         //trigger repaint 
        });
    });
  }

  _bondDevice() {
        bluetooth.bondDevice(_device, pin: _pin.text);
  }

  Future<bool> _getIsBonded(BluetoothDevice device) {
    return bluetooth.isBonded(device);
  }

  ///
  ///
  ///
  void _disconnect() {
    bluetooth.disconnect();
    setState(() => _pressed = true);
  }

  ///
  ///
  ///
  void _writeTest() {
    bluetooth.isConnected.then((isConnected) {
      if (isConnected) {
        bluetooth.write(_message.text);
      }
    });
  }

  ///
  ///
  ///
  Future show(
    String message, {
    Duration duration: const Duration(seconds: 3),
  }) async {
    await new Future.delayed(new Duration(milliseconds: 100));
    Scaffold.of(context).showSnackBar(
      new SnackBar(
        content: new Text(
          message,
          style: new TextStyle(
            color: Colors.white,
          ),
        ),
        duration: duration,
      ),
    );
  }
}
