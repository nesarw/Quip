import 'package:flutter/material.dart';

class InputEmail extends StatefulWidget {
  final TextEditingController controller;

  const InputEmail({Key? key, required this.controller}) : super(key: key);

  @override
  _InputEmailState createState() => _InputEmailState();
}

class _InputEmailState extends State<InputEmail> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 50, left: 50, right: 50),
      child: SizedBox(
        height: 60,
        width: MediaQuery.of(context).size.width,
        child: TextField(
          controller: widget.controller,
          style: TextStyle(
            color: Colors.white,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            fillColor: Colors.lightBlueAccent,
            labelText: 'Email:',
            labelStyle: TextStyle(
              color: Colors.white70,
            ),
          ),
        ),
      ),
    );
  }
}