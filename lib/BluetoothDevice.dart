part of flutter_bluetooth_serial;

/// Represents information about the device. Could be out-of-date. // @TODO . add updating the info via some fn
class BluetoothDevice {
  /// Broadcasted friendly name of the device.
  final String? name;

  /// MAC address of the device or identificator for platform system (if MAC addresses are prohibited).
  final String address;

  /// Type of the device (Bluetooth standard type).
  final BluetoothDeviceType type;

  /// Class of the device.
  //final category category // @TODO . !category!

  /// Describes is device connected.
  final bool isConnected;

  /// Bonding state of the device.
  final BluetoothBondState bondState;

  /// Broadcasted friendly clas of the device.
  final BluetoothDeviceClass deviceClass;

  /// Tells whether the device is bonded (ready to secure connect).
  @Deprecated('Use `isBonded` instead')
  bool get bonded => bondState.isBonded;

  /// Tells whether the device is bonded (ready to secure connect).
  bool get isBonded => bondState.isBonded;

  /// Construct `BluetoothDevice` with given values.
  const BluetoothDevice({
    this.name,
    required this.address,
    this.type = BluetoothDeviceType.unknown,
    this.isConnected = false,
    this.bondState = BluetoothBondState.unknown,
    this.deviceClass = BluetoothDeviceClass.UNCATEGORIZED,
  });

  /// Creates `BluetoothDevice` from map.
  ///
  /// Internally used to receive the object from platform code.
  factory BluetoothDevice.fromMap(Map map) {
    return BluetoothDevice(
        name: map["name"],
        address: map["address"]!,
        type: map["type"] != null
            ? BluetoothDeviceType.fromUnderlyingValue(map["type"])
            : BluetoothDeviceType.unknown,
        isConnected: map["isConnected"] ?? false,
        bondState: map["bondState"] != null
            ? BluetoothBondState.fromUnderlyingValue(map["bondState"])
            : BluetoothBondState.unknown,
        deviceClass: map["deviceClass"] != null
            ? (map['deviceClass'] as int).getBluetoothDeviceClassFromValue
            : BluetoothDeviceClass.UNCATEGORIZED);
  }

  /// Creates map from `BluetoothDevice`.
  Map<String, dynamic> toMap() => {
        "name": this.name,
        "address": this.address,
        "type": this.type.toUnderlyingValue(),
        "isConnected": this.isConnected,
        "bondState": this.bondState.toUnderlyingValue(),
        'deviceClass': this.deviceClass.value,
      };

  /// Compares for equality of this and other `BluetoothDevice`.
  ///
  /// In fact, only `address` is compared, since this is most important
  /// and unchangable information that identifies each device.
  operator ==(Object other) {
    return other is BluetoothDevice && other.address == this.address;
  }

  @override
  int get hashCode => address.hashCode;
}
