import 'package:flutter/material.dart';

class NewEmail extends StatefulWidget {
  final TextEditingController controller;

  const NewEmail({Key? key, required this.controller}) : super(key: key);

  @override
  _NewEmailState createState() => _NewEmailState();
}

class _NewEmailState extends State<NewEmail> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 50, right: 50),
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
            labelText: 'E-mail',
            labelStyle: TextStyle(
              color: Colors.white70,
            ),
          ),
        ),
      ),
    );
  }
}