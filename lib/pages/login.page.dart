import 'package:flutter/material.dart';
import 'package:quip/widget/button.dart';
import 'package:quip/widget/first.dart';
import 'package:quip/widget/inputEmail.dart';
import 'package:quip/widget/password.dart';
import 'package:quip/widget/textLogin.dart';
import 'package:quip/widget/verticalText.dart';

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
                ButtonLogin(),
                // Ensure the correct widget is used
                SizedBox(height: 20),
                // Add some space between the button and the Google sign-in
                GestureDetector(
                  onTap: () {
                    // Handle Google sign-in
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      // Change background color to black
                      borderRadius: BorderRadius.circular(30),
                      // Make the button fully rounded
                      border: Border.all(color: Colors.white),
                      // Change border color to white
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black87,
                          blurRadius: 5,
                          offset: Offset(5, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Image.network(
                          'https://cdn-icons-png.flaticon.com/512/300/300221.png',
                          // New Google icon URL
                          height: 20,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Sign In with Google',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white, // Change text color to white
                          ),
                        ),
                      ],
                    ),
                  ),
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