# What is the `address` parameter?

The address parameter in the Flutter Bluetooth Serial package is used to specify the Bluetooth MAC address of the remote device you want to connect to.
Here is an example usage of the BluetoothConnection.toAddress method which takes the address parameter:

```dart
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

// Create a Bluetooth connection to a remote device
BluetoothConnection connection = await BluetoothConnection.toAddress('00:00:00:00:00:00');

// Use the connection for data transfer
connection.output.add(utf8.encode('Hello, world!'));

// Close the connection when done
connection.finish();
```

In this example, the `BluetoothConnection.toAddress` method is used to create a connection to the remote device with the Bluetooth MAC address `00:00:00:00:00:00`. Once the connection is established, data can be sent to the remote device using the output stream of the connection object. Finally, the `finish` method is called to close the connection when done.

Note that you should replace the MAC address in the example code with the actual MAC address of the remote device you want to connect to.

# Searching for devices

To search for Bluetooth devices using the Flutter Bluetooth Serial package, you can use the `FlutterBluetoothSerial.instance.startDiscovery()` method, which starts a scan for nearby Bluetooth devices.

Here's an example code that demonstrates how to search for the HC-05 module and get a list of all discovered devices:

```dart
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

// Start scanning for nearby Bluetooth devices
FlutterBluetoothSerial.instance.startDiscovery().listen((device) {
  // Check if the device is an HC-05 module
  if (device.name == 'HC-05') {
    print('Found HC-05 module with address ${device.address}');
  }
});

// Get a list of all paired devices
List<BluetoothDevice> devices = await FlutterBluetoothSerial.instance.getBondedDevices();
for (BluetoothDevice device in devices) {
  // Check if the device is an HC-05 module
  if (device.name == 'HC-05') {
    print('Found paired HC-05 module with address ${device.address}');
  }
}
```
In this example, the `startDiscovery()` method is called to start scanning for nearby Bluetooth devices. The method returns a stream of `BluetoothDevice` objects, which can be filtered to find the HC-05 module by checking the device name using the `device.name` property.

Alternatively, you can also use the `getBondedDevices()` method to get a list of all paired Bluetooth devices, and filter the list to find the HC-05 module by checking the device name using the device.name property.

Note that in order to use the `startDiscovery()` method, you will need to request the `ACCESS_COARSE_LOCATION` or `ACCESS_FINE_LOCATION` permission from the user, as Bluetooth scanning requires location permissions on Android.
