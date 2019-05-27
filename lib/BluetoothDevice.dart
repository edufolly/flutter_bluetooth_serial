part of flutter_bluetooth_serial;

class BluetoothDevice {
  final String name;
  final String address;
  final BluetoothDeviceType type;
  //final BluetoothClass bluetoothClass // @TODO . !BluetoothClass! 
  final bool connected;
  final bool bonded; // @TODO ? Maybe use enum of something like BOND_NONE, BOND_BONDING, BOND_BONDED
  
  const BluetoothDevice({
    this.name, 
    this.address, 
    this.type       = BluetoothDeviceType.unknown, 
    this.connected  = false, 
    this.bonded     = false,
  });

  factory BluetoothDevice.fromMap(Map map) {
    return BluetoothDevice(
      name:       map['name'],
      address:    map['address'],
      type:       BluetoothDeviceType.fromUnderlyingValue(map['type']) ?? BluetoothDeviceType.unknown,
      connected:  map['connected'] ?? false,
      bonded:     map['bonded'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'name':       this.name,
    'address':    this.address,
    'type':       this.type.toUnderlyingValue(),
    'connected':  this.connected,
    'bonded':     this.bonded,
  };

  operator ==(Object other) {
    return other is BluetoothDevice && other.address == this.address;
  }

  @override
  int get hashCode => address.hashCode;
}
