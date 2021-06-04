import 'dart:async';
import 'dart:convert';
//import 'dart:html';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_bluetooth_serial_example/Pages/antrenman/antreanman_controller.dart';
import 'package:flutter_bluetooth_serial_example/Pages/antrenmanEkran%C4%B1.dart';
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
  final List kutular;
  final List<int> modMessage;

  const ChatPage({this.kutular, this.modMessage});

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

  double buttonNumTextPadding = Get.height / 25;
  double buttonHeaderTextSize = Get.height / 50;
  double buttonNumTextSize = Get.height / 25;

  int calSuresi;
  int dinSuresi;
  int antSuresi;
  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  bool isConnecting = false;
  bool get isConnected => connection != null && connection.isConnected;

  bool isDisconnecting = false;
  Timer timer;

  @override
  void initState() {
    super.initState();
//TODO timer'ı dakika bitince durmali.
    controller.playFlag.value = false;
    controller.progressValueAnt.value = 1.0;
    controller.progressValueCal.value = 1.0;
    controller.progressValueDin.value = 0.0;
    timer = Timer.periodic(
        Duration(seconds: 2),
        (Timer t) => isConnected
            ? {
                if (controller.playFlag.value)
                  {
                    for (int i = 0; i < 12; i++)
                      {
                        _sendMessage(";;;"),
                      },

                    _sendMessage("b"),
                    _sendMessage(widget.modMessage.join(",") +
                        "," +
                        controller.buttonsContent.join(",") +
                        ","),

                    // for (int i = 0; i < 6; i++)
                    //   {
                    //     _sendMessage(widget.modMessage[i].toString()),

                    //     _sendMessage(","),

                    //   },

                    // for (int i = 0; i < 8; i++)
                    //   {
                    //     _sendMessage(controller.buttonsContent[i].toString()),
                    //     _sendMessage(","),
                    //   },
                    // _sendMessage(widget.modMessage.join(",") +
                    //     controller.buttonsContent.join(",")),

                    _sendMessage("e"),
                    print(connection.isConnected.toString()),

                    for (int i = 0; i < 6; i++)
                      {
                        _sendMessage("..."),
                      },
                    // _sendMessage(widget.modMessage.join(",") +
                    //     controller.buttonsContent.join(",")),
                  }
                else
                  {print("Bluetooth baglantisi kesildi!!")}
              }
            : {
                print("Baglanti Yok"),
                // print("kızmızı activated =" + kutuActivatedFlag[1].toString())
                print("IsConnceting =" + isConnecting.toString())
              });

    // BluetoothConnection.toAddress(widget.server.address).then((_connection) {
    //   print(widget.server.address);
    //   print('Connected to the device');
    //   connection = _connection;
    //   setState(() {
    //     isConnecting = false;
    //     isDisconnecting = false;
    //   });

    //   connection.input.listen(_onDataReceived).onDone(() {
    //     // Example: Detect which side closed the connection
    //     // There should be `isDisconnecting` flag to show are we are (locally)
    //     // in middle of disconnecting process, should be set before calling
    //     // `dispose`, `finish` or `close`, which all causes to disconnect.
    //     // If we except the disconnection, `onDone` should be fired as result.
    //     // If we didn't except this (no flag set), it means closing by remote.
    //     if (isDisconnecting) {
    //       print('Disconnecting locally!');
    //     } else {
    //       print('Disconnected remotely!');
    //     }
    //     if (this.mounted) {
    //       setState(() {});
    //     }
    //   });
    // }).catchError((error) {
    //   print('Cannot connect, exception occured');
    //   print(error);
    // });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }
    for (var i = 0; i < 4; i++) {
      controller.kutuActivatedFlag[i].value = false;
    }
    for (var i = 0; i < 8; i++) {
      controller.buttonsContent[i].value = 0;
      controller.buttonsActivatedFlag[i].value = false;
    }
    controller.isInProgress.value = false;
    timer?.cancel();
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
                        onTap: () => Navigator.pop(context),
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
                                controller.buttonsActivatedFlag[0].value
                                    ? "assets/PNG/AntrenmanEkraniAktif/vucudYuvarlakButtonAktif.png"
                                    : "assets/PNG/AntrenmanEkraniAktif/vucudYuvalakButton.png",
                                height: Get.height / 7,
                              ),
                            ),
                            Text(
                              "boyun",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  // fontWeight: FontWeight.bold,
                                  fontSize: buttonHeaderTextSize),
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.only(top: buttonNumTextPadding),
                              child: Text(
                                controller.buttonsContent[0].value.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    // fontWeight: FontWeight.bold,
                                    fontSize: Get.height / 25),
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
                                controller.buttonsActivatedFlag[1].value
                                    ? "assets/PNG/AntrenmanEkraniAktif/vucudYuvarlakButtonAktif.png"
                                    : "assets/PNG/AntrenmanEkraniAktif/vucudYuvalakButton.png",
                                height: Get.height / 7,
                              ),
                            ),
                            Text(
                              "göğüs",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  // fontWeight: FontWeight.bold,
                                  fontSize: buttonHeaderTextSize),
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.only(top: buttonNumTextPadding),
                              child: Text(
                                controller.buttonsContent[1].value.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    // fontWeight: FontWeight.bold,
                                    fontSize: buttonNumTextSize),
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
                                controller.buttonsActivatedFlag[2].value
                                    ? "assets/PNG/AntrenmanEkraniAktif/vucudYuvarlakButtonAktif.png"
                                    : "assets/PNG/AntrenmanEkraniAktif/vucudYuvalakButton.png",
                                height: Get.height / 7,
                              ),
                            ),
                            Text(
                              "sırt",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  // fontWeight: FontWeight.bold,
                                  fontSize: buttonHeaderTextSize),
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.only(top: buttonNumTextPadding),
                              child: Text(
                                controller.buttonsContent[2].value.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    // fontWeight: FontWeight.bold,
                                    fontSize: buttonNumTextSize),
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
                                controller.buttonsActivatedFlag[3].value
                                    ? "assets/PNG/AntrenmanEkraniAktif/vucudYuvarlakButtonAktif.png"
                                    : "assets/PNG/AntrenmanEkraniAktif/vucudYuvalakButton.png",
                                height: Get.height / 7,
                              ),
                            ),
                            Text(
                              "bel",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  // fontWeight: FontWeight.bold,
                                  fontSize: buttonHeaderTextSize),
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.only(top: buttonNumTextPadding),
                              child: Text(
                                controller.buttonsContent[3].value.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    // fontWeight: FontWeight.bold,
                                    fontSize: buttonNumTextSize),
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
                            onTap: () => {
                              if (widget.kutular[0]
                                  .value) //kutu ilk sayfada aktive edildiyse
                                {
                                  if (isConnected &
                                      controller.kutuActivatedFlag[0].value)
                                    {
                                      disconnectBluetooth(),
                                      controller.kutuActivatedFlag[0].value =
                                          false
                                    }
                                  else
                                    {
                                      if (isConnected &
                                          !controller
                                              .kutuActivatedFlag[0].value)
                                        {
                                          print("pass"),
                                        }
                                      else
                                        {
                                          if (!isConnected &
                                              !controller
                                                  .kutuActivatedFlag[0].value &
                                              !isConnecting)
                                            {
                                              isConnecting = true,
                                              controller.kutuActivatedFlag[1]
                                                  .value = false,
                                              controller.kutuActivatedFlag[3]
                                                  .value = false,
                                              controller.kutuActivatedFlag[2]
                                                  .value = false,
                                              controller.kutuActivatedFlag[0]
                                                  .value = true,
                                              connectBluetooth("siyah1"),
                                            }
                                          else
                                            {
                                              if (!isConnecting)
                                                {
                                                  controller
                                                      .kutuActivatedFlag[0]
                                                      .value = false
                                                }
                                            }
                                        }
                                    }
                                },
                            },
                            child: Opacity(
                              opacity: controller.kutuActivatedFlag[0].value
                                  ? 1
                                  : 0.25,
                              child: Image.asset(
                                'assets/PNG/AntrenmanEkraniAktif/siyah_kutu.png',
                                height: Get.height / 7,
                              ),
                            ),
                          ),
                          // ikinci kutu
                          GestureDetector(
                            onTap: () => {
                              if (widget.kutular[1]
                                  .value) //kutu ilk sayfada aktive edildiyse
                                {
                                  if (isConnected &
                                      controller.kutuActivatedFlag[1].value)
                                    {
                                      disconnectBluetooth(),
                                      controller.kutuActivatedFlag[1].value =
                                          false
                                    }
                                  else
                                    {
                                      if (isConnected &
                                          !controller
                                              .kutuActivatedFlag[1].value)
                                        {
                                          print("pass"),
                                        }
                                      else
                                        {
                                          if (!isConnected &
                                              !controller
                                                  .kutuActivatedFlag[1].value &
                                              !isConnecting)
                                            {
                                              isConnecting = true,
                                              controller.kutuActivatedFlag[3]
                                                  .value = false,
                                              controller.kutuActivatedFlag[0]
                                                  .value = false,
                                              controller.kutuActivatedFlag[2]
                                                  .value = false,
                                              controller.kutuActivatedFlag[1]
                                                  .value = true,
                                              connectBluetooth("kirmizi2"),
                                            }
                                          else
                                            {
                                              if (!isConnecting)
                                                {
                                                  controller
                                                      .kutuActivatedFlag[1]
                                                      .value = false
                                                }
                                            }
                                        }
                                    }
                                },
                            },
                            child: Opacity(
                              opacity: controller.kutuActivatedFlag[1].value
                                  ? 1
                                  : 0.25,
                              child: Image.asset(
                                'assets/PNG/AntrenmanEkraniAktif/kirmizi.png',
                                height: Get.height / 8,
                              ),
                            ),
                          ),
                          // ucuncu kutu
                          GestureDetector(
                            onTap: () => {
                              if (widget.kutular[2].value)
                                {
                                  if (isConnected &
                                      controller.kutuActivatedFlag[2].value)
                                    {
                                      disconnectBluetooth(),
                                      controller.kutuActivatedFlag[2].value =
                                          false
                                    }
                                  else
                                    {
                                      if (isConnected &
                                          !controller
                                              .kutuActivatedFlag[2].value)
                                        {
                                          print("pass"),
                                        }
                                      else
                                        {
                                          if (!isConnected &
                                              !controller
                                                  .kutuActivatedFlag[2].value &
                                              !isConnecting)
                                            {
                                              isConnecting = true,
                                              controller.kutuActivatedFlag[1]
                                                  .value = false,
                                              controller.kutuActivatedFlag[0]
                                                  .value = false,
                                              controller.kutuActivatedFlag[3]
                                                  .value = false,
                                              controller.kutuActivatedFlag[2]
                                                  .value = true,
                                              connectBluetooth("yesil3"),
                                            }
                                          else
                                            {
                                              if (!isConnecting)
                                                {
                                                  controller
                                                      .kutuActivatedFlag[2]
                                                      .value = false
                                                }
                                            }
                                        }
                                    }
                                },
                              // if (widget.kutular[2].value)
                              //   {
                              //     if (isConnected)
                              //       {
                              //         isDisconnecting = true,
                              //         connection.dispose(),
                              //         connection = null,
                              //       },
                              //     controller.kutuActivatedFlag[0].value = false,
                              //     controller.kutuActivatedFlag[1].value = false,
                              //     controller.kutuActivatedFlag[3].value = false,
                              //     controller.kutuActivatedFlag[2].value =
                              //         !controller.kutuActivatedFlag[2].value,
                              //     if (controller.kutuActivatedFlag[2].value)
                              //       {
                              //         controller.read("yesil3").then((s) async {
                              //           print(s);
                              //           BluetoothConnection.toAddress(s)
                              //               .then((_connection) {
                              //             print(s);
                              //             print('Connected to the device');
                              //             connection = _connection;
                              //             setState(
                              //               () {
                              //                 isConnecting = false;
                              //                 isDisconnecting = false;
                              //               },
                              //             );
                              //           });
                              //         }),
                              //       },
                              //   }
                            },
                            child: Opacity(
                              opacity: controller.kutuActivatedFlag[2].value
                                  ? 1
                                  : 0.25,
                              child: Image.asset(
                                'assets/PNG/AntrenmanEkraniAktif/yesil_kutu.png',
                                height: Get.height / 8,
                              ),
                            ),
                          ),
                          //dorduncu kutu
                          GestureDetector(
                            onTap: () => {
                              if (widget.kutular[3]
                                  .value) //kutu ilk sayfada aktive edildiyse
                                {
                                  if (isConnected &
                                      controller.kutuActivatedFlag[3].value)
                                    {
                                      disconnectBluetooth(),
                                      controller.kutuActivatedFlag[3].value =
                                          false
                                    }
                                  else
                                    {
                                      if (isConnected &
                                          !controller
                                              .kutuActivatedFlag[3].value)
                                        {
                                          print("pass"),
                                        }
                                      else
                                        {
                                          if (!isConnected &
                                              !controller
                                                  .kutuActivatedFlag[3].value &
                                              !isConnecting)
                                            {
                                              isConnecting = true,
                                              controller.kutuActivatedFlag[1]
                                                  .value = false,
                                              controller.kutuActivatedFlag[0]
                                                  .value = false,
                                              controller.kutuActivatedFlag[2]
                                                  .value = false,
                                              controller.kutuActivatedFlag[3]
                                                  .value = true,
                                              connectBluetooth("mavi4"),
                                            }
                                          else
                                            {
                                              if (!isConnecting)
                                                {
                                                  controller
                                                      .kutuActivatedFlag[3]
                                                      .value = false
                                                }
                                            }
                                        }
                                    }
                                },
                            },
                            child: Opacity(
                              opacity: controller.kutuActivatedFlag[3].value
                                  ? 1
                                  : 0.25,
                              child: Image.asset(
                                'assets/PNG/AntrenmanEkraniAktif/mavi_kutu.png',
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
                    child: Obx(
                      () => Row(
                        children: <Widget>[
                          //Arka Vucud Bolgeleri
                          Expanded(
                              flex: 28,
                              child: Container(
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(
                                              'assets/PNG/AntrenmanEkraniPasif/arkaResim.png'),
                                          /*fit: BoxFit.*/
                                        ),
                                        //shape: BoxShape.rectangle,
                                      ),
                                    ),
                                    Container(
                                        alignment: Alignment.center,
                                        child: Image.asset(
                                          controller
                                                  .buttonsActivatedFlag[0].value
                                              ? "assets/PNG/AntrenmanEkraniAktif/vucudBolgeleri/myArka/boyun.png"
                                              : "assets/PNG/AntrenmanEkraniAktif/vucudBolgeleri/myArka/null.png",
                                        )),
                                    Container(
                                        alignment: Alignment.center,
                                        child: Image.asset(
                                          controller
                                                  .buttonsActivatedFlag[2].value
                                              ? "assets/PNG/AntrenmanEkraniAktif/vucudBolgeleri/myArka/sirt.png"
                                              : "assets/PNG/AntrenmanEkraniAktif/vucudBolgeleri/myArka/null.png",
                                        )),
                                    Container(
                                        alignment: Alignment.center,
                                        child: Image.asset(
                                          controller
                                                  .buttonsActivatedFlag[3].value
                                              ? "assets/PNG/AntrenmanEkraniAktif/vucudBolgeleri/myArka/bel.png"
                                              : "assets/PNG/AntrenmanEkraniAktif/vucudBolgeleri/myArka/null.png",
                                        )),
                                    Container(
                                        alignment: Alignment.center,
                                        child: Image.asset(
                                          controller
                                                  .buttonsActivatedFlag[4].value
                                              ? "assets/PNG/AntrenmanEkraniAktif/vucudBolgeleri/myArka/kol.png"
                                              : "assets/PNG/AntrenmanEkraniAktif/vucudBolgeleri/myArka/null.png",
                                        )),
                                    Container(
                                        alignment: Alignment.center,
                                        child: Image.asset(
                                          controller
                                                  .buttonsActivatedFlag[6].value
                                              ? "assets/PNG/AntrenmanEkraniAktif/vucudBolgeleri/myArka/popo.png"
                                              : "assets/PNG/AntrenmanEkraniAktif/vucudBolgeleri/myArka/null.png",
                                        )),
                                    Container(
                                        alignment: Alignment.center,
                                        child: Image.asset(
                                          controller
                                                  .buttonsActivatedFlag[7].value
                                              ? "assets/PNG/AntrenmanEkraniAktif/vucudBolgeleri/myArka/bacak.png"
                                              : "assets/PNG/AntrenmanEkraniAktif/vucudBolgeleri/myArka/null.png",
                                        )),
                                  ],
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Center(
                                          child: Text(
                                            'ANTRENMAN SÜRESİ',
                                            style: TextStyle(
                                                color: Colors.white38,
                                                fontSize: Get.height / 50),
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                                '${(controller.antrenmanSuresi[widget.modMessage[0]][widget.modMessage[2]]).value} dk',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: Get.height / 50)),
                                            Text(
                                                '${(controller.antrenmanSuresi[widget.modMessage[0]][widget.modMessage[2]]).value} dk',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: Get.height / 50)),
                                          ],
                                        ),
                                        LinearProgressIndicator(
                                          backgroundColor: Colors.black,
                                          valueColor:
                                              new AlwaysStoppedAnimation<Color>(
                                                  Colors.orange),
                                          value:
                                              controller.progressValueAnt.value,
                                        ),
                                      ],
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Center(
                                          child: Text(
                                            'ÇALIŞMA SURESİ',
                                            style: TextStyle(
                                                color: Colors.white38,
                                                fontSize: Get.height / 50),
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                                '${(controller.calismaDinlenmeSuresi[widget.modMessage[4]]).value} sn',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: Get.height / 50)),
                                            Text(
                                                '${(controller.calismaDinlenmeSuresi[widget.modMessage[4]]).value} sn',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: Get.height / 50)),
                                          ],
                                        ),
                                        LinearProgressIndicator(
                                          backgroundColor: Colors.black,
                                          valueColor:
                                              new AlwaysStoppedAnimation<Color>(
                                                  Colors.yellow),
                                          value:
                                              controller.progressValueCal.value,
                                        ),
                                      ],
                                    ),
                                    //3. seyin suseri
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Center(
                                          child: Text(
                                            'DİNLENME SÜRESİ',
                                            style: TextStyle(
                                                color: Colors.white38,
                                                fontSize: Get.height / 50),
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                                '${(controller.calismaDinlenmeSuresi[widget.modMessage[5]]).value} sn',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: Get.height / 50)),
                                            Text(
                                                '${(controller.calismaDinlenmeSuresi[widget.modMessage[5]]).value} sn',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: Get.height / 50)),
                                          ],
                                        ),
                                        LinearProgressIndicator(
                                          backgroundColor: Colors.black,
                                          valueColor:
                                              new AlwaysStoppedAnimation<Color>(
                                                  Colors.blue),
                                          value:
                                              controller.progressValueDin.value,
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
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(
                                              'assets/PNG/AntrenmanEkraniPasif/onResim.png'),
                                          /*fit: BoxFit.*/
                                        ),
                                        //shape: BoxShape.rectangle,
                                      ),
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      child: Image.asset(
                                        controller.buttonsActivatedFlag[1].value
                                            ? "assets/PNG/AntrenmanEkraniAktif/vucudBolgeleri/myOn/meme.png"
                                            : "assets/PNG/AntrenmanEkraniAktif/vucudBolgeleri/myOn/null.png",
                                      ),
                                    ),
                                    Container(
                                        alignment: Alignment.center,
                                        child: Image.asset(
                                          controller
                                                  .buttonsActivatedFlag[4].value
                                              ? "assets/PNG/AntrenmanEkraniAktif/vucudBolgeleri/myOn/kol.png"
                                              : "assets/PNG/AntrenmanEkraniAktif/vucudBolgeleri/myOn/null.png",
                                        )),
                                    Container(
                                        alignment: Alignment.center,
                                        child: Image.asset(
                                          controller
                                                  .buttonsActivatedFlag[5].value
                                              ? "assets/PNG/AntrenmanEkraniAktif/vucudBolgeleri/myOn/karin.png"
                                              : "assets/PNG/AntrenmanEkraniAktif/vucudBolgeleri/myOn/null.png",
                                        )),
                                    Container(
                                        alignment: Alignment.center,
                                        child: Image.asset(
                                          controller
                                                  .buttonsActivatedFlag[7].value
                                              ? "assets/PNG/AntrenmanEkraniAktif/vucudBolgeleri/myOn/bacak.png"
                                              : "assets/PNG/AntrenmanEkraniAktif/vucudBolgeleri/myOn/null.png",
                                        )),
                                  ],
                                ),
                              )),
                        ],
                      ),
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
                              // if (isConnected)
                              //   {
                              // for (int i = 0; i < 12; i++)
                              //   {
                              //     _sendMessage(";;;\r\n;;;\r\n;;;\r\n;;;\r\n;;;\r\n"),
                              //   },

                              // _sendMessage(
                              //     ";;;\r\n;;;\r\n;;;\r\n;;;\r\n;;;\r\n;;;\r\n;;;\r\n;;;\r\n;;;\r\n;;;\r\n"),

                              // _sendMessage("b\r\n"),

                              // for (int i = 0; i < 6; i++)
                              //   {
                              //     _sendMessage(
                              //         widget.modMessage[i].toString()),
                              //     _sendMessage(","),
                              //   },

                              // for (int i = 0; i < 8; i++)
                              //   {
                              //     _sendMessage(controller.buttonsContent[i]
                              //         .toString()),
                              //     _sendMessage(","),
                              //   },
                              //
                              // Future.delayed(Duration(seconds: 3))
                              //     .then((_) {
                              //   _sendMessage(
                              //       ";;;\r\n;;;\r\n;;;\r\n;;;\r\n;;;\r\n;;;\r\n;;;\r\n;;;\r\n;;;\r\n;;;\r\n" +
                              //           "b\r\n" +
                              //           widget.modMessage
                              //               .join("\r\n,\r\n") +
                              //           "\r\n,\r\n" +
                              //           controller.buttonsContent
                              //               .join("\r\n,\r\n") +
                              //           ",\r\ne" +
                              //           ",\r\n...\r\n...");
                              // }),

                              // _sendMessage(",\r\ne"),

                              // for (int i = 0; i < 3; i++)
                              //   {
                              //     _sendMessage("..."),
                              //   },
                              //   }
                              // else
                              //   {print("Bluetooth baglantisi kesildi!!")}
                            },
                            // onDoubleTap: () => {
                            //   controller.arttir(),
                            //   if (isConnected)
                            //     {
                            //       for (int i = 0; i < 12; i++)
                            //         {
                            //           _sendMessage(";;;"),
                            //         },

                            //       _sendMessage("b"),

                            //       for (int i = 0; i < 6; i++)
                            //         {
                            //           _sendMessage(
                            //               widget.modMessage[i].toString()),
                            //           _sendMessage(","),
                            //         },

                            //       for (int i = 0; i < 8; i++)
                            //         {
                            //           _sendMessage(controller.buttonsContent[i]
                            //               .toString()),
                            //           _sendMessage(","),
                            //         },
                            //       // _sendMessage(widget.modMessage.join(",") +
                            //       //     controller.buttonsContent.join(",")),

                            //       _sendMessage("e"),

                            //       for (int i = 0; i < 3; i++)
                            //         {
                            //           _sendMessage("..."),
                            //         },
                            //     }
                            //   else
                            //     {print("Bluetooth baglantisi kesildi!!")}
                            // },
                            child: Image.asset(
                                "assets/PNG/AntrenmanEkraniPasif/arti.png",
                                height: Get.height / 7),
                          ),

                          //Play Button
                          GestureDetector(
                            onTap: () => {
                              calSuresi = (controller.calismaDinlenmeSuresi[
                                      widget.modMessage[4]])
                                  .value,
                              dinSuresi = (controller.calismaDinlenmeSuresi[
                                      widget.modMessage[5]])
                                  .value,
                              antSuresi = (controller
                                          .antrenmanSuresi[widget.modMessage[0]]
                                      [widget.modMessage[2]])
                                  .value,
                              controller.playFlag.value =
                                  !controller.playFlag.value,
                              controller.changeOpacity(
                                  controller.playFlag.value ? 1 : 0.25),
                              if (controller.playFlag.value)
                                {
                                  controller
                                      .updateProgressAntrenmanSuresi(antSuresi),
                                  controller.updateProgressCal(
                                      calSuresi, dinSuresi)
                                }
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
                              // if (isConnected)
                              //   {
                              //     for (int i = 0; i < 12; i++)
                              //       {
                              //         _sendMessage(";;;"),
                              //       },

                              //     _sendMessage("b"),

                              //     for (int i = 0; i < 6; i++)
                              //       {
                              //         _sendMessage(
                              //             widget.modMessage[i].toString()),
                              //         _sendMessage(","),
                              //       },

                              //     for (int i = 0; i < 8; i++)
                              //       {
                              //         _sendMessage(controller.buttonsContent[i]
                              //             .toString()),
                              //         _sendMessage(","),
                              //       },
                              //     // _sendMessage(widget.modMessage.join(",") +
                              //     //     controller.buttonsContent.join(",")),

                              //     _sendMessage("e"),

                              //     for (int i = 0; i < 12; i++)
                              //       {
                              //         _sendMessage("..."),
                              //       },
                              //     // _sendMessage(widget.modMessage.join(",") +
                              //     //     controller.buttonsContent.join(",")),
                              //   }
                              // else
                              //   {print("Bluetooth baglantisi kesildi!!")}
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
                                controller.buttonsActivatedFlag[4].value
                                    ? "assets/PNG/AntrenmanEkraniAktif/vucudYuvarlakButtonAktif.png"
                                    : "assets/PNG/AntrenmanEkraniAktif/vucudYuvalakButton.png",
                                height: Get.height / 7,
                              ),
                            ),
                            Text(
                              "kollar",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  // fontWeight: FontWeight.bold,
                                  fontSize: buttonHeaderTextSize),
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.only(top: buttonNumTextPadding),
                              child: Text(
                                controller.buttonsContent[4].value.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    // fontWeight: FontWeight.bold,
                                    fontSize: buttonNumTextSize),
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
                                controller.buttonsActivatedFlag[5].value
                                    ? "assets/PNG/AntrenmanEkraniAktif/vucudYuvarlakButtonAktif.png"
                                    : "assets/PNG/AntrenmanEkraniAktif/vucudYuvalakButton.png",
                                height: Get.height / 7,
                              ),
                            ),
                            Text(
                              "karın",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  // fontWeight: FontWeight.bold,
                                  fontSize: buttonHeaderTextSize),
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.only(top: buttonNumTextPadding),
                              child: Text(
                                controller.buttonsContent[5].value.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    // fontWeight: FontWeight.bold,
                                    fontSize: buttonNumTextSize),
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
                                controller.buttonsActivatedFlag[6].value
                                    ? "assets/PNG/AntrenmanEkraniAktif/vucudYuvarlakButtonAktif.png"
                                    : "assets/PNG/AntrenmanEkraniAktif/vucudYuvalakButton.png",
                                height: Get.height / 7,
                              ),
                            ),
                            Text(
                              "kalça",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  // fontWeight: FontWeight.bold,
                                  fontSize: buttonHeaderTextSize),
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.only(top: buttonNumTextPadding),
                              child: Text(
                                controller.buttonsContent[6].value.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    // fontWeight: FontWeight.bold,
                                    fontSize: buttonNumTextSize),
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
                                controller.buttonsActivatedFlag[7].value
                                    ? "assets/PNG/AntrenmanEkraniAktif/vucudYuvarlakButtonAktif.png"
                                    : "assets/PNG/AntrenmanEkraniAktif/vucudYuvalakButton.png",
                                height: Get.height / 7,
                              ),
                            ),
                            Text(
                              "bacaklar",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  // fontWeight: FontWeight.bold,
                                  fontSize: buttonHeaderTextSize),
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.only(top: buttonNumTextPadding),
                              child: Text(
                                controller.buttonsContent[7].value.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    // fontWeight: FontWeight.bold,
                                    fontSize: buttonNumTextSize),
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
                    onTap: () => SystemChannels.platform
                        .invokeMethod('SystemNavigator.pop'),
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

  bool connectBluetooth(String renk) {
    var ableToConnect = false;
    controller.read(renk).then((s) async {
      print(s);
      BluetoothConnection.toAddress(s).then((_connection) {
        print(s);
        print('Connected to the device');
        connection = _connection;
        setState(
          () {
            isConnecting = false;
            isDisconnecting = false;
            ableToConnect = true;
          },
        );
      });
    }).catchError(print("Cant connect"), isConnecting = false);

    return ableToConnect;
  }

  void disconnectBluetooth() {
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }
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
    //text = text.trim();
    //textEditingController.clear();

    if (text.length > 0) {
      try {
        connection.output.add(utf8.encode(text + "\r\n"));
        //await connection.output.close();
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
        // setState(() {});
        // //
        // print("_sendMessage catch error!! eyooo");
      }
    }
  }
}
