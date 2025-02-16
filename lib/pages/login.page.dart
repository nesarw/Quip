import 'package:flutter/material.dart';
import 'package:quip/widget/button.dart';
import 'package:quip/widget/first.dart';
import 'package:quip/widget/forgot.dart';
import 'package:quip/widget/inputEmail.dart';
import 'package:quip/widget/password.dart';
import 'package:quip/widget/textLogin.dart';
import 'package:quip/widget/verticalText.dart';
import 'package:quip/pages/connections.page.dart'; // Add this import

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Colors.black, Colors.black87]),
        ),
        child: ListView(
          children: <Widget>[
            Column(
              children: <Widget>[
                Row(children: <Widget>[
                  VerticalText(),
                  TextLogin(),
                ]),
                InputEmail(),
                PasswordInput(),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ConnectionsPage()),
                    );
                  },
                  child: Text('OK'),
                ),
                FirstTime(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}