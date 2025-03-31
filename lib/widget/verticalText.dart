import 'package:flutter/material.dart';

class VerticalText extends StatefulWidget {
  const VerticalText({Key? key}) : super(key: key);

  @override
  _VerticalTextState createState() => _VerticalTextState();
}

class _VerticalTextState extends State<VerticalText> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 60, left: 0),
      child: RotatedBox(
          quarterTurns: -1,
          child: Text(
            'QUIP',
            style: TextStyle(
              color: Colors.white,
              fontSize: 100,
              fontWeight: FontWeight.w900,
            ),
          )),
    );
  }
}
