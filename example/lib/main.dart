import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import './MainPage.dart';

//import 'package:splashscreen/splashscreen.dart';

void main() {
  runApp(new MaterialApp(
    home: new MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Replace the 3 second delay with your initialization code:
      future: Future.delayed(Duration(seconds: 2)),
      builder: (context, AsyncSnapshot snapshot) {
        // Show splash screen while waiting for app resources to load:
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(home: OpeningPg());
        } else {
          // Loading is done, return the app:
          return MaterialApp(home: ExampleApplication());
        }
      },
    );
  }
}

class OpeningPg extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    // Set landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    return MaterialApp(
      home: Scaffold(
        // appBar: AppBar(title: Text('Set Full Screen Background Image')),
        body: Center(
          child: Container(
            constraints: BoxConstraints.expand(),
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/jpg/ana ekran.jpg'),
                    fit: BoxFit.cover)),
          ),
        ),
      ),
    );
  }
}

class ExampleApplication extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    // Set landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    return MaterialApp(
      // title: 'Flutter Demo',
      // theme: new ThemeData(scaffoldBackgroundColor: const Color(0xff4D4847)),
      home: MainPage(),
    );
  }
}
