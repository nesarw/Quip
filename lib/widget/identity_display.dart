import 'package:flutter/material.dart';

class IdentityDisplay extends StatelessWidget {
  final String username;

  IdentityDisplay({required this.username});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        side: BorderSide(color: Colors.white, width: 2.0),
      ),
      title: Text(
        'See who sent it:',
        style: TextStyle(color: Colors.white,fontSize: 22),
      ),
      content: Text(
      username[0].toUpperCase() + username.substring(1),
        style: TextStyle(color: Colors.white, fontSize: 22),
      ),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.white,
          ),
          child: Text('Close', style: TextStyle(color: Colors.black)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
} 