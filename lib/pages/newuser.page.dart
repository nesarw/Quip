import 'package:flutter/material.dart';
import 'package:quip/widget/buttonNewUser.dart';
import 'package:quip/widget/newEmail.dart';
import 'package:quip/widget/newName.dart';
import 'package:quip/widget/password.dart';
import 'package:quip/widget/singup.dart';
import 'package:quip/widget/textNew.dart';
import 'package:quip/widget/userOld.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:quip/pages/login.page.dart'; // Import the login page

class NewUser extends StatefulWidget {
  @override
  _NewUserState createState() => _NewUserState();
}

class _NewUserState extends State<NewUser> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance; // Initialize FirebaseAuth

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

    try {
      // Debugging statements
      print('Name: $name');
      print('Email: $email');
      print('Password: $password');

      // Store user details in Firestore first
      DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc();
      await userDoc.set({
        'name': name,
        'email': email,
        'password': password, // Note: Storing passwords in Firestore is not recommended
      });

      // Create user in Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        // Update Firestore document with the user's UID
        await userDoc.update({
          'uid': user.uid,
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
    } catch (e) {
      // Debugging statement
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create account: ${e.toString()}'),
          duration: Duration(seconds: 2),
        ),
      );
    }
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
                UserOld(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}