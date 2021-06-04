import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

import '../src/CustomButton.dart';

// Scaffold(
//         // appBar: AppBar(title: Text('Set Full Screen Background Image')),
//         body: Center(
//           child: Container(
//             constraints: BoxConstraints.expand(),
//             decoration: BoxDecoration(
//                 image: DecorationImage(
//                     image: AssetImage('assets/jpg/ana_ekran.jpg'),
//                     fit: BoxFit.cover)),
//           ),
//         ),
//       ),
//
List buttonsContent = [
  ValueNotifier<String>("0"),
  ValueNotifier<String>("0"),
  ValueNotifier<String>("0"),
  ValueNotifier<String>("0"),
  ValueNotifier<String>("0"),
  ValueNotifier<String>("0"),
  ValueNotifier<String>("0"),
  ValueNotifier<String>("0")
];
List buttonsActivatedFlag = [
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false
];
List kutuActivatedFlag = [false, false, false, false];

bool isAllButtonsActivated = false;
bool playFlag = true;

final aktifAntrenmanCikis = ValueNotifier<bool>(false);

class AntrenmanEkrani extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/BackCover.jpg'), fit: BoxFit.cover),
          //shape: BoxShape.rectangle,
        ),
        // color: Colors.yellow,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // left first Column
            Expanded(
              flex: 15,
              child: Container(
                child: Column(
                  children: <Widget>[
                    Expanded(flex: 11, child: Container()),
                    Expanded(
                        flex: 1,
                        child: Container(
                            child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Container(
                                alignment: Alignment.bottomCenter,
                                child: AntrenmanExit(),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Container(),
                            ),
                          ],
                        ))),
                  ],
                ),
              ),
            ),
            //Left Buttons Column
            Expanded(
              flex: 15,
              child: Column(
                children: <Widget>[
                  Expanded(
                    flex: 2, // 20%
                    child: Container(/*color: Colors.red*/),
                  ),
                  Expanded(
                    flex: 6, // 60%
                    child: Container(
                      child: Column(
                        children: [
                          new BoyunButton(),
                          new GogusButton(),
                          new SirtButton(),
                          new BelButton()
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2, // 20%
                    child: Container(/*color: Colors.blue*/),
                  )
                ],
              ),
            ),
            //Mid Column
            Expanded(
              flex: 40,
              child: Column(
                children: <Widget>[
                  //Kutular
                  Expanded(
                    flex: 2, // 20%
                    child: Container(
                        child: Row(
                      children: [
                        new Kutu1(),
                        new Kutu1(),
                        new Kutu1(),
                        new Kutu1()
                      ],
                    )),
                  ),
                  //Vucud bolgeleri ve barlar
                  Expanded(
                    flex: 5, // 60%
                    child: Container(
                      child: Row(
                        children: [
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
                              child: Container(
                                child: Column(
                                  children: [
                                    LinearProgressIndicatorApp(),
                                    LinearProgressIndicatorApp(),
                                    LinearProgressIndicatorApp(),
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
                  ),
                  //Play and increase/decrease Buttons
                  Expanded(
                    flex: 2, // 20%
                    child: Container(
                      child: Row(
                        children: [
                          Expanded(flex: 1, child: Container()),
                          Expanded(
                            flex: 4,
                            child: Container(child: EksiButton()),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                Expanded(flex: 1, child: Container()),
                                Expanded(
                                    flex: 100,
                                    child: Container(
                                      child: PlayButton(),
                                    )),
                                Expanded(
                                  flex: 1,
                                  child: Container(),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Container(child: ArtiButton()),
                          ),
                          Expanded(flex: 1, child: Container()),
                        ],
                      ),
                    ),
                  ),
                  Expanded(flex: 1, child: Container())
                ],
              ),
            ),
            //Right buttons Column
            Expanded(
              flex: 15,
              child: Column(
                children: <Widget>[
                  Expanded(
                    flex: 2, // 20%
                    child: Container(/*color: Colors.red*/),
                  ),
                  Expanded(
                    flex: 6, // 60%
                    child: Container(
                      child: Column(
                        children: [
                          new KollarButton(),
                          new KarinButton(),
                          new KalcaButton(),
                          new BacaklarButton()
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2, // 20%
                    child: Container(/*color: Colors.blue*/),
                  )
                ],
              ),
            ),
            // En sag kolon
            Expanded(
              flex: 15,
              child: Container(
                child: Column(
                  children: <Widget>[
                    Expanded(flex: 11, child: Container()),
                    Expanded(
                        flex: 1,
                        child: Container(
                            child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(),
                            ),
                            Expanded(
                                flex: 1,
                                child: Container(
                                    alignment: Alignment.bottomCenter,
                                    child: CrossExit()))
                          ],
                        ))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BoyunButton extends StatefulWidget {
  @override
  _BoyunButtonState createState() => _BoyunButtonState();
}

class _BoyunButtonState extends State<BoyunButton> {
  int buttonIndex = 0; //Boyun
  String buttonName = "boyun";
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
          child: ConstrainedBox(
              constraints: BoxConstraints.expand(),
              child: GestureDetector(
                //onTap: () {},
                onDoubleTap: () {
                  print('onDoubleTap');
                  setState(() {
                    if (!playFlag) {
                      for (var v = 0; v < buttonsActivatedFlag.length; v++) {
                        buttonsActivatedFlag[v] = !isAllButtonsActivated;
                        print("Button " +
                            v.toString() +
                            " state =" +
                            buttonsActivatedFlag[v].toString());
                      }
                      isAllButtonsActivated = !isAllButtonsActivated;
                    }
                  });
                  Feedback.forTap(context);
                },
                child: FlatButton(
                    onPressed: () {
                      print('onTap');

                      setState(() {
                        if (!playFlag) {
                          buttonsActivatedFlag[buttonIndex] =
                              !buttonsActivatedFlag[buttonIndex];
                          print("Button " +
                              buttonIndex.toString() +
                              " state =" +
                              buttonsActivatedFlag[buttonIndex].toString());
                        }
                      });
                      Feedback.forTap(context);
                    },
                    padding: EdgeInsets.all(0.0),
                    child:
                        Stack(alignment: Alignment(0, -0.5), children: <Widget>[
                      ValueListenableBuilder(
                        valueListenable: aktifAntrenmanCikis,
                        builder: (context, value, widget) {
                          return Opacity(
                            opacity: aktifAntrenmanCikis.value ? 1.0 : 0.25,
                            child: Image.asset(
                                'assets/PNG/AntrenmanEkraniAktif/vucudYuvalakButton.png'),
                          );
                        },
                      ),
                      // Image.asset('assets/PNG/AntrenmanEkraniAktif/vucudYuvalakButton.png'
                      //       ),
                      Text(
                        buttonName,
                        style: TextStyle(
                            color: Colors.white,
                            // fontWeight: FontWeight.bold,
                            fontSize: 7.0),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: ValueListenableBuilder(
                          valueListenable: buttonsContent[buttonIndex],
                          builder: (context, value, widget) {
                            return Text(
                              buttonsContent[buttonIndex].value,
                              style: TextStyle(
                                  color: Colors.white,
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 14.0),
                            );
                          },
                        ),
                      )
                    ])),
              ))),
    );
  }
}

class GogusButton extends StatefulWidget {
  @override
  _GogusButtonState createState() => _GogusButtonState();
}

class _GogusButtonState extends State<GogusButton> {
  int buttonIndex = 1; //Boyun
  String buttonName = "göğüs";
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
          child: ConstrainedBox(
              constraints: BoxConstraints.expand(),
              child: GestureDetector(
                //onTap: () {},
                onDoubleTap: () {
                  print('onDoubleTap');
                  setState(() {
                    if (!playFlag) {
                      for (var v = 0; v < buttonsActivatedFlag.length; v++) {
                        buttonsActivatedFlag[v] = !isAllButtonsActivated;
                        print("Button " +
                            v.toString() +
                            " state =" +
                            buttonsActivatedFlag[v].toString());
                      }
                      isAllButtonsActivated = !isAllButtonsActivated;
                    }
                  });
                  Feedback.forTap(context);
                },
                child: FlatButton(
                    onPressed: () {
                      print('onTap');

                      setState(() {
                        if (!playFlag) {
                          buttonsActivatedFlag[buttonIndex] =
                              !buttonsActivatedFlag[buttonIndex];
                          print("Button " +
                              buttonIndex.toString() +
                              " state =" +
                              buttonsActivatedFlag[buttonIndex].toString());
                        }
                      });
                      Feedback.forTap(context);
                    },
                    padding: EdgeInsets.all(0.0),
                    child:
                        Stack(alignment: Alignment(0, -0.5), children: <Widget>[
                      ValueListenableBuilder(
                        valueListenable: aktifAntrenmanCikis,
                        builder: (context, value, widget) {
                          return Opacity(
                            opacity: aktifAntrenmanCikis.value ? 1.0 : 0.25,
                            child: Image.asset(
                                'assets/PNG/AntrenmanEkraniAktif/vucudYuvalakButton.png'),
                          );
                        },
                      ),
                      // Image.asset('assets/PNG/AntrenmanEkraniAktif/vucudYuvalakButton.png'
                      //       ),
                      Text(
                        buttonName,
                        style: TextStyle(
                            color: Colors.white,
                            // fontWeight: FontWeight.bold,
                            fontSize: 7.0),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: ValueListenableBuilder(
                          valueListenable: buttonsContent[buttonIndex],
                          builder: (context, value, widget) {
                            return Text(
                              buttonsContent[buttonIndex].value,
                              style: TextStyle(
                                  color: Colors.white,
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 14.0),
                            );
                          },
                        ),
                      )
                    ])),
              ))),
    );
  }
}

class SirtButton extends StatefulWidget {
  @override
  _SirtButtonState createState() => _SirtButtonState();
}

class _SirtButtonState extends State<SirtButton> {
  int buttonIndex = 2; //Boyun
  String buttonName = "sırt";
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
          child: ConstrainedBox(
              constraints: BoxConstraints.expand(),
              child: GestureDetector(
                //onTap: () {},
                onDoubleTap: () {
                  print('onDoubleTap');
                  setState(() {
                    if (!playFlag) {
                      for (var v = 0; v < buttonsActivatedFlag.length; v++) {
                        buttonsActivatedFlag[v] = !isAllButtonsActivated;
                        print("Button " +
                            v.toString() +
                            " state =" +
                            buttonsActivatedFlag[v].toString());
                      }
                      isAllButtonsActivated = !isAllButtonsActivated;
                    }
                  });
                  Feedback.forTap(context);
                },
                child: FlatButton(
                    onPressed: () {
                      print('onTap');

                      setState(() {
                        if (!playFlag) {
                          buttonsActivatedFlag[buttonIndex] =
                              !buttonsActivatedFlag[buttonIndex];
                          print("Button " +
                              buttonIndex.toString() +
                              " state =" +
                              buttonsActivatedFlag[buttonIndex].toString());
                        }
                      });
                      Feedback.forTap(context);
                    },
                    padding: EdgeInsets.all(0.0),
                    child:
                        Stack(alignment: Alignment(0, -0.5), children: <Widget>[
                      ValueListenableBuilder(
                        valueListenable: aktifAntrenmanCikis,
                        builder: (context, value, widget) {
                          return Opacity(
                            opacity: aktifAntrenmanCikis.value ? 1.0 : 0.25,
                            child: Image.asset(
                                'assets/PNG/AntrenmanEkraniAktif/vucudYuvalakButton.png'),
                          );
                        },
                      ),
                      // Image.asset('assets/PNG/AntrenmanEkraniAktif/vucudYuvalakButton.png'
                      //       ),
                      Text(
                        buttonName,
                        style: TextStyle(
                            color: Colors.white,
                            // fontWeight: FontWeight.bold,
                            fontSize: 7.0),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: ValueListenableBuilder(
                          valueListenable: buttonsContent[buttonIndex],
                          builder: (context, value, widget) {
                            return Text(
                              buttonsContent[buttonIndex].value,
                              style: TextStyle(
                                  color: Colors.white,
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 14.0),
                            );
                          },
                        ),
                      )
                    ])),
              ))),
    );
  }
}

class BelButton extends StatefulWidget {
  @override
  _BelButtonState createState() => _BelButtonState();
}

class _BelButtonState extends State<BelButton> {
  int buttonIndex = 3; //Boyun
  String buttonName = "bel";
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
          child: ConstrainedBox(
              constraints: BoxConstraints.expand(),
              child: GestureDetector(
                //onTap: () {},
                onDoubleTap: () {
                  print('onDoubleTap');
                  setState(() {
                    if (!playFlag) {
                      for (var v = 0; v < buttonsActivatedFlag.length; v++) {
                        buttonsActivatedFlag[v] = !isAllButtonsActivated;
                        print("Button " +
                            v.toString() +
                            " state =" +
                            buttonsActivatedFlag[v].toString());
                      }
                      isAllButtonsActivated = !isAllButtonsActivated;
                    }
                  });
                  Feedback.forTap(context);
                },
                child: FlatButton(
                    onPressed: () {
                      print('onTap');

                      setState(() {
                        if (!playFlag) {
                          buttonsActivatedFlag[buttonIndex] =
                              !buttonsActivatedFlag[buttonIndex];
                          print("Button " +
                              buttonIndex.toString() +
                              " state =" +
                              buttonsActivatedFlag[buttonIndex].toString());
                        }
                      });
                      Feedback.forTap(context);
                    },
                    padding: EdgeInsets.all(0.0),
                    child:
                        Stack(alignment: Alignment(0, -0.5), children: <Widget>[
                      ValueListenableBuilder(
                        valueListenable: aktifAntrenmanCikis,
                        builder: (context, value, widget) {
                          return Opacity(
                            opacity: aktifAntrenmanCikis.value ? 1.0 : 0.25,
                            child: Image.asset(
                                'assets/PNG/AntrenmanEkraniAktif/vucudYuvalakButton.png'),
                          );
                        },
                      ),
                      // Image.asset('assets/PNG/AntrenmanEkraniAktif/vucudYuvalakButton.png'
                      //       ),
                      Text(
                        buttonName,
                        style: TextStyle(
                            color: Colors.white,
                            // fontWeight: FontWeight.bold,
                            fontSize: 7.0),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: ValueListenableBuilder(
                          valueListenable: buttonsContent[buttonIndex],
                          builder: (context, value, widget) {
                            return Text(
                              buttonsContent[buttonIndex].value,
                              style: TextStyle(
                                  color: Colors.white,
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 14.0),
                            );
                          },
                        ),
                      )
                    ])),
              ))),
    );
  }
}

class KollarButton extends StatefulWidget {
  @override
  _KollarButtonState createState() => _KollarButtonState();
}

class _KollarButtonState extends State<KollarButton> {
  int buttonIndex = 4; //Boyun
  String buttonName = "kollar";
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
          child: ConstrainedBox(
              constraints: BoxConstraints.expand(),
              child: GestureDetector(
                //onTap: () {},
                onDoubleTap: () {
                  print('onDoubleTap');
                  setState(() {
                    if (!playFlag) {
                      for (var v = 0; v < buttonsActivatedFlag.length; v++) {
                        buttonsActivatedFlag[v] = !isAllButtonsActivated;
                        print("Button " +
                            v.toString() +
                            " state =" +
                            buttonsActivatedFlag[v].toString());
                      }
                      isAllButtonsActivated = !isAllButtonsActivated;
                    }
                  });
                  Feedback.forTap(context);
                },
                child: FlatButton(
                    onPressed: () {
                      print('onTap');

                      setState(() {
                        if (!playFlag) {
                          buttonsActivatedFlag[buttonIndex] =
                              !buttonsActivatedFlag[buttonIndex];
                          print("Button " +
                              buttonIndex.toString() +
                              " state =" +
                              buttonsActivatedFlag[buttonIndex].toString());
                        }
                      });
                      Feedback.forTap(context);
                    },
                    padding: EdgeInsets.all(0.0),
                    child:
                        Stack(alignment: Alignment(0, -0.5), children: <Widget>[
                      ValueListenableBuilder(
                        valueListenable: aktifAntrenmanCikis,
                        builder: (context, value, widget) {
                          return Opacity(
                            opacity: aktifAntrenmanCikis.value ? 1.0 : 0.25,
                            child: Image.asset(
                                'assets/PNG/AntrenmanEkraniAktif/vucudYuvalakButton.png'),
                          );
                        },
                      ),
                      // Image.asset('assets/PNG/AntrenmanEkraniAktif/vucudYuvalakButton.png'
                      //       ),
                      Text(
                        buttonName,
                        style: TextStyle(
                            color: Colors.white,
                            // fontWeight: FontWeight.bold,
                            fontSize: 7.0),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: ValueListenableBuilder(
                          valueListenable: buttonsContent[buttonIndex],
                          builder: (context, value, widget) {
                            return Text(
                              buttonsContent[buttonIndex].value,
                              style: TextStyle(
                                  color: Colors.white,
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 14.0),
                            );
                          },
                        ),
                      )
                    ])),
              ))),
    );
  }
}

