part of flutter_bluetooth_serial;

/// Enum-like class for all types of pairing variants.
class PairingVariant {
  final int underlyingValue;

  const PairingVariant._(this.underlyingValue);

  factory PairingVariant.fromUnderlyingValue(int value) {
    switch (value) {
      case 0:
        return PairingVariant.Pin;
      case 1:
        return PairingVariant.Passkey;
      case 2:
        return PairingVariant.PasskeyConfirmation;
      case 3:
        return PairingVariant.Consent;
      case 4:
        return PairingVariant.DisplayPasskey;
      case 5:
        return PairingVariant.DisplayPin;
      case 6:
        return PairingVariant.OOB;
      case 7:
        return PairingVariant.Pin16Digits;
      default:
        return PairingVariant.Error;
    }
  }
  int toUnderlyingValue() => underlyingValue;

  String toString() {
    switch (underlyingValue) {
      case 0:
        return 'PairingVariant.Pin';
      case 1:
        return 'PairingVariant.Passkey';
      case 2:
        return 'PairingVariant.PasskeyConfirmation';
      case 3:
        return 'PairingVariant.Consent';
      case 4:
        return 'PairingVariant.DisplayPasskey';
      case 5:
        return 'PairingVariant.DisplayPin';
      case 6:
        return 'PairingVariant.OOB';
      case 7:
        return 'PairingVariant.Pin16Digits';
      default:
        return 'PairingVariant.Error';
    }
  }

  static const Error = PairingVariant._(-1);
  static const Pin = PairingVariant._(0);
  static const Passkey = PairingVariant._(1);
  static const PasskeyConfirmation = PairingVariant._(2);
  static const Consent = PairingVariant._(3);
  static const DisplayPasskey = PairingVariant._(4);
  static const DisplayPin = PairingVariant._(5);
  static const OOB = PairingVariant._(6);
  static const Pin16Digits = PairingVariant._(7);

  // operator ==(Object other) {
  //   return other is PairingVariant && other.underlyingValue == this.underlyingValue;
  // }

  // @override
  // int get hashCode => underlyingValue.hashCode;
}

/// Represents information about incoming pairing request
class BluetoothPairingRequest {
  /// MAC address of the device or identificator for platform system (if MAC addresses are prohibited).
  final String address;

  /// Variant of the pairing methods.
  final PairingVariant pairingVariant;

  /// Passkey for confirmation.
  final int passkey;

  /// Construct `BluetoothPairingRequest` with given values.
  const BluetoothPairingRequest({
    this.address,
    this.pairingVariant,
    this.passkey,
  });

  /// Creates `BluetoothPairingRequest` from map.
  /// Internally used to receive the object from platform code.
  factory BluetoothPairingRequest.fromMap(Map map) {
    return BluetoothPairingRequest(
      address: map['address'],
      pairingVariant: PairingVariant.fromUnderlyingValue(map['variant']),
      passkey: map['passkey'],
    );
  }
}
