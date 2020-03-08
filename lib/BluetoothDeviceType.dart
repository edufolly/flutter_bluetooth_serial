part of flutter_bluetooth_serial;

class BluetoothDeviceType {
  final int underlyingValue;
  final String stringValue;

  const BluetoothDeviceType.fromString(String string)
      : this.underlyingValue = (string == 'unknown'
                ? 0
                : string == 'classic'
                    ? 1
                    : string == 'le'
                        ? 2
                        : string == 'dual'
                            ? 3
                            : -2 // Unknown, if not found valid
            ),
        this.stringValue = ((string == 'unknown' ||
                    string == 'classic' ||
                    string == 'le' ||
                    string == 'dual' //
                )
                ? string
                : 'unknown' // Unknown, if not found valid
            );

  const BluetoothDeviceType.fromUnderlyingValue(int value)
      : this.underlyingValue = ((value >= 0 && value <= 3)
                ? value
                : 0 // Unknown, if not found valid
            ),
        this.stringValue = (value == 0
                ? 'unknown'
                : value == 1
                    ? 'classic'
                    : value == 2
                        ? 'le'
                        : value == 3
                            ? 'dual'
                            : 'unknown' // Unknown, if not found valid
            );

  String toString() => 'BluetoothDeviceType.$stringValue';

  int toUnderlyingValue() => underlyingValue;

  static const unknown = BluetoothDeviceType.fromUnderlyingValue(0);
  static const classic = BluetoothDeviceType.fromUnderlyingValue(1);
  static const le = BluetoothDeviceType.fromUnderlyingValue(2);
  static const dual = BluetoothDeviceType.fromUnderlyingValue(3);

  operator ==(Object other) {
    return other is BluetoothDeviceType &&
        other.underlyingValue == this.underlyingValue;
  }

  @override
  int get hashCode => underlyingValue.hashCode;
}
