import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import '../antrenman/antrenman_page.dart';
import 'dart:async';

class StateControllerMode extends GetxController {
  var selectedMod = 0.obs, selectedSeviye = 0.obs;
  var selectedModIc = 0.obs, selectedCalismaSur = 0.obs;
  var selectedAntrenmanSur = 0.obs, selectedDinlenmeSur = 0.obs;
  List modlar = [
    'Başlangıç'.obs,
    'Dayanıklılık'.obs,
    'Kuvvet'.obs,
    'Yağ Yakımı'.obs,
    'Dinlenme'.obs,
    'Özel'.obs
  ];
  List seviye = ['Kolay'.obs, 'Normal'.obs, 'Zor'.obs];

  List calismaSuresi = [
    '1 Sn'.obs,
    '2 Sn'.obs,
    '3 Sn'.obs,
    '4 Sn'.obs,
    '5 Sn'.obs,
    '6 Sn'.obs,
    '7 Sn'.obs,
    '8 Sn'.obs,
    '9 Sn'.obs,
    '10 Sn'.obs,
  ];
  List antrenmanSuresi = [
    ['10 Dk'.obs, '15 Dk'.obs, '20 Dk'.obs, '25 Dk'.obs, '30 Dk'.obs],
    ['15 Dk'.obs, '20 Dk'.obs, '25 Dk'.obs, '30 Dk'.obs],
    ['15 Dk'.obs, '20 Dk'.obs, '25 Dk'.obs, '30 Dk'.obs, '40 Dk'.obs],
    ['15 Dk'.obs, '20 Dk'.obs, '25 Dk'.obs, '30 Dk'.obs],
    ['5 Dk'.obs, '10 Dk'.obs],
    ['15 Dk'.obs, '20 Dk'.obs, '25 Dk'.obs, '30 Dk'.obs]
  ];
  List dinlenmeSuresi = [
    '1 Sn'.obs,
    '2 Sn'.obs,
    '3 Sn'.obs,
    '4 Sn'.obs,
    '5 Sn'.obs,
    '6 Sn'.obs,
    '7 Sn'.obs,
    '8 Sn'.obs,
    '9 Sn'.obs,
    '10 Sn'.obs,
  ];

  List modIcerigi = [
    [
      'Başlangıç - 1'.obs,
      'Başlangıç - 2'.obs,
      'Başlangıç - 3'.obs,
      'Süreklilik - 1'.obs,
      'Süreklilik - 2'.obs
    ],
    ['Dayanıklılık - 1'.obs, 'Dayanıklılık - 2'.obs, 'Dayanıklılık - 3'.obs],
    ['Kuvvet - 1'.obs, 'Kuvvet - 2'.obs],
    ['Yağ Yakımı - 1'.obs, 'Yağ Yakımı - 2'.obs],
    ['Dinlenme - 1'.obs, 'Dinlenme - 2'.obs],
    ['Masaj'.obs, 'Selülit Önleyici'.obs]
  ];

  void antrenmanScreen(BuildContext context, List kutular, List modMessage) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return ChatPage(kutular: kutular, modMessage: modMessage);
        },
      ),
    );
  }
}