class KarinButton extends StatefulWidget {
  @override
  _KarinButtonState createState() => _KarinButtonState();
}

class _KarinButtonState extends State<KarinButton> {
  int buttonIndex = 5; //Boyun
  String buttonName = "karın";
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
          child: ConstrainedBox(
              constraints: BoxConstraints.expand(),
              child: GestureDetector(
                //onTap: () {},
                onDoubleTap: () {
                  print('onDoubleTap');
                  setState(() {
                    if (!playFlag) {
                      for (var v = 0; v < buttonsActivatedFlag.length; v++) {
                        buttonsActivatedFlag[v] = !isAllButtonsActivated;
                        print("Button " +
                            v.toString() +
                            " state =" +
                            buttonsActivatedFlag[v].toString());
                      }
                      isAllButtonsActivated = !isAllButtonsActivated;
                    }
                  });
                  Feedback.forTap(context);
                },
                child: FlatButton(
                    onPressed: () {
                      print('onTap');

                      setState(() {
                        if (!playFlag) {
                          buttonsActivatedFlag[buttonIndex] =
                              !buttonsActivatedFlag[buttonIndex];
                          print("Button " +
                              buttonIndex.toString() +
                              " state =" +
                              buttonsActivatedFlag[buttonIndex].toString());
                        }
                      });
                      Feedback.forTap(context);
                    },
                    padding: EdgeInsets.all(0.0),
                    child:
                        Stack(alignment: Alignment(0, -0.5), children: <Widget>[
                      ValueListenableBuilder(
                        valueListenable: aktifAntrenmanCikis,
                        builder: (context, value, widget) {
                          return Opacity(
                            opacity: aktifAntrenmanCikis.value ? 1.0 : 0.25,
                            child: Image.asset(
                                'assets/PNG/AntrenmanEkraniAktif/vucudYuvalakButton.png'),
                          );
                        },
                      ),
                      // Image.asset('assets/PNG/AntrenmanEkraniAktif/vucudYuvalakButton.png'
                      //       ),
                      Text(
                        buttonName,
                        style: TextStyle(
                            color: Colors.white,
                            // fontWeight: FontWeight.bold,
                            fontSize: 7.0),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: ValueListenableBuilder(
                          valueListenable: buttonsContent[buttonIndex],
                          builder: (context, value, widget) {
                            return Text(
                              buttonsContent[buttonIndex].value,
                              style: TextStyle(
                                  color: Colors.white,
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 14.0),
                            );
                          },
                        ),
                      )
                    ])),
              ))),
    );
  }
}

