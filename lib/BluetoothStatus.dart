part of flutter_bluetooth_serial;

class BluetoothStatus { // @TODO , there should be BluetoothState instead - only for Adapter; Disconnect/Connected should be only for specific devices
  final int underlyingValue;
  final String stringValue;

  const BluetoothStatus.fromString(String string) : 
    this.underlyingValue = (
      string == 'UNKNOWN' ? -2 :
      string == 'ERROR'   ? -1 :

      string == 'DISCONNECTED'  ?  0 :
      string == 'CONNECTED'     ?  1 :

      string == 'STATE_OFF'         ? 10 :
      string == 'STATE_TURNING_ON'  ? 11 :
      string == 'STATE_ON'          ? 12 :
      string == 'STATE_TURNING_OFF' ? 13 :

      //ring == 'STATE_BLE_OFF'         ? 10 :
      string == 'STATE_BLE_TURNING_ON'  ? 14 :
      string == 'STATE_BLE_ON'          ? 15 :
      string == 'STATE_BLE_TURNING_OFF' ? 16 :

      -2 // Unknown, if not found valid
    ),
    this.stringValue = (
      (
        string == 'UNKNOWN' ||
        string == 'ERROR'   ||

        string == 'DISCONNECTED' ||
        string == 'CONNECTED'    ||

        string == 'STATE_OFF'         ||
        string == 'STATE_TURNING_ON'  ||
        string == 'STATE_ON'          ||
        string == 'STATE_TURNING_OFF' ||

        //ring == 'STATE_BLE_OFF'         ||
        string == 'STATE_BLE_TURNING_ON'  ||
        string == 'STATE_BLE_ON'          ||
        string == 'STATE_BLE_TURNING_OFF' //
      )
        ? string : 'UNKNOWN' // Unknown, if not found valid
    );

  const BluetoothStatus.fromUnderlyingValue(int value) :
    this.underlyingValue = (
      ((value >= -2 && value <= 1) || (value >= 10 && value <= 16))
        ? value : -2 // Unknown, if not found valid
    ),
    this.stringValue = (
      value == -2 ? 'UNKNOWN' :
      value == -1 ? 'ERROR'   :

      value ==  0 ? 'DISCONNECTED'  :
      value ==  1 ? 'CONNECTED'     :

      value == 10 ? 'STATE_OFF'         :
      value == 11 ? 'STATE_TURNING_ON'  :
      value == 12 ? 'STATE_ON'          :
      value == 13 ? 'STATE_TURNING_OFF' :

      //lue == 10 ? 'STATE_BLE_OFF'         : // Just for symetry in code :F
      value == 14 ? 'STATE_BLE_TURNING_ON'  :
      value == 15 ? 'STATE_BLE_ON'          :
      value == 16 ? 'STATE_BLE_TURNING_OFF' :
      
      'UNKNOWN' // Unknown, if not found valid
    );

  String toString() => 'BluetoothStatus.$stringValue';

  int toUnderlyingValue() => underlyingValue;

  static const UNKNOWN                = BluetoothStatus.fromUnderlyingValue(-2);
  static const ERROR                  = BluetoothStatus.fromUnderlyingValue(-1);

  static const DISCONNECTED           = BluetoothStatus.fromUnderlyingValue(0);
  static const CONNECTED              = BluetoothStatus.fromUnderlyingValue(1);

  static const STATE_OFF              = BluetoothStatus.fromUnderlyingValue(10);
  static const STATE_TURNING_ON       = BluetoothStatus.fromUnderlyingValue(11);
  static const STATE_ON               = BluetoothStatus.fromUnderlyingValue(12);
  static const STATE_TURNING_OFF      = BluetoothStatus.fromUnderlyingValue(13);

  //atic const STATE_BLE_OFF = BluetoothStatus.STATE_OFF; // Just for symetry in code :F
  static const STATE_BLE_TURNING_ON   = BluetoothStatus.fromUnderlyingValue(14);
  static const STATE_BLE_ON           = BluetoothStatus.fromUnderlyingValue(15);
  static const STATE_BLE_TURNING_OFF  = BluetoothStatus.fromUnderlyingValue(16);

  operator ==(Object other) {
    return other is BluetoothStatus && other.underlyingValue == this.underlyingValue;
  }

  @override
  int get hashCode => underlyingValue.hashCode;

  bool get isEnabled => this == STATE_ON || this == CONNECTED; // From now it is fucking obvious that Status should be broken into adapter `BluetoothState` and `BluetoothDevice.connected`; Multiple connections/devices incomming, so it will happen in few days :)
}
