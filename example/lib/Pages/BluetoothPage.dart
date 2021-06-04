import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_bluetooth_serial_example/Pages/terms_conditions.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter/cupertino.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import '../DiscoveryPage.dart';
import '../SelectBondedDevicePage.dart';
import './antrenman/antrenman_page.dart';
import '../BackgroundCollectingTask.dart';
import '../BackgroundCollectedPage.dart';

import './picker_page.dart';

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

BluetoothDevice selectedDevice;
List<_Message> messages = [];

bool switchState = false;
List kutuActivatedFlag = [false, false, false, false];
List blueToothSelectedDevice = [
  BluetoothDevice,
  BluetoothDevice,
  BluetoothDevice,
  BluetoothDevice,
];

class SwithButton extends StatefulWidget {
  @override
  _SwithButton createState() => new _SwithButton();
}

class _SwithButton extends State<SwithButton> {
  @override
  Widget build(BuildContext context) {
    return CupertinoSwitch(
        activeColor: Colors.blue,
        value: switchState,
        onChanged: (bool value) {
          setState(() {
            switchState = value;
          });
          print("object");
        });
  }
}

class BluetoothPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/BackCover.jpg'), fit: BoxFit.cover),
            //shape: BoxShape.rectangle,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Stack(
                  alignment: Alignment(0, -0.5),
                  children: <Widget>[
                    Text("BLUETOOTH", style: TextStyle(color: Colors.white)),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: SwithButton(),
                    )
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Row(children: [Kutu1(), Kutu1(), Kutu1(), Kutu1()]),
              ),
              Expanded(
                  flex: 2,
                  child: Row(
                    children: [BaslatButton()],
                  ))
            ],
          ),
          // child: Column(
          //   crossAxisAlignment: CrossAxisAlignment.center,
          //   children: [
          //     Expanded(
          //         flex: 1,
          //         child: Container(
          //           child: CupertinoSwitch(
          //               value: switchState,
          //               onChanged: (bool value) {
          //                 switchState = value;
          //                 print("object");
          //               }),
          //         )),
          //   ],
          // ),
        ),
      ),
    );
  }
}

class Kutu1 extends StatefulWidget {
  @override
  _KutuState createState() => _KutuState();
}

class _KutuState extends State<Kutu1> {
  int kutuIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
          child: ConstrainedBox(
              constraints: BoxConstraints.expand(),
              child: FlatButton(
                  onPressed: () async {
                    print("Kutu pressed!");

                    selectedDevice = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return DiscoveryPage();
                        },
                      ),
                    );

                    if (selectedDevice != null) {
                      print('Discovery -> selected ' + selectedDevice.address);
                    } else {
                      print('Discovery -> no device selected');
                    }

                    setState(() {
                      for (int v = 0; v < 4; v++) {
                        if (v != kutuIndex) {
                          kutuActivatedFlag[v] = false;
                        } else {
                          kutuActivatedFlag[v] = !kutuActivatedFlag[v];
                        }
                        print(kutuActivatedFlag[v].toString());
                      }
                    });
                  },
                  padding: EdgeInsets.all(0.0),
                  child: Opacity(
                    opacity: kutuActivatedFlag[0] ? 1.0 : 0.25,
                    child: Image.asset(
                        'assets/PNG/AntrenmanEkraniAktif/yesil_kutu.png'),
                  )))),
    );
  }
}

class BaslatButton extends StatefulWidget {
  @override
  _BaslatButtonState createState() => _BaslatButtonState();
}

class _BaslatButtonState extends State<BaslatButton> {
  BluetoothConnection connection;
  static final clientID = 0;
  final ScrollController listScrollController = new ScrollController();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
          child: ConstrainedBox(
              constraints: BoxConstraints.expand(),
              child: FlatButton(
                  onPressed: () async {
                    // final selectedDevice =
                    //     await Navigator.of(context).push(
                    //   MaterialPageRoute(
                    //     builder: (context) {
                    //       return SelectBondedDevicePage(
                    //           checkAvailability: false);
                    //     },
                    //   ),
                    // );

                    if (selectedDevice != null) {
                      print('Connect -> selected ' + selectedDevice.address);

                      //_startChat(context, selectedDevice);
                    } else {
                      print('Connect -> no device selected');
                    }
                  },
                  padding: EdgeInsets.all(0.0),
                  child: Opacity(
                    opacity:
                        (/*kutuActivatedFlag[0] ||
                            kutuActivatedFlag[1] ||
                            kutuActivatedFlag[2] ||
                            kutuActivatedFlag[3]*/
                                true)
                            ? 1.0
                            : 0.0,
                    child: Image.asset('assets/PNG/BLUETOOTH/basla_buton.png'),
                  )))),
    );
  }

  // void _sendMessage(String text) async {
  //   text = text.trim();
  //   //textEditingController.clear();

  //   if (text.length > 0) {
  //     try {
  //       connection.output.add(utf8.encode(text + "\r\n"));
  //       await connection.output.allSent;

  //       setState(() {
  //         messages.add(_Message(clientID, text));
  //       });

  //       Future.delayed(Duration(milliseconds: 333)).then((_) {
  //         listScrollController.animateTo(
  //             listScrollController.position.maxScrollExtent,
  //             duration: Duration(milliseconds: 333),
  //             curve: Curves.easeOut);
  //       });
  //     } catch (e) {
  //       // Ignore error, but notify state
  //       setState(() {});
  //     }
  //   }
  // }
}