class KalcaButton extends StatefulWidget {
  @override
  _KalcaButtonState createState() => _KalcaButtonState();
}

class _KalcaButtonState extends State<KalcaButton> {
  int buttonIndex = 6; //Boyun
  String buttonName = "kalça";
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
          child: ConstrainedBox(
              constraints: BoxConstraints.expand(),
              child: GestureDetector(
                //onTap: () {},
                onDoubleTap: () {
                  print('onDoubleTap');
                  setState(() {
                    if (!playFlag) {
                      for (var v = 0; v < buttonsActivatedFlag.length; v++) {
                        buttonsActivatedFlag[v] = !isAllButtonsActivated;
                        print("Button " +
                            v.toString() +
                            " state =" +
                            buttonsActivatedFlag[v].toString());
                      }
                      isAllButtonsActivated = !isAllButtonsActivated;
                    }
                  });
                  Feedback.forTap(context);
                },
                child: FlatButton(
                    onPressed: () {
                      print('onTap');

                      setState(() {
                        if (!playFlag) {
                          buttonsActivatedFlag[buttonIndex] =
                              !buttonsActivatedFlag[buttonIndex];
                          print("Button " +
                              buttonIndex.toString() +
                              " state =" +
                              buttonsActivatedFlag[buttonIndex].toString());
                        }
                      });
                      Feedback.forTap(context);
                    },
                    padding: EdgeInsets.all(0.0),
                    child:
                        Stack(alignment: Alignment(0, -0.5), children: <Widget>[
                      ValueListenableBuilder(
                        valueListenable: aktifAntrenmanCikis,
                        builder: (context, value, widget) {
                          return Opacity(
                            opacity: aktifAntrenmanCikis.value ? 1.0 : 0.25,
                            child: Image.asset(
                                'assets/PNG/AntrenmanEkraniAktif/vucudYuvalakButton.png'),
                          );
                        },
                      ),
                      // Image.asset('assets/PNG/AntrenmanEkraniAktif/vucudYuvalakButton.png'
                      //       ),
                      Text(
                        buttonName,
                        style: TextStyle(
                            color: Colors.white,
                            // fontWeight: FontWeight.bold,
                            fontSize: 7.0),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: ValueListenableBuilder(
                          valueListenable: buttonsContent[buttonIndex],
                          builder: (context, value, widget) {
                            return Text(
                              buttonsContent[buttonIndex].value,
                              style: TextStyle(
                                  color: Colors.white,
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 14.0),
                            );
                          },
                        ),
                      )
                    ])),
              ))),
    );
  }
}

