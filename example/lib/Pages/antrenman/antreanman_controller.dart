import 'package:get/get.dart';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class StateController extends GetxController {
  var opacity = 0.2.obs;
  var isAllButtonsActivated = false;
  var playFlag = false.obs;

  var progressValueDin = 0.0.obs;
  var progressValueAnt = 1.0.obs;
  var progressValueCal = 1.0.obs;
  var antTime = 20.obs;
  var calTime = 10.obs;
  var dinTime = 6.obs;
  var isInProgress = false.obs;

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
  List antrenmanSuresi = [
    [10.obs, 15.obs, 20.obs, 25.obs, 30.obs],
    [15.obs, 20.obs, 25.obs, 30.obs],
    [15.obs, 20.obs, 25.obs, 30.obs, 40.obs],
    [15.obs, 20.obs, 25.obs, 30.obs],
    [5.obs, 10.obs],
    [15.obs, 20.obs, 25.obs, 30.obs]
  ];
  List calismaDinlenmeSuresi = [
    1.obs,
    2.obs,
    3.obs,
    4.obs,
    5.obs,
    6.obs,
    7.obs,
    8.obs,
    9.obs,
    10.obs,
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
  // void updateProgress() {
  //   const oneSec = const Duration(seconds: 1);
  //   const oneMin = const Duration(minutes: 1);

  //   new Timer.periodic(oneSec, (Timer t) {
  //     if (!playFlag.value) {
  //       t.cancel();
  //       return;
  //     }
  //     progressValueDin.value -= 0.1;
  //     // we "finish" downloading here
  //     if (progressValueDin <= 0.0) {
  //       //isLoading.value = false;
  //       t.cancel();
  //       progressValueDin.value = 1;
  //       //TODO Antrenman bittikten sonra play butonu başlangıc durumuna getirmek adına aşagıdaki
  //       //kodu düzenleyecegim
  //       //playFlag.value = false;
  //       return;
  //     }
  //   });
  // }

  void updateProgressAntrenmanSuresi(int antSuresi) {
    const oneMin = const Duration(minutes: 1);
    isInProgress = true.obs;

    new Timer.periodic(oneMin, (Timer t) {
      if (!playFlag.value) {
        t.cancel();
        return;
      }
      progressValueAnt.value -= 1 / antSuresi;
      // we "finish" downloading here
      if (progressValueAnt <= 0.0) {
        isInProgress.value = false;
        t.cancel();
        progressValueAnt.value = 1;
        //TODO Antrenman bittikten sonra play butonu başlangıc durumuna getirmek adına aşagıdaki
        //kodu düzenleyecegim
        playFlag.value = false;
        return;
      }
    });
  }

  void updateProgressCal(int calSuresi, int dinSuresi) {
    const oneSec = const Duration(seconds: 1);

    new Timer.periodic(oneSec, (Timer t) {
      if (!playFlag.value) {
        t.cancel();
        return;
      }
      progressValueCal.value -= 1 / calSuresi;
      // we "finish" downloading here
      if (progressValueCal.value <= 0.0) {
        //isLoading.value = false;

        progressValueDin.value = 1.0;
        //TODO Antrenman bittikten sonra play butonu başlangıc durumuna getirmek adına aşagıdaki
        //kodu düzenleyecegim
        //playFlag.value = false;
        if (isInProgress.value) {
          updateProgressDin(calSuresi, dinSuresi);
        }
        t.cancel();
        return;
      }
    });
  }

  void updateProgressDin(int calSuresi, int dinSuresi) {
    const oneSec = const Duration(seconds: 1);
    //progressValueDin.value = 1.0;

    new Timer.periodic(oneSec, (Timer t) {
      if (!playFlag.value) {
        t.cancel();
        return;
      }
      progressValueDin.value -= 1 / dinSuresi;
      // we "finish" downloading here
      if (progressValueDin.value <= 0.0) {
        //isLoading.value = false;

        progressValueCal.value = 1.0;
        //TODO Antrenman bittikten sonra play butonu başlangıc durumuna getirmek adına aşagıdaki
        //kodu düzenleyecegim
        //playFlag.value = false;
        if (isInProgress.value) {
          updateProgressCal(calSuresi, dinSuresi);
        }
        t.cancel();
        return;
      }
    });
  }

  read(String renk) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'my_' + renk + 'kutu_address';
    final value = prefs.getString(key) ?? "0";
    print('read: $value');
    return value;
  }
}
