import 'package:flutter/material.dart';

import './MainPage.dart';

void main() => runApp(new ExampleApplication());

class ExampleApplication extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // title: 'Flutter Demo',
      // theme: new ThemeData(scaffoldBackgroundColor: const Color(0xff4D4847)),
      home: MainPage(),
    );
  }
}
