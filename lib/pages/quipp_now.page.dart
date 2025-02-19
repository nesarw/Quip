import 'package:flutter/material.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart'; // Add this import
import 'connections.page.dart'; // Update this import

class QuippNowPage extends StatefulWidget {
  final String username;
  final VoidCallback onQuippNowComplete;
  final User user; // Add this parameter

  QuippNowPage({required this.username, required this.onQuippNowComplete, required this.user}); // Update constructor

  @override
  _QuippNowPageState createState() => _QuippNowPageState();
}

class _QuippNowPageState extends State<QuippNowPage> {
  final List<String> quips = [
    'Quip 1: This is a random quip.',
    'Quip 2: Another random quip.',
    'Quip 3: Yet another random quip.',
    'Quip 4: More random quips.',
    'Quip 5: Random quip galore.',
  ];

  String currentQuip = 'Quip 1: This is a random quip.';

  void _shuffleQuip() {
    setState(() {
      currentQuip = quips[Random().nextInt(quips.length)];
    });
  }

  void _quipNow() {
    widget.onQuippNowComplete();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Disable back navigation
      child: Scaffold(
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
              Text(
                "${widget.username}",
                style: TextStyle(color: Colors.white, fontSize: 24),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  currentQuip,
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
                    onPressed: _shuffleQuip,
                    child: Text('Shuffle'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black, // Set button color to black
                      foregroundColor: Colors.white, // Set text color to white
                      side: BorderSide(color: Colors.white, width: 2.0), // Add white outline
                    ),
                    onPressed: _quipNow,
                    child: Text('Quipp Now'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
