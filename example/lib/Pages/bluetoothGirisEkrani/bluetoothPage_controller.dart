import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../mod/modSelect.dart';
import '../antrenman/antrenman_page.dart';
import 'dart:async';

class StateController1 extends GetxController {
  var isSwitched = false.obs;

  List kutuActivatedFlag = [
    false.obs,
    false.obs,
    false.obs,
    false.obs,
  ];

  void startChat(BuildContext context, List kutular) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return ModeSelect(kutular: kutular) /*ChatPage(server: server)*/;
        },
      ),
    );
  }

  read(String renk) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'my_' + renk + 'kutu_address';
    final value = prefs.getString(key) ?? "0";
    print('read: $value');
    return value;
  }

  save(String renk, String address) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'my_' + renk + 'kutu_address';
    final value = address;
    prefs.setString(key, value);
    print('saved $value');
  }
}
