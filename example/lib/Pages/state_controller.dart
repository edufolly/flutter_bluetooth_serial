import 'package:get/get.dart';
import 'dart:async';

class StateController extends GetxController {
  var opacity = 0.2.obs;
  var isAllButtonsActivated = false;
  var playFlag = false.obs;

  var progressValue = 0.8.obs;
  var antTime = 20.obs;
  var calTime = 10.obs;
  var dinTime = 6.obs;
  var isLoading = false.obs;

  List buttonsContent = [
    0.obs,
    0.obs,
    0.obs,
    0.obs,
    0.obs,
    0.obs,
    0.obs,
    0.obs,
  ];

  List buttonsActivatedFlag = [
    false.obs,
    false.obs,
    false.obs,
    false.obs,
    false.obs,
    false.obs,
    false.obs,
    false.obs
  ];

  List kutuActivatedFlag = [
    false.obs,
    false.obs,
    false.obs,
    false.obs,
  ];

  void changeOpacity(double opacity) {
    this.opacity.value = opacity;
  }

  void arttir() {
    if (playFlag.value) {
      for (var v = 0; v < buttonsContent.length; v++) {
        if (buttonsActivatedFlag[v].value) {
          int intTemp = buttonsContent[v].value + 1;
          if (intTemp >= 0 && intTemp <= 100) {
            buttonsContent[v].value = intTemp;
          }
          // print("Button " +
          //     v.toString() +
          //     " content =" +
          //     buttonsContent[v].value.toString());
        }
      }
    }
  }

  void azalt() {
    if (playFlag.value) {
      for (var v = 0; v < buttonsContent.length; v++) {
        if (buttonsActivatedFlag[v].value) {
          int intTemp = buttonsContent[v].value - 1;
          if (intTemp >= 0 && intTemp <= 100) {
            buttonsContent[v].value = intTemp;
          }
          // print("Button " +
          //     v.toString() +
          //     " content =" +
          //     buttonsContent[v].value.toString());
        }
      }
    }
  }

  void doubleTapped() {
    if (playFlag.value) {
      for (var v = 0; v < buttonsActivatedFlag.length; v++) {
        buttonsActivatedFlag[v].value = !isAllButtonsActivated;
        // print("Button " +
        //     v.toString() +
        //     " state =" +
        //     buttonsActivatedFlag[v].toString());
      }
      isAllButtonsActivated = !isAllButtonsActivated;
    }
  }

//TODO Update proccessor methodu düzenlenecek şu anda öylesine bir gösteri çalışıyor.
//Sürelerle alaklı Hasanla konuşmam lazım. Büyük ihtimal bir önceki sayfada seçilen ayarlar
//buraya gelecek.
  void updateProgress() {
    const oneSec = const Duration(seconds: 1);

    new Timer.periodic(oneSec, (Timer t) {
      progressValue.value -= 0.1;
      // we "finish" downloading here
      if (progressValue <= 0.0) {
        isLoading.value = false;
        t.cancel();
        progressValue.value = 1;
        return;
      }
    });
  }
}
