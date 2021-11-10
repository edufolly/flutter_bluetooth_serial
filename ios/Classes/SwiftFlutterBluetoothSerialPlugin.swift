import Flutter
import UIKit
import CoreBluetooth

public class SwiftFlutterBluetoothSerialPlugin: NSObject, FlutterPlugin, CBCentralManagerDelegate {
  var centralManager: CBCentralManager!
  var initialized: Bool = false

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_bluetooth_serial/methods", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterBluetoothSerialPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    print("FlutterBluetoothSerial: handle called: ", call.method)
    if (!initialized) {
      centralManager = CBCentralManager(delegate: self, queue: nil)
      initialized = true
    }

    result("iOS " + UIDevice.current.systemVersion)

  }

  public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
            case .poweredOn:
                NSLog("poweredOn")
                //startScan()
            case .poweredOff:
                // Alert user to turn on Bluetooth
                NSLog("poweredOff")
            case .resetting:
                // Wait for next state update and consider logging interruption of Bluetooth service
                NSLog("resetting")
            case .unauthorized:
                // Alert user to enable Bluetooth permission in app Settings
                NSLog("unauthorized")
            case .unsupported:
                // Alert user their device does not support Bluetooth and app will not work as expected
                NSLog("unsupported")
            case .unknown:
               // Wait for next state update
                NSLog("unknown")
        }
    }
}
