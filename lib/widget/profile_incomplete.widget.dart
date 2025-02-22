import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quip/pages/edit_profile.page.dart'; // Add this import

class ProfileIncomplete extends StatelessWidget {
  final User user;
  final String userName;

  const ProfileIncomplete({Key? key, required this.user, required this.userName}) : super(key: key); // Update constructor

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.0), // Add margin around the widget
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(12.0), // Add rounded corners
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.white),
          SizedBox(width: 8.0),
          Expanded(
            child: Text(
              'Your profile is incomplete.',
              style: TextStyle(color: Colors.white, fontSize: 20.0), // Increase text size
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white, width: 2.0),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfilePage(
                    user: user,
                    userName: userName,
                    email: user.email ?? '',
                  ),
                ),
              );
            },
            child: Text('Complete Now'),
          ),
        ],
      ),
    );
  }
}
