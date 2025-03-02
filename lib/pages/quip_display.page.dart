import 'package:flutter/material.dart';
import 'dart:math';
import '../widget/identity_display.dart';

class QuipDisplayPage extends StatelessWidget {
  final String quip;
  final String username;

  QuipDisplayPage({
    required this.quip,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black, Colors.black87]),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                quip,
                style: TextStyle(color: Colors.white, fontSize: 24),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // Set button color to black
                    foregroundColor: Colors.white, // Set text color to white
                    side: BorderSide(color: Colors.white, width: 2.0), // Add white outline
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return IdentityDisplay(username: username);
                      },
                    );
                  },
                  child: Row(
                    children: [
                      Icon(Icons.lock_open_outlined, color: Colors.white), // Add reveal icon
                      SizedBox(width: 5),
                      Text('Reveal'),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // Set button color to black
                    foregroundColor: Colors.black, // Set text color to white
                    side: BorderSide(color: Colors.white, width: 2.0), // Add white outline
                  ),
                  onPressed: () {},
                  child: Row(
                    children: [
                      Icon(Icons.favorite, color: Colors.red), // Add like icon
                      SizedBox(width: 5),
                      Text('Like'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 