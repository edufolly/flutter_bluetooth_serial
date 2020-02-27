part of flutter_bluetooth_serial;

class BluetoothState {
  final int underlyingValue;
  final String stringValue;

  const BluetoothState.fromString(String string)
      : this.underlyingValue = (string == 'STATE_OFF'
                ? 10
                : string == 'STATE_TURNING_ON'
                    ? 11
                    : string == 'STATE_ON'
                        ? 12
                        : string == 'STATE_TURNING_OFF'
                            ? 13
                            :

                            //ring == 'STATE_BLE_OFF'         ? 10 :
                            string == 'STATE_BLE_TURNING_ON'
                                ? 14
                                : string == 'STATE_BLE_ON'
                                    ? 15
                                    : string == 'STATE_BLE_TURNING_OFF'
                                        ? 16
                                        : string == 'ERROR'
                                            ? -1
                                            : -2 // Unknown, if not found valid
            ),
        this.stringValue = ((string == 'STATE_OFF' ||
                    string == 'STATE_TURNING_ON' ||
                    string == 'STATE_ON' ||
                    string == 'STATE_TURNING_OFF' ||

                    //ring == 'STATE_BLE_OFF'         ||
                    string == 'STATE_BLE_TURNING_ON' ||
                    string == 'STATE_BLE_ON' ||
                    string == 'STATE_BLE_TURNING_OFF' ||
                    string == 'ERROR')
                ? string
                : 'UNKNOWN' // Unknown, if not found valid
            );

  const BluetoothState.fromUnderlyingValue(int value)
      : this.underlyingValue = (((value >= 10 && value <= 16) || value == -1)
                ? value
                : -2 // Unknown, if not found valid
            ),
        this.stringValue = (value == 10
                ? 'STATE_OFF'
                : value == 11
                    ? 'STATE_TURNING_ON'
                    : value == 12
                        ? 'STATE_ON'
                        : value == 13
                            ? 'STATE_TURNING_OFF'
                            :

                            //lue == 10 ? 'STATE_BLE_OFF'         : // Just for symetry in code :F
                            value == 14
                                ? 'STATE_BLE_TURNING_ON'
                                : value == 15
                                    ? 'STATE_BLE_ON'
                                    : value == 16
                                        ? 'STATE_BLE_TURNING_OFF'
                                        : value == -1
                                            ? 'ERROR'
                                            : 'UNKNOWN' // Unknown, if not found valid
            );

  String toString() => 'BluetoothState.$stringValue';

  int toUnderlyingValue() => underlyingValue;

  static const STATE_OFF = BluetoothState.fromUnderlyingValue(10);
  static const STATE_TURNING_ON = BluetoothState.fromUnderlyingValue(11);
  static const STATE_ON = BluetoothState.fromUnderlyingValue(12);
  static const STATE_TURNING_OFF = BluetoothState.fromUnderlyingValue(13);

  //atic const STATE_BLE_OFF = BluetoothState.STATE_OFF; // Just for symetry in code :F
  static const STATE_BLE_TURNING_ON = BluetoothState.fromUnderlyingValue(14);
  static const STATE_BLE_ON = BluetoothState.fromUnderlyingValue(15);
  static const STATE_BLE_TURNING_OFF = BluetoothState.fromUnderlyingValue(16);

  static const ERROR = BluetoothState.fromUnderlyingValue(-1);
  static const UNKNOWN = BluetoothState.fromUnderlyingValue(-2);

  operator ==(Object other) {
    return other is BluetoothState &&
        other.underlyingValue == this.underlyingValue;
  }

  @override
  int get hashCode => underlyingValue.hashCode;

  bool get isEnabled => this == STATE_ON;
}