class BacaklarButton extends StatefulWidget {
  @override
  _BacaklarButtonState createState() => _BacaklarButtonState();
}

class _BacaklarButtonState extends State<BacaklarButton> {
  int buttonIndex = 7; //Boyun
  String buttonName = "bacaklar";
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
          child: ConstrainedBox(
              constraints: BoxConstraints.expand(),
              child: GestureDetector(
                //onTap: () {},
                onDoubleTap: () {
                  print('onDoubleTap');
                  setState(() {
                    if (!playFlag) {
                      for (var v = 0; v < buttonsActivatedFlag.length; v++) {
                        buttonsActivatedFlag[v] = !isAllButtonsActivated;
                        print("Button " +
                            v.toString() +
                            " state =" +
                            buttonsActivatedFlag[v].toString());
                      }
                      isAllButtonsActivated = !isAllButtonsActivated;
                    }
                  });
                  Feedback.forTap(context);
                },
                child: FlatButton(
                    onPressed: () {
                      print('onTap');

                      setState(() {
                        if (!playFlag) {
                          buttonsActivatedFlag[buttonIndex] =
                              !buttonsActivatedFlag[buttonIndex];
                          print("Button " +
                              buttonIndex.toString() +
                              " state =" +
                              buttonsActivatedFlag[buttonIndex].toString());
                        }
                      });
                      Feedback.forTap(context);
                    },
                    padding: EdgeInsets.all(0.0),
                    child:
                        Stack(alignment: Alignment(0, -0.5), children: <Widget>[
                      ValueListenableBuilder(
                        valueListenable: aktifAntrenmanCikis,
                        builder: (context, value, widget) {
                          return Opacity(
                            opacity: aktifAntrenmanCikis.value ? 1.0 : 0.25,
                            child: Image.asset(
                                'assets/PNG/AntrenmanEkraniAktif/vucudYuvalakButton.png'),
                          );
                        },
                      ),
                      // Image.asset('assets/PNG/AntrenmanEkraniAktif/vucudYuvalakButton.png'
                      //       ),
                      Text(
                        buttonName,
                        style: TextStyle(
                            color: Colors.white,
                            // fontWeight: FontWeight.bold,
                            fontSize: 7.0),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: ValueListenableBuilder(
                          valueListenable: buttonsContent[buttonIndex],
                          builder: (context, value, widget) {
                            return Text(
                              buttonsContent[buttonIndex].value,
                              style: TextStyle(
                                  color: Colors.white,
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 14.0),
                            );
                          },
                        ),
                      )
                    ])),
              ))),
    );
  }
}

