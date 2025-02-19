import 'package:flutter/material.dart';
import 'package:quip/widget/buttonNewUser.dart';
import 'package:quip/widget/newEmail.dart';
import 'package:quip/widget/newName.dart';
import 'package:quip/widget/password.dart';
import 'package:quip/widget/singup.dart';
import 'package:quip/widget/textNew.dart';
import 'package:quip/widget/userOld.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quip/pages/login.page.dart'; // Import the login page

class NewUser extends StatefulWidget {
  @override
  _NewUserState createState() => _NewUserState();
}

class _NewUserState extends State<NewUser> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _validateEmail(String email) {
    final RegExp emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegExp.hasMatch(email);
  }

  bool _validatePassword(String password) {
    final RegExp passwordRegExp = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
    );
    return passwordRegExp.hasMatch(password);
  }

  Future<void> _registerNewUser() async {
    String name = _nameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('All fields are required'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (!_validateEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid email format'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (!_validatePassword(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password must be at least 8 characters long, include an uppercase letter, a lowercase letter, a number, and a special character'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('users').add({
      'name': name,
      'email': email,
      'password': password,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Account created'),
        duration: Duration(seconds: 2),
      ),
    );

    // Redirect to the login page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

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
                Row(
                  children: <Widget>[
                    SingUp(),
                    TextNew(),
                  ],
                ),
                NewNome(controller: _nameController),
                NewEmail(controller: _emailController),
                PasswordInput(controller: _passwordController),
                ButtonNewUser(onPressed: _registerNewUser),
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

                UserOld(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}