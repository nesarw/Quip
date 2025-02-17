import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProfilePage extends StatelessWidget {
  final User user;

  UserProfilePage({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(user.photoURL ?? ''),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Name: ${user.displayName ?? 'N/A'}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Email: ${user.email ?? 'N/A'}',
              style: TextStyle(fontSize: 18),
            ),
            // Add other details such as date of birth and gender if available
            // For example, if you have stored these details in Firestore, you can fetch and display them here
          ],
        ),
      ),
    );
  }
}
