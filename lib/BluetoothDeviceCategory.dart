part of flutter_bluetooth_serial;

enum BluetoothDeviceCategory {
  MISC,
  COMPUTER,
  PHONE,
  NETWORKING,
  AUDIO_VIDEO,
  PERIPHERAL,
  IMAGING,
  WEARABLE,
  TOY,
  HEALTH,
  UNCATEGORIZED,
  UNKNOWN,
  PERIPHERAL_KEYBOARD,
  PERIPHERAL_POINTING,
  PERIPHERAL_KEYBOARD_POINTING,
  PERIPHERAL_NON_KEYBOARD_NON_POINTING,
}

BluetoothDeviceCategory mapStringToDeviceCategory(String deviceCategoryString) {
  switch (deviceCategoryString) {
    case "MISC":
      return BluetoothDeviceCategory.MISC;
    case "COMPUTER":
      return BluetoothDeviceCategory.COMPUTER;
    case "PHONE":
      return BluetoothDeviceCategory.PHONE;
    case "NETWORKING":
      return BluetoothDeviceCategory.NETWORKING;
    case "AUDIO_VIDEO":
      return BluetoothDeviceCategory.AUDIO_VIDEO;
    case "PERIPHERAL":
      return BluetoothDeviceCategory.PERIPHERAL;
    case "IMAGING":
      return BluetoothDeviceCategory.IMAGING;
    case "WEARABLE":
      return BluetoothDeviceCategory.WEARABLE;
    case "TOY":
      return BluetoothDeviceCategory.TOY;
    case "HEALTH":
      return BluetoothDeviceCategory.HEALTH;
    case "UNCATEGORIZED":
      return BluetoothDeviceCategory.UNCATEGORIZED;
    case "PERIPHERAL_KEYBOARD":
      return BluetoothDeviceCategory.PERIPHERAL_KEYBOARD;
    case "PERIPHERAL_POINTING":
      return BluetoothDeviceCategory.PERIPHERAL_POINTING;
    case "PERIPHERAL_KEYBOARD_POINTING":
      return BluetoothDeviceCategory.PERIPHERAL_KEYBOARD_POINTING;
    case "PERIPHERAL_NON_KEYBOARD_NON_POINTING":
      return BluetoothDeviceCategory.PERIPHERAL_NON_KEYBOARD_NON_POINTING;
    default:
      return BluetoothDeviceCategory.UNKNOWN;
  }
}

String mapDeviceCategoryToString(BluetoothDeviceCategory category) {
  switch (category) {
    case BluetoothDeviceCategory.MISC:
      return "MISC";
    case BluetoothDeviceCategory.COMPUTER:
      return "COMPUTER";
    case BluetoothDeviceCategory.PHONE:
      return "PHONE";
    case BluetoothDeviceCategory.NETWORKING:
      return "NETWORKING";
    case BluetoothDeviceCategory.AUDIO_VIDEO:
      return "AUDIO_VIDEO";
    case BluetoothDeviceCategory.PERIPHERAL:
      return "PERIPHERAL";
    case BluetoothDeviceCategory.IMAGING:
      return "IMAGING";
    case BluetoothDeviceCategory.WEARABLE:
      return "WEARABLE";
    case BluetoothDeviceCategory.TOY:
      return "TOY";
    case BluetoothDeviceCategory.HEALTH:
      return "HEALTH";
    case BluetoothDeviceCategory.UNCATEGORIZED:
      return "UNCATEGORIZED";
    case BluetoothDeviceCategory.PERIPHERAL_KEYBOARD:
      return "PERIPHERAL_KEYBOARD";
    case BluetoothDeviceCategory.PERIPHERAL_POINTING:
      return "PERIPHERAL_POINTING";
    case BluetoothDeviceCategory.PERIPHERAL_KEYBOARD_POINTING:
      return "PERIPHERAL_KEYBOARD_POINTING";
    case BluetoothDeviceCategory.PERIPHERAL_NON_KEYBOARD_NON_POINTING:
      return "PERIPHERAL_NON_KEYBOARD_NON_POINTING";
    default:
      return "UNKNOWN";
  }
}

extension BuildContextExtension on BluetoothDeviceCategory {
  String get toStringValue => mapDeviceCategoryToString(this);
}
