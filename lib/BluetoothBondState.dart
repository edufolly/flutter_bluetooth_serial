part of flutter_bluetooth_serial;

class BluetoothBondState {
  final int underlyingValue;
  final String stringValue;

  const BluetoothBondState.fromString(String string)
      : this.underlyingValue = (string == 'none'
                ? 10
                : string == 'bonding'
                    ? 11
                    : string == 'bonded'
                        ? 12
                        : -2 // Unknown, if not found valid
            ),
        this.stringValue =
            ((string == 'none' || string == 'bonding' || string == 'bonded' //
                )
                ? string
                : 'unknown' // Unknown, if not found valid
            );

  const BluetoothBondState.fromUnderlyingValue(int value)
      : this.underlyingValue = ((value >= 10 && value <= 12)
                ? value
                : 0 // Unknown, if not found valid
            ),
        this.stringValue = (value == 10
                ? 'none'
                : value == 11
                    ? 'bonding'
                    : value == 12
                        ? 'bonded'
                        : 'unknown' // Unknown, if not found valid
            );

  String toString() => 'BluetoothBondState.$stringValue';

  int toUnderlyingValue() => underlyingValue;

  static const unknown = BluetoothBondState.fromUnderlyingValue(0);
  static const none = BluetoothBondState.fromUnderlyingValue(10);
  static const bonding = BluetoothBondState.fromUnderlyingValue(11);
  static const bonded = BluetoothBondState.fromUnderlyingValue(12);

  operator ==(Object other) {
    return other is BluetoothBondState &&
        other.underlyingValue == this.underlyingValue;
  }

  @override
  int get hashCode => underlyingValue.hashCode;

  bool get isBonded => this == bonded;
}
