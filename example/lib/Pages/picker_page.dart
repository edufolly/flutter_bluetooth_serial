import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import './antrenmanEkranı.dart';

const List<String> colors = const <String>[
  'Red',
  'Yellow',
  'Amber',
  'Blue',
  'Black',
  'Pink',
  'Purple',
  'White',
  'Grey',
  'Green',
];

class PickerPage extends StatefulWidget {
  @override
  _PickerPageState createState() => _PickerPageState();
}

class _PickerPageState extends State<PickerPage> {
  int _selectedMod = 0, _selectedSeviye = 0;
  int _selectedModIc = 0, _selectedCalismaSur = 0;
  int _selectedAntrenmanSur = 0, _selectedDinlenmeSur = 0;
  List modlar = [
    'Başlangıç',
    'Dayanıklılık',
    'Kuvvet',
    'Yağ Yakımı',
    'Dinlenme',
    'Özel'
  ];
  List seviye = ['Kolay', 'Normal', 'Zor'];

  List calismaSuresi = [
    '1 Sn',
    '2 Sn',
    '3 Sn',
    '4 Sn',
    '5 Sn',
    '6 Sn',
    '7 Sn',
    '8 Sn',
    '9 Sn',
    '10 Sn',
  ];
  List antrenmanSuresi = [
    ['10 Dk', '15 Dk', '20 Dk', '25 Dk', '30 Dk'],
    ['15 Dk', '20 Dk', '25 Dk', '30 Dk'],
    ['15 Dk', '20 Dk', '25 Dk', '30 Dk', '40 Dk'],
    ['15 Dk', '20 Dk', '25 Dk', '30 Dk'],
    ['5 Dk', '10 Dk'],
    ['15 Dk', '20 Dk', '25 Dk', '30 Dk']
  ];
  List dinlenmeSuresi = [
    '1 Sn',
    '2 Sn',
    '3 Sn',
    '4 Sn',
    '5 Sn',
    '6 Sn',
    '7 Sn',
    '8 Sn',
    '9 Sn',
    '10 Sn',
  ];

  List modIcerigi = [
    [
      'Başlangıç - 1',
      'Başlangıç - 2',
      'Başlangıç - 3',
      'Süreklilik - 1',
      'Süreklilik - 2'
    ],
    ['Dayanıklılık - 1', 'Dayanıklılık - 2', 'Dayanıklılık - 3'],
    ['Kuvvet - 1', 'Kuvvet - 2'],
    ['Yağ Yakımı - 1', 'Yağ Yakımı - 2'],
    ['Dinlenme - 1', 'Dinlenme - 2'],
    ['Masaj', 'Selülit Önleyici']
  ];
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Mod Seçimi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            // Text(
            //   "Normal Cupertino Picker",
            //   style: TextStyle(
            //     fontWeight: FontWeight.bold,
            //     fontSize: 18.0,
            //   ),
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                CupertinoButton(
                    child: Text("MODLAR   :"),
                    onPressed: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              height: 200.0,
                              child: CupertinoPicker(
                                  itemExtent: 32.0,
                                  onSelectedItemChanged: (int index) {
                                    setState(() {
                                      _selectedMod = index;
                                      _selectedSeviye = 0;
                                      _selectedModIc = 0;
                                      _selectedCalismaSur = 0;
                                      _selectedAntrenmanSur = 0;
                                      _selectedDinlenmeSur = 0;
                                    });
                                  },
                                  children: new List.generate(modlar.length,
                                      (int index) {
                                    return new Center(
                                      child: new Text(modlar[index]),
                                    );
                                  })),
                            );
                          });
                    }),
                Text(
                  modlar[_selectedMod],
                  style: TextStyle(fontSize: 18.0),
                ),
                SizedBox(
                  height: 20.0,
                ),
                CupertinoButton(
                    child: Text("SEVİYE   :"),
                    onPressed: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              height: 200.0,
                              child: CupertinoPicker(
                                  itemExtent: 32.0,
                                  onSelectedItemChanged: (int index) {
                                    setState(() {
                                      _selectedSeviye = index;
                                    });
                                  },
                                  children: new List.generate(3, (int index) {
                                    return new Center(
                                      child: new Text(seviye[index]),
                                    );
                                  })),
                            );
                          });
                    }),
                Text(
                  seviye[_selectedSeviye],
                  style: TextStyle(fontSize: 18.0),
                ),
                SizedBox(
                  height: 20.0,
                ),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                CupertinoButton(
                    child: Text("MOD İÇERİĞİ  :"),
                    onPressed: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              height: 200.0,
                              child: CupertinoPicker(
                                  itemExtent: 32.0,
                                  onSelectedItemChanged: (int index) {
                                    setState(() {
                                      _selectedModIc = index;
                                    });
                                  },
                                  children: new List.generate(
                                      modIcerigi[_selectedMod].length,
                                      (int index) {
                                    return new Center(
                                      child: new Text(
                                          modIcerigi[_selectedMod][index]),
                                    );
                                  })),
                            );
                          });
                    }),
                Text(
                  modIcerigi[_selectedMod][_selectedModIc],
                  style: TextStyle(fontSize: 18.0),
                ),
                SizedBox(
                  height: 20.0,
                ),
                CupertinoButton(
                    child: Text("ÇALIŞMA SÜRESİ   :"),
                    onPressed: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              height: 200.0,
                              child: CupertinoPicker(
                                  itemExtent: 32.0,
                                  onSelectedItemChanged: (int index) {
                                    setState(() {
                                      _selectedCalismaSur = index;
                                    });
                                  },
                                  children: new List.generate(
                                      calismaSuresi.length, (int index) {
                                    return new Center(
                                      child: new Text(calismaSuresi[index]),
                                    );
                                  })),
                            );
                          });
                    }),
                Text(
                  calismaSuresi[_selectedCalismaSur],
                  style: TextStyle(fontSize: 18.0),
                ),
                SizedBox(
                  height: 20.0,
                ),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                CupertinoButton(
                    child: Text("ANTRENMAN SÜRESİ   :"),
                    onPressed: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              height: 200.0,
                              child: CupertinoPicker(
                                  itemExtent: 32.0,
                                  onSelectedItemChanged: (int index) {
                                    setState(() {
                                      _selectedAntrenmanSur = index;
                                    });
                                  },
                                  children: new List.generate(
                                      antrenmanSuresi[_selectedMod].length,
                                      (int index) {
                                    return new Center(
                                      child: new Text(
                                          antrenmanSuresi[_selectedMod][index]),
                                    );
                                  })),
                            );
                          });
                    }),
                Text(
                  antrenmanSuresi[_selectedMod][_selectedAntrenmanSur],
                  style: TextStyle(fontSize: 18.0),
                ),
                SizedBox(
                  height: 20.0,
                ),
                CupertinoButton(
                    child: Text("DİNLENME SÜRESİ   :"),
                    onPressed: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              height: 200.0,
                              child: CupertinoPicker(
                                  itemExtent: 32.0,
                                  onSelectedItemChanged: (int index) {
                                    setState(() {
                                      _selectedDinlenmeSur = index;
                                    });
                                  },
                                  children: new List.generate(
                                      dinlenmeSuresi.length, (int index) {
                                    return new Center(
                                      child: new Text(dinlenmeSuresi[index]),
                                    );
                                  })),
                            );
                          });
                    }),
                Text(
                  dinlenmeSuresi[_selectedDinlenmeSur],
                  style: TextStyle(fontSize: 18.0),
                ),
                SizedBox(
                  height: 20.0,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  child: const Text('TAMAM'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AntrenmanEkrani()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