class Kutu1 extends StatefulWidget {
  @override
  _KutuState createState() => _KutuState();
}

class _KutuState extends State<Kutu1> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
          child: ConstrainedBox(
              constraints: BoxConstraints.expand(),
              child: FlatButton(
                  onPressed: () {
                    print(buttonsContent[2].value);
                    int a = int.parse(buttonsContent[2].value) + 1;

                    setState(() {
                      kutuActivatedFlag[0] = !kutuActivatedFlag[0];
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

class LinearProgressIndicatorApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LinearProgressIndicatorAppState();
  }
}

class LinearProgressIndicatorAppState
    extends State<LinearProgressIndicatorApp> {
  bool _loading = false;
  double _progressValue = 100;

  @override
  void initState() {
    super.initState();
    _loading = true;
    _progressValue = 1.0;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
          padding: EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Text(
                  'ANTRENMAN SURESİ',
                  style: TextStyle(color: Colors.white, fontSize: 8.0),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${(_progressValue * 100).round()} dk',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 8.0)),
                  Text('${(_progressValue * 100).round()} dk',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 8.0)),
                ],
              ),
              LinearProgressIndicator(
                backgroundColor: Colors.cyanAccent,
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.orange),
                value: _progressValue,
              ),
            ],
          )),

      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     setState(() {
      //       _loading = !_loading;
      //       _updateProgress();
      //     });
      //   },
      //   tooltip: 'Download',
      //   child: Icon(Icons.cloud_download),
      // ),
      //
    );
  }

  // this function updates the progress value
  void _updateProgress() {
    const oneSec = const Duration(seconds: 1);
    new Timer.periodic(oneSec, (Timer t) {
      setState(() {
        _progressValue -= 0.1;
        // we "finish" downloading here
        if (_progressValue <= 0.0) {
          _loading = false;
          t.cancel();
          _progressValue = 1;
          return;
        }
      });
    });
  }
}

