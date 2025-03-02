import 'package:flutter/material.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart'; // Add this import
import 'connections.page.dart'; // Update this import
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this import
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this import
import 'package:shared_preferences/shared_preferences.dart';

class QuippNowPage extends StatefulWidget {
  final String username;
  final VoidCallback onQuippNowComplete;
  final User user;
  final String receiverUserId; // Add this parameter

  QuippNowPage({
    required this.username,
    required this.onQuippNowComplete,
    required this.user,
    required this.receiverUserId, // Update constructor
  });

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
  String receiverUsername = 'Loading...'; // Add a variable to store the receiver's username
  int shufflesLeft = 5;

  @override
  void initState() {
    super.initState();
    _fetchReceiverUsername(); // Fetch the receiver's username when the page is initialized
    _loadShufflesLeft();
    _resetShufflesAtMidnight();
  }

  Future<void> _fetchReceiverUsername() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.receiverUserId)
          .get();

      if (userDoc.exists) {
        setState(() {
          receiverUsername = userDoc['name'] ?? 'Unknown';
        });
      } else {
        setState(() {
          receiverUsername = 'User not found';
        });
      }
    } catch (e) {
      print('Error fetching username: $e'); // Log the error
      setState(() {
        receiverUsername = 'Error fetching username';
      });
    }
  }

  Future<void> _loadShufflesLeft() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      shufflesLeft = prefs.getInt('shufflesLeft') ?? 5;
    });
  }

  Future<void> _decrementShuffles() async {
    if (shufflesLeft > 0) {
      setState(() {
        shufflesLeft--;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt('shufflesLeft', shufflesLeft);
    }
  }

  Future<void> _resetShufflesAtMidnight() async {
    DateTime now = DateTime.now();
    DateTime nextMidnight = DateTime(now.year, now.month, now.day + 1);
    Duration timeUntilMidnight = nextMidnight.difference(now);

    Future.delayed(timeUntilMidnight, () async {
      setState(() {
        shufflesLeft = 5;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt('shufflesLeft', shufflesLeft);
      _resetShufflesAtMidnight(); // Schedule the next reset
    });
  }

  void _shuffleQuip() {
    if (shufflesLeft > 0) {
      _decrementShuffles();
      setState(() {
        currentQuip = quips[Random().nextInt(quips.length)];
      });
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.black,
            title: Text(
              'No Free Shuffles Left',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              'You have used all your free shuffles for today.',
              style: TextStyle(color: Colors.white),
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                ),
                child: Text(
                  'OK',
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _quipNow() async {
    // Send the current quip to Firestore
    await FirebaseFirestore.instance.collection('quips').add({
      'currentSentQuip': currentQuip,
      'senderUserId': widget.user.uid,
      'senderName': widget.user.displayName ?? 'Unknown',
      'receiverUserId': widget.receiverUserId, // Use the passed receiver user ID
      'receiverName': receiverUsername, // Use the fetched receiver's username
      'timestamp': FieldValue.serverTimestamp(), // Add server timestamp
    });

    // Call the completion callback
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
                receiverUsername, // Display the fetched receiver's username
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.white, width: 2.0),
                        ),
                        onPressed: _shuffleQuip,
                        child: Row(
                          children: [
                            Icon(Icons.shuffle, color: Colors.white),
                            SizedBox(width: 5),
                            Text('Shuffle'),
                          ],
                        ),
                      ),
                      Text(
                        '$shufflesLeft/5 Left',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          side: BorderSide(color: Colors.white, width: 2.0),
                        ),
                        onPressed: _quipNow,
                        child: Row(
                          children: [
                            Icon(Icons.send, color: Colors.black),
                            SizedBox(width: 5),
                            Text('Quipp Now'),
                          ],
                        ),
                      ),
                    ],
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
