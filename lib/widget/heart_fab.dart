import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quip/pages/liked_quips.page.dart';

class HeartFAB extends StatelessWidget {
  final VoidCallback? onPressed;
  final User user;

  const HeartFAB({
    Key? key,
    this.onPressed,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.0),
      child: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LikedQuipsPage(user: user),
            ),
          );
        },
        backgroundColor: Colors.white,
        shape: CircleBorder(),
        child: Icon(
          Icons.favorite,
          color: Colors.red,
          size: 30,
        ),
      ),
    );
  }
} 