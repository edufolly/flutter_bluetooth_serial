part of flutter_bluetooth_serial;

enum BluetoothDeviceClass {
  // Audio and Video Devices
  AUDIO_VIDEO_CAMCORDER(1076),
  AUDIO_VIDEO_CAR_AUDIO(1056),
  AUDIO_VIDEO_HANDSFREE(1032),
  AUDIO_VIDEO_HEADPHONES(1048),
  AUDIO_VIDEO_HIFI_AUDIO(1064),
  AUDIO_VIDEO_LOUDSPEAKER(1044),
  AUDIO_VIDEO_MICROPHONE(1040),
  AUDIO_VIDEO_PORTABLE_AUDIO(1052),
  AUDIO_VIDEO_SET_TOP_BOX(1060),
  AUDIO_VIDEO_UNCATEGORIZED(1024),
  AUDIO_VIDEO_VCR(1068),
  AUDIO_VIDEO_VIDEO_CAMERA(1072),
  AUDIO_VIDEO_VIDEO_CONFERENCING(1088),
  AUDIO_VIDEO_VIDEO_DISPLAY_AND_LOUDSPEAKER(1084),
  AUDIO_VIDEO_VIDEO_GAMING_TOY(1096),
  AUDIO_VIDEO_VIDEO_MONITOR(1080),
  AUDIO_VIDEO_WEARABLE_HEADSET(1028),

  // Computer Devices
  COMPUTER_DESKTOP(260),
  COMPUTER_HANDHELD_PC_PDA(272),
  COMPUTER_LAPTOP(268),
  COMPUTER_PALM_SIZE_PC_PDA(276),
  COMPUTER_SERVER(264),
  COMPUTER_UNCATEGORIZED(256),
  COMPUTER_WEARABLE(280),

  // Health Devices
  HEALTH_BLOOD_PRESSURE(2308),
  HEALTH_DATA_DISPLAY(2332),
  HEALTH_GLUCOSE(2320),
  HEALTH_PULSE_OXIMETER(2324),
  HEALTH_PULSE_RATE(2328),
  HEALTH_THERMOMETER(2312),
  HEALTH_UNCATEGORIZED(2304),
  HEALTH_WEIGHING(2316),

  // Peripheral Devices
  PERIPHERAL_KEYBOARD(1344),
  PERIPHERAL_KEYBOARD_POINTING(1472),
  PERIPHERAL_NON_KEYBOARD_NON_POINTING(1280),
  PERIPHERAL_POINTING(1408),

  // Phone Devices
  PHONE_CELLULAR(516),
  PHONE_CORDLESS(520),
  PHONE_ISDN(532),
  PHONE_MODEM_OR_GATEWAY(528),
  PHONE_SMART(524),
  PHONE_UNCATEGORIZED(512),

  // Toy Devices
  TOY_CONTROLLER(2064),
  TOY_DOLL_ACTION_FIGURE(2060),
  TOY_GAME(2068),
  TOY_ROBOT(2052),
  TOY_UNCATEGORIZED(2048),
  TOY_VEHICLE(2056),

  // Wearable Devices
  WEARABLE_GLASSES(1812),
  WEARABLE_HELMET(1808),
  WEARABLE_JACKET(1804),
  WEARABLE_PAGER(1800),
  WEARABLE_UNCATEGORIZED(1792),
  WEARABLE_WRIST_WATCH(1796),

  // Major Class Devices
  IMAGING(1536),
  MISC(0),
  UNCATEGORIZED(7936),
  NETWORKING(768);

  const BluetoothDeviceClass(this.value);

  final int value;
}

extension BluetoothDeviceClassEnum on int {
  BluetoothDeviceClass get getBluetoothDeviceClassFromValue {
    for (BluetoothDeviceClass enumValue in BluetoothDeviceClass.values) {
      if (enumValue.value == this) {
        return enumValue;
      }
    }
    // Handle the case where the integer value doesn't match any enum value.
    // Default value or handle as needed.
    return BluetoothDeviceClass.UNCATEGORIZED;
  }
}

extension BluetoothDeviceClassName on BluetoothDeviceClass {
  // Get readable name of the bluetooth class
  String get name => this.toString().replaceAll('BluetoothDeviceClass.', '');
}