class AntrenmanExit extends StatefulWidget {
  @override
  _AntrenmanExitState createState() => _AntrenmanExitState();
}

class _AntrenmanExitState extends State<AntrenmanExit> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        child: ConstrainedBox(
          constraints: BoxConstraints.expand(),
          child: FlatButton(
            onPressed: () {
              print("Antrenman Aktif cikis_buton mavi basıldı");

              // setState(() {
              //   aktifAntrenmanCikis = !aktifAntrenmanCikis;
              // });
            },
            padding: EdgeInsets.all(0.0),
            child: ValueListenableBuilder(
              valueListenable: aktifAntrenmanCikis,
              builder: (context, value, widget) {
                return Opacity(
                  opacity: aktifAntrenmanCikis.value ? 1.0 : 0.0,
                  child: Image.asset(
                      'assets/PNG/AntrenmanEkraniAktif/cikis_buton.png'),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class CrossExit extends StatefulWidget {
  @override
  _CrossExitState createState() => _CrossExitState();
}

class _CrossExitState extends State<CrossExit> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
          child: ConstrainedBox(
              constraints: BoxConstraints.expand(),
              child: FlatButton(
                  onPressed: () {
                    print("Antrenman Aktif cikis_buton cross krımızı basıldı");

                    setState(() {
                      aktifAntrenmanCikis.value = !aktifAntrenmanCikis.value;
                    });
                  },
                  padding: EdgeInsets.all(0.0),
                  child: Image.asset(
                      'assets/PNG/AntrenmanEkraniAktif/cikis.png')))),
    );
  }
}

class EksiButton extends StatefulWidget {
  @override
  _EksiButtonState createState() => _EksiButtonState();
}

class _EksiButtonState extends State<EksiButton> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
          child: ConstrainedBox(
              constraints: BoxConstraints.expand(),
              child: FlatButton(
                  onPressed: () {
                    print("Decrease button tapped!");
                    for (var v = 0; v < buttonsContent.length; v++) {
                      if (buttonsActivatedFlag[v]) {
                        int intTemp = int.parse(buttonsContent[v].value) - 1;
                        if (intTemp >= 0 && intTemp <= 100) {
                          buttonsContent[v].value = intTemp.toString();
                        }
                        print("Button " +
                            v.toString() +
                            " content =" +
                            buttonsContent[v].value);
                      }
                    }

                    // setState(() {
                    //   kutuActivatedFlag[0] = !kutuActivatedFlag[0];
                    // });
                  },
                  padding: EdgeInsets.all(0.0),
                  child: Image.asset(
                      'assets/PNG/AntrenmanEkraniPasif/eksi.png')))),
    );
  }
}

