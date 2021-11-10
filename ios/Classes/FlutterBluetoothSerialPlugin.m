#import "FlutterBluetoothSerialPlugin.h"
#if __has_include(<flutter_bluetooth_serial/flutter_bluetooth_serial-Swift.h>)
#import <flutter_bluetooth_serial/flutter_bluetooth_serial-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_bluetooth_serial-Swift.h"
#endif

@implementation FlutterBluetoothSerialPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterBluetoothSerialPlugin registerWithRegistrar:registrar];
}
@end
