import 'package:animations/animations.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/services.dart';

import '../src/policyDialog.dart';

class TermsOfUse extends StatelessWidget {
  const TermsOfUse({
    Key key,
  }) : super(key: key);

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
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: 60,
          minWidth: 100,
        ),
        child: DraggableScrollableSheet(
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/jpg/tibbi_yazi.jpg'))),
              child: FutureBuilder(
                  future: rootBundle.loadString('''
assets/terms_and_conditions.md'''),
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.hasData) {
                      return Markdown(data: snapshot.data);
                    }

                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }),
            );
          },
        ),
      ),
    ))));
    //   showModal(
    //   context: context,
    //   configuration: FadeScaleTransitionConfiguration(),
    //   builder: (context) {
    //     return PolicyDialog(
    //       mdFileName: 'terms_and_conditions.md',
    //     );
    //   },
    // );

    // return Padding(
    //     padding: const EdgeInsets.all(16.0),
    //     child: RichText(
    //       textAlign: TextAlign.center,
    //       text: TextSpan(
    //           text: "By creating an account, you are agreeing to our\n",
    //           style: Theme.of(context).textTheme.bodyText1,
    //           children: [
    //             TextSpan(
    //               text: "Terms & Conditions ",
    //               style: TextStyle(fontWeight: FontWeight.bold),
    //               recognizer: TapGestureRecognizer()
    //                 ..onTap = () {
    //                   showModal(
    //                     context: context,
    //                     configuration: FadeScaleTransitionConfiguration(),
    //                     builder: (context) {
    //                       return PolicyDialog(
    //                         mdFileName: 'terms_and_conditions.md',
    //                       );
    //                     },
    //                   );
    //                 },
    //             ),
    //           ]),
    //     ));
  }
}
