import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add this import
import 'package:quip/widget/bottom_navigation_bar.dart'; // Add this import
import 'package:quip/pages/quip_display.page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quip/widget/heart_fab.dart';
import 'package:quip/widget/inbox_shimmer.dart';

class QuippInboxPage extends StatefulWidget {
  final User user;

  const QuippInboxPage({Key? key, required this.user}) : super(key: key);

  @override
  _QuippInboxPageState createState() => _QuippInboxPageState();
}

class _QuippInboxPageState extends State<QuippInboxPage> {
  List<Map<String, dynamic>> quips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchQuips();
  }

  Future<void> _fetchQuips() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('quips')
          .where('receiverUserId', isEqualTo: widget.user.uid)
          .get();

      if (!mounted) return;
      setState(() {
        quips = querySnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data != null) {
            return data;
          } else {
            return <String, dynamic>{};
          }
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching quips: $e");
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
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
      body: _isLoading
          ? InboxShimmer()
          : Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/loginpagebg.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.5),
                    ],
                  ),
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
            ),
      floatingActionButton: HeartFAB(
        user: widget.user,
      ),
    );
  }
}
