import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add this import
import 'package:quip/pages/edit_profile.page.dart'; // Add this import

class ProfileIncomplete extends StatelessWidget {
  final User user; // Add this field

  const ProfileIncomplete({Key? key, required this.user}) : super(key: key); // Update constructor

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EditProfilePage(user: user)),
        );
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF000000),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red, width: 2), // Add red border
        ),
        child: const Text.rich(
          TextSpan(
            style: TextStyle(color: Colors.white),
            children: [
              TextSpan(
                text: "Profile Incomplete !\n",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(text: "Click to Complete Now",),
            ],
          ),
        ),
      ),
    );
  }
}
