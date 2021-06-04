import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../Pages/bluetoothGirisEkrani/bluetoothPage.dart';
import 'package:flutter_bluetooth_serial_example/Pages/terms_conditions_Controller.dart';

final controller = Get.put(StateControllerT());

class TermsConditionsPage extends StatefulWidget {
  @override
  _TermsConditionsPageState createState() => _TermsConditionsPageState();
}

class _TermsConditionsPageState extends State<TermsConditionsPage> {
  ScrollController _controller;

//SingleChildScrollView icine ekledigimiz controlleri dinliyoruz
  _scrollListener() {
    if (_controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange) {
      setState(
        () {
          print("reach the bottom");
          controller.tamamFlag.value = true;
        },
      );
    }
    if (_controller.offset <= _controller.position.minScrollExtent &&
        !_controller.position.outOfRange) {
      setState(() {
        // controller.tamamFlag.value = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
//SingleChildScrollView icine controller ekledik
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            // color: Colors.black,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/BackCover.jpg'), fit: BoxFit.cover),
              //shape: BoxShape.rectangle,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            child: Column(
              children: [
                Expanded(
                  flex: 8,
                  child: SingleChildScrollView(
                    controller: _controller,
                    child: Container(
                      color: Color(0xffbebebe),
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Text(
                                "EMS Elektro Kas Uyarım sistemleri yoğun ve derinlemesine kasların uyarılmasını sağlayan çok etkili ve başarılı sonuçlar aldıran sporlardan biridir. Tabi ki önemli bir noktada antrenman yoğunluğu yüksektir. Bu sebeple de sağlığımızın iyi durumda olması gerekmektedir.\n\n1) Kalp de oluşabilecek riskler:\n     - Kalp damar hastalığı \n     - Kan dolaşım sorunları\n     - Yüksek tansiyon\n     - Kalp pili\n     - İç defibrilatör\n     - Bypass \n     - Kalp enfarktüsü\n     - Arteroskleroz\n     - Anjina pektoris\n     - Hasta sinüs sendromu\n     - Karotissinus sendromu \n\n2) Cilt de oluşabilecek riskler:\n     - Nörodermatit \n     - Psoriasis\n     - Genel cilt kuruluğu\n     - Elektrotların altında veya yakınında açık cilt yaraları, egzama, güneş yanığı vb. \n\n3) Metabolizma için riskler:\n     - Şeker hastalığı \n     - Safra kesesi veya böbrek taşları,\n\n 4) İmplantlar için riskler:\n     - Metal implantlar\n     - Elektrotların yakın piercing \n\n5) Nöroloji için riskler:\n     - Sara\n     - Parkinson hastalığı \n     - Multipl skleroz\n     - Amyotropik yan skleroz\n     - Spastik omurilik felci\n     - Şiddetli migren\n     - Aiyotiupin yaii SNICIUL\n     - Spastik omurilik felci\n     - Şiddetli migren\n     - Dezoryantasyon \n\n6) Kanamalardan kaynaklı sorunlar: \n     - Hemofili (kanama eğilimi)\n     - Kan akış bozuklukları (dolaşım bozuklukları) \n     - İç/Dış Kanamalar\n     - Trombozlar\n\n 7) Dahiliye için riskler:\n     - Tümör\n     - Kanser sorunları Son altı ay içinde ameliyat İnme Lenf ödem \n     - Akut iltihap \n     - Bacak damarları, varikoz damarları etrafında iltihap Vücut boşluklarına akıntı, örnek: plevra efluksiyonu, karında sıvı birikimi ateş\n\n8)Hamilelik ilgili sorunlar:\n     • Mevcut gebelik Spiral (takıldıktan sonra 6-8 hafta) \n\n9) Ortopedik sorunlar: \n     - Ortopedik sıkıntılar\n     - Spor etkinliklerini engelleyen hastalıklar\n     - Romatizmalı hastalıklar\n     - (Eklem) gut\n     - Osteoporoz\n     - Progrefis muskular distrofi \n     - Tendinopati (tendon hastalığı)\n     - Spinal disk sendromu\n     - Disk kayması \n     - Kırıklar\n\n 10) Diğer sorunlar: \n     - Alkol etkisi \n     - Uyuşturucu etkisi\n     - Elektrik anksiyetesi\n\nAntrenmana devam etmek isterseniz yukarıdaki açıklamaları anladığınızı, oluşabilecek risk ve hastalıkların hiçbirinin sizinle ilgili olmadığını, ayrıca emin olamadığınız durumlar için tıbbi destek aldığınızı kabul etmenizi istiyoruz.",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // RaisedButton(
                        //   child: Text("Geri"),
                        //   onPressed: () => SystemChannels.platform
                        //       .invokeMethod('SystemNavigator.pop'),
                        // ),
                        // Geri Button uygulamayi kapatiyor.
                        GestureDetector(
                          onTap: () => SystemChannels.platform
                              .invokeMethod('SystemNavigator.pop'),
                          child: Stack(
                            children: [
                              Image.asset(
                                'assets/PNG/TibbiYazi/tamam_buton.png',
                                height: Get.height / 10,
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 65, top: 18),
                                child: Text(
                                  "Geri",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: Get.height / 20),
                                ),
                              ),
                            ],
                          ),
                        ),

                        //Tamam Button
                        GestureDetector(
                          onTap: () => controller.tamamFlag.value
                              ? bluetoothScreen(context)
                              : print("Oku pic!!"),
                          child: Stack(
                            children: [
                              Image.asset(
                                'assets/PNG/TibbiYazi/tamam_buton.png',
                                height: Get.height / 10,
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 40, top: 18),
                                child: Opacity(
                                  opacity:
                                      controller.tamamFlag.value ? 1.0 : 0.30,
                                  child: Text(
                                    "Tamam",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: Get.height / 20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // RaisedButton(
                        //   child: Text("Tamam"),
                        //   onPressed: () => {
                        //     print(""),
                        //     bluetoothScreen(context),
                        //   },
                        // ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void bluetoothScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return BluetoothPage() /*ChatPage(server: server)*/;
        },
      ),
    );
  }
}
