import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothDeviceListEntry extends ListTile {
  BluetoothDeviceListEntry({
    required BluetoothDevice device,
    int? rssi,
    GestureTapCallback? onTap,
    GestureLongPressCallback? onLongPress,
    bool enabled = true,
  }) : super(
    onTap: onTap,
    onLongPress: onLongPress,
    enabled: enabled,
    leading:
    Icon(_getDeviceIcon(device.deviceClass)),
    title: Text(device.name ?? ""),
    subtitle: Text(device.address.toString() + " | class: " + device.deviceClass.toString()),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        rssi != null
            ? Container(
          margin: new EdgeInsets.all(8.0),
          child: DefaultTextStyle(
            style: _computeTextStyle(rssi),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(rssi.toString()),
                Text('dBm'),
              ],
            ),
          ),
        )
            : Container(width: 0, height: 0),
        device.isConnected
            ? Icon(Icons.import_export)
            : Container(width: 0, height: 0),
        device.isBonded
            ? Icon(Icons.link)
            : Container(width: 0, height: 0),

      ],
    ),
  );

  static TextStyle _computeTextStyle(int rssi) {
    /**/ if (rssi >= -35)
      return TextStyle(color: Colors.greenAccent[700]);
    else if (rssi >= -45)
      return TextStyle(
          color: Color.lerp(
              Colors.greenAccent[700], Colors.lightGreen, -(rssi + 35) / 10));
    else if (rssi >= -55)
      return TextStyle(
          color: Color.lerp(
              Colors.lightGreen, Colors.lime[600], -(rssi + 45) / 10));
    else if (rssi >= -65)
      return TextStyle(
          color: Color.lerp(Colors.lime[600], Colors.amber, -(rssi + 55) / 10));
    else if (rssi >= -75)
      return TextStyle(
          color: Color.lerp(
              Colors.amber, Colors.deepOrangeAccent, -(rssi + 65) / 10));
    else if (rssi >= -85)
      return TextStyle(
          color: Color.lerp(
              Colors.deepOrangeAccent, Colors.redAccent, -(rssi + 75) / 10));
    else
      /*code symmetry*/
      return TextStyle(color: Colors.redAccent);
  }

  // https://developer.android.com/reference/android/bluetooth/BluetoothClass.Device
  static IconData _getDeviceIcon(int deviceClass) {
    if (deviceClass > 500 && deviceClass < 550) {
      // phone
      return Icons.phone_android;
    }
    else if (deviceClass > 1000 && deviceClass < 1100) {
      // audio video devices
      return Icons.headphones;
    }
    else if (deviceClass > 250 && deviceClass < 300) {
      // computer and accessories
      return Icons.computer;
    }
    else if (deviceClass > 2300 && deviceClass < 2400) {
      // health
      return Icons.health_and_safety;
    }
    else if (deviceClass > 2000 && deviceClass < 2100) {
      // toy
      return Icons.smart_toy;
    }
    else if (deviceClass == 1796) {
      // wearable wrist watch
      return Icons.watch;
    }
    else if (deviceClass == 1812) {
      // wearable glass
      return Icons.bluetooth;
    }
    else {
      return Icons.bluetooth;
    }
  }
}