class PlayButton extends StatefulWidget {
  @override
  _PlayButtonState createState() => _PlayButtonState();
}

class _PlayButtonState extends State<PlayButton> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
          child: ConstrainedBox(
              constraints: BoxConstraints.expand(),
              child: FlatButton(
                  onPressed: () {
                    // print(buttonsContent[2].value);
                    // int a = int.parse(buttonsContent[2].value) + 1;

                    setState(() {
                      kutuActivatedFlag[0] = !kutuActivatedFlag[0];
                      playFlag = !playFlag;
                      aktifAntrenmanCikis.value = !aktifAntrenmanCikis.value;
                      print(aktifAntrenmanCikis.value);
                    });
                  },
                  padding: EdgeInsets.all(0.0),
                  child: playFlag
                      ? Image.asset(
                          'assets/PNG/AntrenmanEkraniPasif/baslat.png')
                      : Image.asset(
                          'assets/PNG/AntrenmanEkraniAktif/stopButton.png')))),
    );
  }
}

class ArtiButton extends StatefulWidget {
  @override
  _ArtiButtonState createState() => _ArtiButtonState();
}

class _ArtiButtonState extends State<ArtiButton> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
          child: ConstrainedBox(
              constraints: BoxConstraints.expand(),
              child: FlatButton(
                  onPressed: () {
                    print("Increase button tapped!");
                    for (var v = 0; v < buttonsContent.length; v++) {
                      if (buttonsActivatedFlag[v]) {
                        int intTemp = int.parse(buttonsContent[v].value) + 1;
                        if (intTemp >= 0 && intTemp <= 100) {
                          buttonsContent[v].value = intTemp.toString();
                        }
                        print("Button " +
                            v.toString() +
                            " content =" +
                            buttonsContent[v].value);
                      }
                    }
                    //Send updated stiations on bluetooth serial!
                  },
                  padding: EdgeInsets.all(0.0),
                  child: Image.asset(
                      'assets/PNG/AntrenmanEkraniPasif/arti.png')))),
    );
  }
}
