import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_bluetooth_serial_example/Pages/state_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

final controller = Get.put(StateController());

List kutuActivatedFlag = [false, false, false, false];

class ChatPage extends StatefulWidget {
  final BluetoothDevice server;

  const ChatPage({this.server});

  @override
  _ChatPage createState() => new _ChatPage();
}

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class _ChatPage extends State<ChatPage> {
  static final clientID = 0;
  BluetoothConnection connection;

  List<_Message> messages = [];
  String _messageBuffer = '';

  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  bool isConnecting = true;
  bool get isConnected => connection != null && connection.isConnected;

  bool isDisconnecting = false;

  @override
  void initState() {
    super.initState();

    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection.input.listen(_onDataReceived).onDone(() {
        // Example: Detect which side closed the connection
        // There should be `isDisconnecting` flag to show are we are (locally)
        // in middle of disconnecting process, should be set before calling
        // `dispose`, `finish` or `close`, which all causes to disconnect.
        // If we except the disconnection, `onDone` should be fired as result.
        // If we didn't except this (no flag set), it means closing by remote.
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: <Widget>[
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/BackCover.jpg'), fit: BoxFit.cover),
            //shape: BoxShape.rectangle,
          ),
        ),
        // color: Colors.yellow,
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // left first Column
            Expanded(
                flex: 15,
                child: Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        child: Opacity(
                          opacity: controller.playFlag.value ? 1.0 : 0.0,
                          child: Image.asset(
                            'assets/PNG/AntrenmanEkraniAktif/cikis_buton.png',
                            height: Get.height / 10,
                          ),
                        ),
                      )
                    ],
                  ),
                )),
            //Left Buttons Column
            Expanded(
              flex: 15,
              child: Obx(
                () => Padding(
                  padding: EdgeInsets.symmetric(vertical: Get.height / 5.4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      //boyun
                      GestureDetector(
                        onTap: () => controller.buttonsActivatedFlag[0].value =
                            !controller.buttonsActivatedFlag[0].value,
                        onDoubleTap: () => controller.doubleTapped(),
                        child: Stack(
                          alignment: Alignment(0, -0.5),
                          children: [
                            Opacity(
                              opacity: controller.opacity.value,
                              child: Image.asset(
                                "assets/PNG/AntrenmanEkraniAktif/vucudYuvalakButton.png",
                                height: Get.height / 7,
                              ),
                            ),
                            Text(
                              "boyun",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 8.0),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 20),
                              child: Text(
                                controller.buttonsContent[0].value.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    // fontWeight: FontWeight.bold,
                                    fontSize: 16.0),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => controller.buttonsActivatedFlag[1].value =
                            !controller.buttonsActivatedFlag[1].value,
                        onDoubleTap: () => controller.doubleTapped(),
                        child: Stack(
                          alignment: Alignment(0, -0.5),
                          children: [
                            Opacity(
                              opacity: controller.opacity.value,
                              child: Image.asset(
                                "assets/PNG/AntrenmanEkraniAktif/vucudYuvalakButton.png",
                                height: Get.height / 7,
                              ),
                            ),
                            Text(
                              "göğüs",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 8.0),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 20),
                              child: Text(
                                controller.buttonsContent[1].value.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    // fontWeight: FontWeight.bold,
                                    fontSize: 16.0),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => controller.buttonsActivatedFlag[2].value =
                            !controller.buttonsActivatedFlag[2].value,
                        onDoubleTap: () => controller.doubleTapped(),
                        child: Stack(
                          alignment: Alignment(0, -0.5),
                          children: [
                            Opacity(
                              opacity: controller.opacity.value,
                              child: Image.asset(
                                "assets/PNG/AntrenmanEkraniAktif/vucudYuvalakButton.png",
                                height: Get.height / 7,
                              ),
                            ),
                            Text(
                              "sırt",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 8.0),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 20),
                              child: Text(
                                controller.buttonsContent[2].value.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    // fontWeight: FontWeight.bold,
                                    fontSize: 16.0),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => controller.buttonsActivatedFlag[3].value =
                            !controller.buttonsActivatedFlag[3].value,
                        onDoubleTap: () => controller.doubleTapped(),
                        child: Stack(
                          alignment: Alignment(0, -0.5),
                          children: [
                            Opacity(
                              opacity: controller.opacity.value,
                              child: Image.asset(
                                "assets/PNG/AntrenmanEkraniAktif/vucudYuvalakButton.png",
                                height: Get.height / 7,
                              ),
                            ),
                            Text(
                              "bel",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 8.0),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 20),
                              child: Text(
                                controller.buttonsContent[3].value.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    // fontWeight: FontWeight.bold,
                                    fontSize: 16.0),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            //Mid Column
            Expanded(
              flex: 40,
              child: Column(
                children: <Widget>[
                  //Kutular
                  Expanded(
                    flex: 3, // 20%
                    child: Obx(
                      () => Row(
                        children: <Widget>[
                          GestureDetector(
                            onTap: () => controller.kutuActivatedFlag[0].value =
                                !controller.kutuActivatedFlag[0].value,
                            child: Opacity(
                              opacity: controller.kutuActivatedFlag[0].value
                                  ? 1
                                  : 0.25,
                              child: Image.asset(
                                'assets/PNG/AntrenmanEkraniAktif/yesil_kutu.png',
                                height: Get.height / 7,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => controller.kutuActivatedFlag[0].value =
                                !controller.kutuActivatedFlag[0].value,
                            child: Opacity(
                              opacity: controller.kutuActivatedFlag[0].value
                                  ? 1
                                  : 0.25,
                              child: Image.asset(
                                'assets/PNG/AntrenmanEkraniAktif/yesil_kutu.png',
                                height: Get.height / 7,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => controller.kutuActivatedFlag[0].value =
                                !controller.kutuActivatedFlag[0].value,
                            child: Opacity(
                              opacity: controller.kutuActivatedFlag[0].value
                                  ? 1
                                  : 0.25,
                              child: Image.asset(
                                'assets/PNG/AntrenmanEkraniAktif/yesil_kutu.png',
                                height: Get.height / 7,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => controller.kutuActivatedFlag[0].value =
                                !controller.kutuActivatedFlag[0].value,
                            child: Opacity(
                              opacity: controller.kutuActivatedFlag[0].value
                                  ? 1
                                  : 0.25,
                              child: Image.asset(
                                'assets/PNG/AntrenmanEkraniAktif/yesil_kutu.png',
                                height: Get.height / 7,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  //Vucud bolgeleri ve barlar
                  Expanded(
                    flex: 5, // 60%
                    child: Row(
                      children: <Widget>[
                        //Arka Vucud Bolgeleri
                        Expanded(
                            flex: 28,
                            child: Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                      'assets/PNG/AntrenmanEkraniPasif/arkaResim.png'),
                                  /*fit: BoxFit.*/
                                ),
                                //shape: BoxShape.rectangle,
                              ),
                            )),
                        //Sayac barları
                        Expanded(
                            flex: 44,
                            child: Obx(
                              () => Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  //Antrenman Süresi
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Center(
                                        child: Text(
                                          'ANTRENMAN SÜRESİ',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 8.0),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                              '${(controller.antTime.value).round()} dk',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 8.0)),
                                          Text(
                                              '${(controller.antTime.value).round()} dk',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 8.0)),
                                        ],
                                      ),
                                      LinearProgressIndicator(
                                        backgroundColor: Colors.black,
                                        valueColor:
                                            new AlwaysStoppedAnimation<Color>(
                                                Colors.orange),
                                        value: controller.progressValue.value,
                                      ),
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Center(
                                        child: Text(
                                          'ÇALIŞMA SURESİ',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 8.0),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                              '${(controller.calTime.value).round()} sn',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 8.0)),
                                          Text(
                                              '${(controller.calTime.value).round()} sn',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 8.0)),
                                        ],
                                      ),
                                      LinearProgressIndicator(
                                        backgroundColor: Colors.black,
                                        valueColor:
                                            new AlwaysStoppedAnimation<Color>(
                                                Colors.yellow),
                                        value: controller.progressValue.value,
                                      ),
                                    ],
                                  ),
                                  //3. seyin suseri
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Center(
                                        child: Text(
                                          'DİNLENME SÜRESİ',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 8.0),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                              '${(controller.dinTime.value).round()} sn',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 8.0)),
                                          Text(
                                              '${(controller.dinTime.value).round()} sn',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 8.0)),
                                        ],
                                      ),
                                      LinearProgressIndicator(
                                        backgroundColor: Colors.black,
                                        valueColor:
                                            new AlwaysStoppedAnimation<Color>(
                                                Colors.blue),
                                        value: controller.progressValue.value,
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            )),
                        //On Vucud Bolgeleri
                        Expanded(
                            flex: 28,
                            child: Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                      'assets/PNG/AntrenmanEkraniPasif/onResim.png'),
                                  /*fit: BoxFit.*/
                                ),
                                //shape: BoxShape.rectangle,
                              ),
                            )),
                      ],
                    ),
                  ),
                  //Play and increase/decrease Buttons
                  Expanded(
                    flex: 2, // 20%
                    child: Obx(
                      () => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          //Increase Button                        //
                          GestureDetector(
                            onTap: () => {
                              controller.arttir(),
                              if (isConnected)
                                {
                                  _sendMessage(
                                      "Bluetooth send message works!!"),
                                },
                            },
                            child: Image.asset(
                                "assets/PNG/AntrenmanEkraniPasif/arti.png",
                                height: Get.height / 7),
                          ),

                          //Play Button
                          GestureDetector(
                            onTap: () => {
                              controller.playFlag.value =
                                  !controller.playFlag.value,
                              controller.changeOpacity(
                                  controller.playFlag.value ? 1 : 0.25),
                              if (controller.playFlag.value)
                                {controller.updateProgress()}
                            },
                            child: Image.asset(
                                controller.playFlag.value
                                    ? "assets/PNG/AntrenmanEkraniAktif/stopButton.png"
                                    : "assets/PNG/AntrenmanEkraniPasif/baslat.png",
                                height: Get.height / 10),
                          ),
                          //Decrease Button
                          GestureDetector(
                            onTap: () => {
                              controller.azalt(),
                              if (isConnected)
                                {
                                  _sendMessage(
                                      "Bluetooth send message works!!"),
                                },
                            },
                            child: Image.asset(
                                "assets/PNG/AntrenmanEkraniPasif/eksi.png",
                                height: Get.height / 7),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(flex: 1, child: Row())
                ],
              ),
            ),
            //Right buttons Column
            Expanded(
              flex: 15,
              child: Obx(
                () => Padding(
                  padding: EdgeInsets.symmetric(vertical: Get.height / 5.4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () => controller.buttonsActivatedFlag[4].value =
                            !controller.buttonsActivatedFlag[4].value,
                        onDoubleTap: () => controller.doubleTapped(),
                        child: Stack(
                          alignment: Alignment(0, -0.5),
                          children: [
                            Opacity(
                              opacity: controller.opacity.value,
                              child: Image.asset(
                                "assets/PNG/AntrenmanEkraniAktif/vucudYuvalakButton.png",
                                height: Get.height / 7,
                              ),
                            ),
                            Text(
                              "kollar",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 8.0),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 20),
                              child: Text(
                                controller.buttonsContent[4].value.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    // fontWeight: FontWeight.bold,
                                    fontSize: 16.0),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => controller.buttonsActivatedFlag[5].value =
                            !controller.buttonsActivatedFlag[5].value,
                        onDoubleTap: () => controller.doubleTapped(),
                        child: Stack(
                          alignment: Alignment(0, -0.5),
                          children: [
                            Opacity(
                              opacity: controller.opacity.value,
                              child: Image.asset(
                                "assets/PNG/AntrenmanEkraniAktif/vucudYuvalakButton.png",
                                height: Get.height / 7,
                              ),
                            ),
                            Text(
                              "karın",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 8.0),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 20),
                              child: Text(
                                controller.buttonsContent[5].value.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    // fontWeight: FontWeight.bold,
                                    fontSize: 16.0),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => controller.buttonsActivatedFlag[6].value =
                            !controller.buttonsActivatedFlag[6].value,
                        onDoubleTap: () => controller.doubleTapped(),
                        child: Stack(
                          alignment: Alignment(0, -0.5),
                          children: [
                            Opacity(
                              opacity: controller.opacity.value,
                              child: Image.asset(
                                "assets/PNG/AntrenmanEkraniAktif/vucudYuvalakButton.png",
                                height: Get.height / 7,
                              ),
                            ),
                            Text(
                              "kalça",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 8.0),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 20),
                              child: Text(
                                controller.buttonsContent[6].value.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    // fontWeight: FontWeight.bold,
                                    fontSize: 16.0),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => controller.buttonsActivatedFlag[7].value =
                            !controller.buttonsActivatedFlag[7].value,
                        onDoubleTap: () => controller.doubleTapped(),
                        child: Stack(
                          alignment: Alignment(0, -0.5),
                          children: [
                            Opacity(
                              opacity: controller.opacity.value,
                              child: Image.asset(
                                "assets/PNG/AntrenmanEkraniAktif/vucudYuvalakButton.png",
                                height: Get.height / 7,
                              ),
                            ),
                            Text(
                              "bacaklar",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 8.0),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 20),
                              child: Text(
                                controller.buttonsContent[7].value.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    // fontWeight: FontWeight.bold,
                                    fontSize: 16.0),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // En sag kolon
            Expanded(
              flex: 15,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    child: Image.asset(
                      'assets/PNG/AntrenmanEkraniAktif/cikis.png',
                      height: Get.height / 10,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ]),
    );
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (~index != 0) {
      setState(() {
        messages.add(
          _Message(
            1,
            backspacesCounter > 0
                ? _messageBuffer.substring(
                    0, _messageBuffer.length - backspacesCounter)
                : _messageBuffer + dataString.substring(0, index),
          ),
        );
        _messageBuffer = dataString.substring(index);
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }

  void _sendMessage(String text) async {
    text = text.trim();
    //textEditingController.clear();

    if (text.length > 0) {
      try {
        connection.output.add(utf8.encode(text + "\r\n"));
        await connection.output.allSent;

        // setState(() {
        //   messages.add(_Message(clientID, text));
        // });

        // Future.delayed(Duration(milliseconds: 333)).then((_) {
        //   listScrollController.animateTo(
        //       listScrollController.position.maxScrollExtent,
        //       duration: Duration(milliseconds: 333),
        //       curve: Curves.easeOut);
        // });
      } catch (e) {
        // Ignore error, but notify state
        //setState(() {});
        //
        print("_sendMessage catch error!! eyooo");
      }
    }
  }
}

// class LinearProgressIndicatorApp extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() {
//     return LinearProgressIndicatorAppState();
//   }
// }

// class LinearProgressIndicatorAppState
//     extends State<LinearProgressIndicatorApp> {
//   bool _loading = false;
//   double _progressValue = 100;

//   @override
//   void initState() {
//     super.initState();
//     _loading = true;
//     _progressValue = 1.0;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//         child: Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: <Widget>[
//         Center(
//           child: Text(
//             'ANTRENMAN SURESİ',
//             style: TextStyle(color: Colors.white, fontSize: 8.0),
//           ),
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text('${(_progressValue * 100).round()} dk',
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8.0)),
//             Text('${(_progressValue * 100).round()} dk',
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8.0)),
//           ],
//         ),
//         LinearProgressIndicator(
//           backgroundColor: Colors.cyanAccent,
//           valueColor: new AlwaysStoppedAnimation<Color>(Colors.orange),
//           value: _progressValue,
//         ),
//       ],
//     ));
//   }

//   // this function updates the progress value
//   void _updateProgress() {
//     const oneSec = const Duration(seconds: 1);
//     new Timer.periodic(oneSec, (Timer t) {
//       setState(() {
//         _progressValue -= 0.1;
//         // we "finish" downloading here
//         if (_progressValue <= 0.0) {
//           _loading = false;
//           t.cancel();
//           _progressValue = 1;
//           return;
//         }
//       });
//     });
//   }
// }
