import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add this import
import 'package:quip/widget/bottom_navigation_bar.dart'; // Add this import

class QuippInboxPage extends StatefulWidget {
  final User user;

  QuippInboxPage({required this.user});

  @override
  _QuippInboxPageState createState() => _QuippInboxPageState();
}

class _QuippInboxPageState extends State<QuippInboxPage> {
  final List<String> quips = [
    'Someone Sent you a Quip',
    'Someone Sent you a Quip','Someone Sent you a Quip','Someone Sent you a Quip','Someone Sent you a Quip','Someone Sent you a Quip','Someone Sent you a Quip','Someone Sent you a Quip','Someone Sent you a Quip','Someone Sent you a Quip','Someone Sent you a Quip',
    // Add more quips as needed
  ];

  int _selectedIndex = 1; // Set the selected index to 1 for the inbox page

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/connections');
    }
  }

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
        child: ListView(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Align to the left
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 50.0, left: 16.0, right: 16.0, bottom: 16.0), // Add margin from the top
                  child: Text(
                    'Inbox',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
                ...quips.map((quip) => ListTile(
                      title: Text(
                        quip,
                        style: TextStyle(color: Colors.white),
                      ),
                      leading: Icon(Icons.message, color: Colors.white),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
