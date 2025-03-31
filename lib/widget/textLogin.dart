import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class TextLogin extends StatefulWidget {
  const TextLogin({Key? key}) : super(key: key);

  @override
  _TextLoginState createState() => _TextLoginState();
}

class _TextLoginState extends State<TextLogin> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0, left: 10.0),
      child: SizedBox(
        //color: Colors.green,
        height: 260,
        width: 250,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 60,
            ),
            DefaultTextStyle(
              style: TextStyle(
                fontSize: 38,
                color: Colors.white,
                fontWeight: FontWeight.w300,
                fontStyle: FontStyle.italic,
              ),
              child: AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    'Welcome to the world of Quip',
                    speed: Duration(milliseconds: 60),
                    textAlign: TextAlign.left,
                  ),
                ],
                repeatForever: true,
                pause: Duration(seconds: 2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}