import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_bluetooth_serial_example/Pages/terms_conditions.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:custom_switch/custom_switch.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_bluetooth_serial_example/DiscoveryPage.dart';
import 'package:flutter_bluetooth_serial_example/SelectBondedDevicePage.dart';
import '../antrenman/antrenman_page.dart';
import 'package:flutter_bluetooth_serial_example/BackgroundCollectingTask.dart';
import 'package:flutter_bluetooth_serial_example/BackgroundCollectedPage.dart';

import '../picker_page.dart';
import './bluetoothPage_controller.dart';

final controller = Get.put(StateController1());
BluetoothDevice selectedDevice;

class BluetoothPage extends StatefulWidget {
  @override
  _BluetoothPage createState() => new _BluetoothPage();
}

//class BluetoothPage extends StatelessWidget {

class _BluetoothPage extends State<BluetoothPage> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  String _address = "...";
  String _name = "...";
  Timer _discoverableTimeoutTimer;
  int _discoverableTimeoutSecondsLeft = 0;

  BackgroundCollectingTask _collectingTask;

  bool _autoAcceptPairingRequests = false;

  @override
  void initState() {
    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
      controller.isSwitched.value = state.isEnabled;
    });

    Future.doWhile(() async {
      // Wait if adapter not enabled
      if (await FlutterBluetoothSerial.instance.isEnabled) {
        return false;
      }
      await Future.delayed(Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
      // Update the address field
      FlutterBluetoothSerial.instance.address.then((address) {
        setState(() {
          _address = address;
        });
      });
    });

    FlutterBluetoothSerial.instance.name.then((name) {
      setState(() {
        _name = name;
      });
    });

    // Listen for futher state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
        controller.isSwitched.value = state.isEnabled;

        // Discoverable mode is disabled when Bluetooth gets disabled
        _discoverableTimeoutTimer = null;
        _discoverableTimeoutSecondsLeft = 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: <Widget>[
        Center(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/BackCover.jpg'), fit: BoxFit.cover),
              //shape: BoxShape.rectangle,
            ),
          ),
        ),
        Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Padding(
                    padding: EdgeInsets.only(top: Get.height / 13),
                    child: Text(
                      "BLUETOOTH",
                      style: TextStyle(
                          color: Colors.white70, fontSize: Get.height / 23),
                    )),
              ),
              //Switch
              Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () async {
                      if (!controller.isSwitched.value) {
                        await FlutterBluetoothSerial.instance.requestEnable();
                      } else
                        await FlutterBluetoothSerial.instance.requestDisable();
                    },
                    child: Image.asset(
                        controller.isSwitched.value
                            ? 'assets/PNG/BLUETOOTH/on_buton.png'
                            : 'assets/PNG/BLUETOOTH/off_buton.png',
                        height: Get.height / 7),
                  )),

              //Kutular
              Expanded(
                flex: 5,
                child: Opacity(
                  opacity: controller.isSwitched.value ? 1 : 0,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        //1. kutu
                        GestureDetector(
                          onTap: () {
                            controller.kutuActivatedFlag[0].value =
                                !controller.kutuActivatedFlag[0].value;
                            print("siyah1");
                            print(controller.read("siyah1").then((s) async {
                              print(s);
                              if (s == "0") {
                                print(controller.read("siyah1").toString());
                                selectedDevice =
                                    await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return DiscoveryPage();
                                    },
                                  ),
                                );

                                if (selectedDevice != null) {
                                  print('Discovery -> selected ' +
                                      selectedDevice.address);
                                  controller.kutuActivatedFlag[0].value = true;
                                  controller.save(
                                      "siyah1", selectedDevice.address);
                                } else {
                                  print('Discovery -> no device selected');
                                }
                              }
                            }));
                          },
                          onDoubleTap: () async {
                            selectedDevice = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return DiscoveryPage();
                                },
                              ),
                            );

                            if (selectedDevice != null) {
                              print('Discovery -> selected ' +
                                  selectedDevice.address);
                              controller.kutuActivatedFlag[0].value = true;
                              controller.save("siyah1", selectedDevice.address);
                            } else {
                              print('Discovery -> no device selected');
                            }
                          },
                          child: Opacity(
                            opacity: controller.kutuActivatedFlag[0].value
                                ? 1
                                : 0.25,
                            child: Image.asset(
                              'assets/PNG/AntrenmanEkraniAktif/siyah_kutu.png',
                              height: Get.height / 3.1,
                            ),
                          ),
                        ),

                        // ikinci kutu

                        GestureDetector(
                          onTap: () {
                            controller.kutuActivatedFlag[1].value =
                                !controller.kutuActivatedFlag[1].value;
                            print("kirmizi2");
                            print(controller.read("kirmizi2").then((s) async {
                              print(s);
                              if (s == "0") {
                                print(controller.read("kirmizi2").toString());
                                selectedDevice =
                                    await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return DiscoveryPage();
                                    },
                                  ),
                                );

                                if (selectedDevice != null) {
                                  print('Discovery -> selected ' +
                                      selectedDevice.address);
                                  controller.kutuActivatedFlag[0].value = true;
                                  controller.save(
                                      "kirmizi2", selectedDevice.address);
                                } else {
                                  print('Discovery -> no device selected');
                                }
                              }
                            }));
                          },
                          onDoubleTap: () async {
                            selectedDevice = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return DiscoveryPage();
                                },
                              ),
                            );

                            if (selectedDevice != null) {
                              print('Discovery -> selected ' +
                                  selectedDevice.address);
                              controller.kutuActivatedFlag[1].value = true;
                              controller.save(
                                  "kirmizi2", selectedDevice.address);
                            } else {
                              print('Discovery -> no device selected');
                            }
                          },
                          child: Opacity(
                            opacity: controller.kutuActivatedFlag[1].value
                                ? 1
                                : 0.25,
                            child: Image.asset(
                              'assets/PNG/AntrenmanEkraniAktif/kirmizi.png',
                              height: Get.height / 3.1,
                            ),
                          ),
                        ),

                        // 3. kutu

                        GestureDetector(
                          onTap: () {
                            controller.kutuActivatedFlag[2].value =
                                !controller.kutuActivatedFlag[2].value;
                            print("yesil3");
                            print(controller.read("yesil3").then((s) async {
                              print(s);
                              if (s == "0") {
                                print(controller.read("yesil3").toString());
                                selectedDevice =
                                    await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return DiscoveryPage();
                                    },
                                  ),
                                );

                                if (selectedDevice != null) {
                                  print('Discovery -> selected ' +
                                      selectedDevice.address);
                                  controller.kutuActivatedFlag[2].value = true;
                                  controller.save(
                                      "yesil3", selectedDevice.address);
                                } else {
                                  print('Discovery -> no device selected');
                                }
                              }
                            }));
                          },
                          onDoubleTap: () async {
                            selectedDevice = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return DiscoveryPage();
                                },
                              ),
                            );

                            if (selectedDevice != null) {
                              print('Discovery -> selected ' +
                                  selectedDevice.address);
                              controller.kutuActivatedFlag[2].value = true;
                              controller.save("yesil3", selectedDevice.address);
                            } else {
                              print('Discovery -> no device selected');
                            }
                          },
                          child: Opacity(
                            opacity: controller.kutuActivatedFlag[2].value
                                ? 1
                                : 0.25,
                            child: Image.asset(
                              'assets/PNG/AntrenmanEkraniAktif/yesil_kutu.png',
                              height: Get.height / 3.1,
                            ),
                          ),
                        ),

                        //4. kutu

                        GestureDetector(
                          onTap: () {
                            controller.kutuActivatedFlag[3].value =
                                !controller.kutuActivatedFlag[3].value;
                            print("mavi4");
                            print(controller.read("mavi4").then((s) async {
                              print(s);
                              if (s == "0") {
                                print(controller.read("mavi4").toString());
                                selectedDevice =
                                    await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return DiscoveryPage();
                                    },
                                  ),
                                );

                                if (selectedDevice != null) {
                                  print('Discovery -> selected ' +
                                      selectedDevice.address);
                                  controller.kutuActivatedFlag[3].value = true;
                                  controller.save(
                                      "mavi4", selectedDevice.address);
                                } else {
                                  print('Discovery -> no device selected');
                                }
                              }
                            }));
                          },
                          onDoubleTap: () async {
                            selectedDevice = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return DiscoveryPage();
                                },
                              ),
                            );

                            if (selectedDevice != null) {
                              print('Discovery -> selected ' +
                                  selectedDevice.address);
                              controller.kutuActivatedFlag[3].value = true;
                              controller.save("mavi4", selectedDevice.address);
                            } else {
                              print('Discovery -> no device selected');
                            }
                          },
                          child: Opacity(
                            opacity: controller.kutuActivatedFlag[3].value
                                ? 1
                                : 0.25,
                            child: Image.asset(
                              'assets/PNG/AntrenmanEkraniAktif/mavi_kutu.png',
                              height: Get.height / 3.1,
                            ),
                          ),
                        ),
                      ]),
                ),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,

                  //TODO cross button on the left bottom corner
                  children: [
                    //Baslat Button
                    GestureDetector(
                        onTap: () => {
                              controller.startChat(
                                  context, controller.kutuActivatedFlag),
                              // if (selectedDevice != null)
                              //   {
                              //     print('Connect -> selected ' +
                              //         selectedDevice.address),

                              //     controller.startChat(context, selectedDevice)

                              //     //_startChat(context, selectedDevice);
                              //   }
                              // else
                              //   {print('Connect -> no device selected')}
                            },
                        child: Opacity(
                          opacity: (controller.isSwitched.value) &&
                                  (controller.kutuActivatedFlag[0].value ||
                                      controller.kutuActivatedFlag[1].value ||
                                      controller.kutuActivatedFlag[2].value ||
                                      controller.kutuActivatedFlag[3].value)
                              ? 1
                              : 0,
                          child: Image.asset(
                            'assets/PNG/BLUETOOTH/basla_buton.png',
                            height: Get.height / 6,
                          ),
                        )),
                    //Cross button
                    // Align(
                    //   alignment: Alignment.bottomLeft,
                    //   child: GestureDetector(
                    //     child: Image.asset(
                    //       'assets/PNG/AntrenmanEkraniAktif/cikis.png',
                    //       height: Get.height / 10,
                    //     ),
                    //   ),
                    // )
                  ],
                ),
              )
            ],
          ),
        ),
      ]),
    );
  }
}
