part of flutter_bluetooth_serial;

class BluetoothDiscoveryResult {
  final BluetoothDevice device;
  final int rssi;

  BluetoothDiscoveryResult({
    this.device,
    this.rssi = 0,
  });

  factory BluetoothDiscoveryResult.fromMap(Map map) {
    return BluetoothDiscoveryResult(
      device: BluetoothDevice.fromMap(map),
      rssi: map['rssi'] ?? 0,
    );
  }
}
