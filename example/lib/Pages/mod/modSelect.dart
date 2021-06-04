import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial_example/Pages/antrenman/antrenman_page.dart';
import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import './modSelect_controller.dart';

final controller = Get.put(StateControllerMode());

class ModeSelect extends StatefulWidget {
  final List kutular;

  const ModeSelect({this.kutular});
  @override
  _ModeSelect createState() => _ModeSelect();
}

class _ModeSelect extends State<ModeSelect> {
//List that has the final config
  List<int> modMessage;
  // FixedExtentScrollController modScrollController;
  // FixedExtentScrollController seviyeScrollController;
  // FixedExtentScrollController modIScrollController;
  // FixedExtentScrollController calSurScrollController;
  // FixedExtentScrollController antSurScrollController;
  // FixedExtentScrollController dinSurScrollController;

  // void _incrementCounter() {
  //   modScrollController.animateTo(itemExtent,
  //       duration: Duration(milliseconds: 200), curve: Curves.ease);
  //   setState(() {
  //     _counter++;
  //   });
  // }
  double pageHeaderSize = Get.height / 20;
  double subHeaderSize = Get.height / 27;

  double itemExtent = Get.height / 20;
  double curTextSize = Get.height / 24;
  double diameterRatio = 1.2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(
      //     "MOD SEÇİMİ",
      //     textAlign: TextAlign.center,
      //   ),
      //   toolbarOpacity: 1.0,
      //   backgroundColor: Colors.black,
      //   bottomOpacity: 1.0,
      // ),
      body: Stack(
        children: [
          Center(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/BackCover.jpg'),
                    fit: BoxFit.cover),
                //shape: BoxShape.rectangle,
              ),
            ),
          ),
          Obx(
            () => Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "MOD SEÇİMİ",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: pageHeaderSize,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    )),
                //Text MODLAR - SEVİYE
                Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "MODLAR",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: subHeaderSize,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "SEVİYE",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: subHeaderSize,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    )),
                //Cupertino MODLAR - SEVIYE
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 20,
                          width: 15,
                        ),
                      ),
                      //MODLAR
                      Expanded(
                        flex: 3,
                        child: Container(
                          //width: 20,
                          child: ListWheelScrollView(
                            //scrollController: modScrollController,
                            itemExtent: itemExtent,
                            diameterRatio: diameterRatio,
                            squeeze: 1.1,
                            //perspective: 0.01,
                            overAndUnderCenterOpacity: 0.3,
                            children: <Widget>[
                              for (var i = 0; i < controller.modlar.length; i++)
                                Text(
                                  controller.modlar[i].value,
                                  style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: curTextSize),
                                ),
                            ],
                            onSelectedItemChanged: (int index) {
                              //print(controller.modlar[index].value);
                              controller.selectedMod.value = index;
                              controller.selectedSeviye.value = 0;
                              controller.selectedModIc.value = 0;
                              controller.selectedCalismaSur.value = 0;
                              controller.selectedAntrenmanSur.value = 0;
                              controller.selectedDinlenmeSur.value = 0;
                            },
                            //looping: false,
                            // backgroundColor: Color(0xff2e3032),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: SizedBox(
                          height: 20,
                          width: 15,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: ListWheelScrollView(
                          //scrollController: modScrollController,
                          itemExtent: itemExtent,
                          diameterRatio: diameterRatio,
                          squeeze: 1.1,
                          //perspective: 0.01,
                          overAndUnderCenterOpacity: 0.3,
                          children: <Widget>[
                            for (var i = 0; i < controller.seviye.length; i++)
                              Text(
                                controller.seviye[i].value,
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: curTextSize),
                              ),
                          ],
                          onSelectedItemChanged: (int index) {
                            //print(controller.modlar[index].value);
                            // controller.selectedMod.value = index;
                            controller.selectedSeviye.value = index;
                            // controller.selectedModIc.value = 0;
                            // controller.selectedCalismaSur.value = 0;
                            // controller.selectedAntrenmanSur.value = 0;
                            // controller.selectedDinlenmeSur.value = 0;
                          },
                          //looping: false,
                          // backgroundColor: Color(0xff2e3032),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 20,
                          width: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                //Text mod icerigi - calisma suresi
                Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "MOD İÇERİĞİ",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: subHeaderSize,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "ÇALIŞMA SÜRESİ",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: subHeaderSize,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    )),
                //Cupertino mod icerigi - çalisma süresi
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 1,
                        child: SizedBox(
                          height: 20,
                          width: 10,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: ListWheelScrollView(
                          //scrollController: modScrollController,
                          itemExtent: itemExtent,
                          diameterRatio: diameterRatio,
                          squeeze: 1.1,
                          //perspective: 0.01,
                          overAndUnderCenterOpacity: 0.3,
                          children: <Widget>[
                            for (var i = 0;
                                i <
                                    controller
                                        .modIcerigi[
                                            controller.selectedMod.value]
                                        .length;
                                i++)
                              Text(
                                controller
                                    .modIcerigi[controller.selectedMod.value][i]
                                    .value,
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: curTextSize),
                              ),
                          ],
                          onSelectedItemChanged: (int index) {
                            //print(controller.modlar[index].value);
                            // controller.selectedMod.value = index;
                            // controller.selectedSeviye.value = 0;
                            controller.selectedModIc.value = index;
                            // controller.selectedCalismaSur.value = 0;
                            // controller.selectedAntrenmanSur.value = 0;
                            // controller.selectedDinlenmeSur.value = 0;
                          },
                          //looping: false,
                          // backgroundColor: Color(0xff2e3032),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 20,
                          width: 10,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: ListWheelScrollView(
                          //scrollController: modScrollController,
                          itemExtent: itemExtent,
                          diameterRatio: diameterRatio,
                          squeeze: 1.1,
                          //perspective: 0.01,
                          overAndUnderCenterOpacity: 0.3,
                          children: <Widget>[
                            for (var i = 0;
                                i < controller.calismaSuresi.length;
                                i++)
                              Text(
                                controller.calismaSuresi[i].value,
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: curTextSize),
                              ),
                          ],
                          onSelectedItemChanged: (int index) {
                            //print(controller.modlar[index].value);
                            // controller.selectedMod.value = index;
                            // controller.selectedSeviye.value = index;
                            // controller.selectedModIc.value = 0;
                            controller.selectedCalismaSur.value = index;
                            // controller.selectedAntrenmanSur.value = 0;
                            // controller.selectedDinlenmeSur.value = 0;
                          },
                          //looping: false,
                          // backgroundColor: Color(0xff2e3032),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: SizedBox(
                          height: 20,
                          width: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                //TEXT antrenman süresi - Dinlenme Süresi
                Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "ANTRENMAN SÜRESİ",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: subHeaderSize,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "DİNLENME SÜRESİ",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: subHeaderSize,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    )),
                // Cupertino Antrenan süresi - Dinlenme süresi
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 20,
                          width: 15,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: ListWheelScrollView(
                          //scrollController: modScrollController,
                          itemExtent: itemExtent,
                          diameterRatio: diameterRatio,
                          squeeze: 1.1,
                          //perspective: 0.01,
                          overAndUnderCenterOpacity: 0.3,
                          children: <Widget>[
                            for (var i = 0;
                                i <
                                    controller
                                        .antrenmanSuresi[
                                            controller.selectedMod.value]
                                        .length;
                                i++)
                              Text(
                                controller
                                    .antrenmanSuresi[
                                        controller.selectedMod.value][i]
                                    .value,
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: curTextSize),
                              ),
                          ],
                          onSelectedItemChanged: (int index) {
                            //print(controller.modlar[index].value);
                            // controller.selectedMod.value = index;
                            // controller.selectedSeviye.value = 0;
                            //controller.selectedModIc.value = index;
                            // controller.selectedCalismaSur.value = 0;
                            controller.selectedAntrenmanSur.value = index;
                            // controller.selectedDinlenmeSur.value = 0;
                          },
                          //looping: false,
                          // backgroundColor: Color(0xff2e3032),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: SizedBox(
                          height: 20,
                          width: 10,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: ListWheelScrollView(
                          //scrollController: modScrollController,
                          itemExtent: itemExtent,
                          diameterRatio: diameterRatio,
                          squeeze: 1.1,
                          //perspective: 0.01,
                          overAndUnderCenterOpacity: 0.3,
                          children: <Widget>[
                            for (var i = 0;
                                i < controller.dinlenmeSuresi.length;
                                i++)
                              Text(
                                controller.dinlenmeSuresi[i].value,
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: curTextSize),
                              ),
                          ],
                          onSelectedItemChanged: (int index) {
                            //print(controller.modlar[index].value);
                            // controller.selectedMod.value = index;
                            // controller.selectedSeviye.value = index;
                            // controller.selectedModIc.value = 0;
                            //controller.selectedCalismaSur.value = index;
                            // controller.selectedAntrenmanSur.value = 0;
                            controller.selectedDinlenmeSur.value = index;
                          },
                          //looping: false,
                          // backgroundColor: Color(0xff2e3032),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 10,
                          width: 5,
                        ),
                      ),
                    ],
                  ),
                ),
                //Tamam buton
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () => {
                          modMessage = [
                            controller.selectedMod.value,
                            controller.selectedModIc.value,
                            controller.selectedAntrenmanSur.value,
                            controller.selectedSeviye.value,
                            controller.selectedCalismaSur.value,
                            controller.selectedDinlenmeSur.value
                          ],
                          controller.antrenmanScreen(
                              context, widget.kutular, modMessage),
                        },
                        child: Image.asset(
                          'assets/PNG/tamamButton.png',
                          height: Get.height / 2,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
