import 'package:flutter/material.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'connections.page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quip/services/message_generator.service.dart';

class QuippNowPage extends StatefulWidget {
  final String username;
  final VoidCallback onQuippNowComplete;
  final User user;
  final String receiverUserId;

  const QuippNowPage({Key? key, 
    required this.username,
    required this.onQuippNowComplete,
    required this.user,
    required this.receiverUserId,
  }) : super(key: key);

  @override
  _QuippNowPageState createState() => _QuippNowPageState();
}

class _QuippNowPageState extends State<QuippNowPage> {
  String currentQuip = 'Loading...';
  String receiverUsername = 'Loading...';
  int shufflesLeft = 5;
  bool isLoading = false;
  final MessageGeneratorService _messageGenerator = MessageGeneratorService();

  @override
  void initState() {
    super.initState();
    _fetchReceiverUsername();
    _loadShufflesLeft();
    _resetShufflesAtMidnight();
    _generateNewQuip();
  }

  Future<void> _generateNewQuip() async {
    if (shufflesLeft > 0) {
      setState(() {
        isLoading = true;
      });

      try {
        final generatedMessage = await _messageGenerator.generateMessage();
        setState(() {
          currentQuip = generatedMessage;
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          currentQuip = 'Failed to generate message. Try again!';
          isLoading = false;
        });
      }
    } else {
      _showNoShufflesDialog();
    }
  }

  void _showNoShufflesDialog() {
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
      print('Error fetching username: $e');
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
      await prefs.setInt('shufflesLeft', shufflesLeft);
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
      await prefs.setInt('shufflesLeft', shufflesLeft);
      _resetShufflesAtMidnight(); // Schedule the next reset
    });
  }

  void _quipNow() async {
    await FirebaseFirestore.instance.collection('quips').add({
      'currentSentQuip': currentQuip,
      'senderUserId': widget.user.uid,
      'senderName': widget.user.displayName ?? 'Unknown',
      'receiverUserId': widget.receiverUserId,
      'receiverName': receiverUsername,
      'timestamp': FieldValue.serverTimestamp(),
      'likedBy': [],
    });

    widget.onQuippNowComplete();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black, Colors.black87],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                receiverUsername,
                style: TextStyle(color: Colors.white, fontSize: 24),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              if (isLoading)
                CircularProgressIndicator(color: Colors.white)
              else
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(
                    currentQuip,
                    style: TextStyle(color: Colors.white, fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                ),
              SizedBox(height: 50),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: 150,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                side: BorderSide(color: Colors.white, width: 2.0),
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                              onPressed: shufflesLeft > 0 ? () async {
                                await _generateNewQuip();
                                await _decrementShuffles();
                              } : null,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.shuffle, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text('Shuffle'),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '$shufflesLeft/5 Left',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 150,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.white, width: 2.0),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        onPressed: _quipNow,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.send, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Send Quip'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
