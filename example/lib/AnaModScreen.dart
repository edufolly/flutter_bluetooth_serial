import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

//import 'package:flutter_spleshscreen/Constant/Constant.dart';
import 'package:flutter/cupertino.dart';

Widget build(BuildContext context) {
  return Image(image: AssetImage('assets/PNG/LOGO/logo.png'));
}

class MyApp1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            // appBar: AppBar(title: Text('Set Full Screen Background Image')),
            body: Center(
      child: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/BackCover.jpg'), fit: BoxFit.cover)),
        child: Column(
          children: [
            Container(
              height: 200.0,
              width: 200.0,
              decoration: new BoxDecoration(
                  image: DecorationImage(
                      image: new AssetImage('assets/PNG/LOGO/logo.png'),
                      fit: BoxFit.fill),
                  shape: BoxShape.circle),
              child: Center(
                child: Text(
                  'Welcome to Prime Message',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Aleo',
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.bold,
                      fontSize: 25.0,
                      color: Colors.white),
                ),
              ),
            ),
            // Container(
            //   child: Text(
            //     'Welcome to Prime Message',
            //     textAlign: TextAlign.center,
            //     style: TextStyle(
            //         fontFamily: 'Aleo',
            //         fontStyle: FontStyle.normal,
            //         fontWeight: FontWeight.bold,
            //         fontSize: 25.0,
            //         color: Colors.white),
            //   ),
            // ),
          ],
        ),
      ),
      // child: Center(
      //   child: Text(
      //     'Set Full Screen Background Image in Flutter',
      //     textAlign: TextAlign.center,
      //     style: TextStyle(
      //         color: Colors.brown,
      //         fontSize: 25,
      //         fontWeight: FontWeight.bold),
      //   ),)
    )));
  }
}

class CustomButton extends StatelessWidget {
  CustomButton({@required this.onPressed});
  final GestureTapCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      fillColor: Colors.green,
      splashColor: Colors.greenAccent,
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const <Widget>[
            Icon(
              Icons.face,
              color: Colors.amber,
            ),
            SizedBox(
              width: 10.0,
            ),
            Text(
              "Tap Me",
              maxLines: 1,
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
      onPressed: onPressed,
      shape: const StadiumBorder(),
    );
  }
}

class SecondRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Second Route"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Go back!'),
        ),
      ),
    );
  }
}
