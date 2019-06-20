part of flutter_bluetooth_serial;

class BluetoothDevice {
  final String name;
  final String address;
  final BluetoothDeviceType type;
  //final BluetoothClass bluetoothClass // @TODO . !BluetoothClass! 
  final bool connected;
  final BluetoothBondState bondState;
  
  bool get bonded => bondState.isBonded;

  const BluetoothDevice({
    this.name, 
    this.address, 
    this.type       = BluetoothDeviceType.unknown, 
    this.connected  = false, 
    this.bondState  = BluetoothBondState.unknown,
  });

  factory BluetoothDevice.fromMap(Map map) {
    return BluetoothDevice(
      name:       map['name'],
      address:    map['address'],
      type:       map['type'] != null ? BluetoothDeviceType.fromUnderlyingValue(map['type']) : BluetoothDeviceType.unknown,
      connected:  map['connected'] ?? false,
      bondState:  map['bond'] != null ? BluetoothBondState.fromUnderlyingValue(map['bond']) : BluetoothBondState.unknown,
    );
  }

  Map<String, dynamic> toMap() => {
    'name':       this.name,
    'address':    this.address,
    'type':       this.type.toUnderlyingValue(),
    'connected':  this.connected,
    'bond':       this.bondState.toUnderlyingValue(),
  };

  operator ==(Object other) {
    return other is BluetoothDevice && other.address == this.address;
  }

  @override
  int get hashCode => address.hashCode;
}
