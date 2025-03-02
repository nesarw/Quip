import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add this import
import 'package:quip/widget/bottom_navigation_bar.dart'; // Add this import
import 'package:quip/pages/quip_display.page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuippInboxPage extends StatefulWidget {
  final User user;

  QuippInboxPage({required this.user});

  @override
  _QuippInboxPageState createState() => _QuippInboxPageState();
}

class _QuippInboxPageState extends State<QuippInboxPage> {
  List<Map<String, dynamic>> quips = [];

  @override
  void initState() {
    super.initState();
    _fetchQuips();
  }

  Future<void> _fetchQuips() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('quips')
          .where('receiverUserId', isEqualTo: widget.user.uid)
          .get();

      setState(() {
        quips = querySnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data != null) {
            return data;
          } else {
            return <String, dynamic>{};
          }
        }).toList();
        print('Fetched quips:');
        print(quips);
      });
    } catch (e) {
      print("Error fetching quips: $e");
    }
  }

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
        child: quips.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sentiment_dissatisfied_sharp, color: Colors.grey, size: 50.0), // Sad face icon
                    SizedBox(height: 10.0),
                    Text(
                      'No quips',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 32,
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                  ],
                ),
              )
            : ListView(
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
                      ...quips.map((quipData) => ListTile(
                            title: Text(
                              'Someone Sent you a Quip',
                              style: TextStyle(color: Colors.white),
                            ),
                            leading: Icon(Icons.message, color: Colors.white),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => QuipDisplayPage(
                                    quip: quipData['currentSentQuip'] ?? 'No Quip',
                                    username: quipData['senderName'] ?? 'Unknown',
                                  ),
                                ),
                              );
                            },
                          )),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
