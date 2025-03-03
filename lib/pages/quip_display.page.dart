import 'package:flutter/material.dart';
import 'dart:math';
import '../widget/identity_display.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuipDisplayPage extends StatefulWidget {
  final String quip;
  final String username;

  const QuipDisplayPage({Key? key, 
    required this.quip,
    required this.username,
  }) : super(key: key);

  @override
  _QuipDisplayPageState createState() => _QuipDisplayPageState();
}

class _QuipDisplayPageState extends State<QuipDisplayPage> {
  int revealsLeft = 5;
  int userLikes = 0;

  @override
  void initState() {
    super.initState();
    _loadRevealsLeft();
    _resetRevealsAtMidnight();
    _fetchUserLikes();
  }

  Future<void> _loadRevealsLeft() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      revealsLeft = prefs.getInt('revealsLeft') ?? 5;
    });
  }

  Future<void> _decrementReveals() async {
    if (revealsLeft > 0) {
      setState(() {
        revealsLeft--;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt('revealsLeft', revealsLeft);
    }
  }

  Future<void> _resetRevealsAtMidnight() async {
    DateTime now = DateTime.now();
    DateTime nextMidnight = DateTime(now.year, now.month, now.day + 1);
    Duration timeUntilMidnight = nextMidnight.difference(now);

    Future.delayed(timeUntilMidnight, () async {
      setState(() {
        revealsLeft = 5;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt('revealsLeft', revealsLeft);
      _resetRevealsAtMidnight(); // Schedule the next reset
    });
  }

  Future<void> _fetchUserLikes() async {
    try {
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUserId).get();
      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
      setState(() {
        userLikes = userData != null && userData.containsKey('likes') ? userData['likes'] : 0;
      });
    } catch (e) {
      print('Error fetching user likes: $e');
    }
  }

  Future<void> _incrementLikes() async {
    try {
      // Step 1: Fetch the quip document from the "quips" collection
      QuerySnapshot quipSnapshot = await FirebaseFirestore.instance
          .collection('quips')
          .where('currentSentQuip', isEqualTo: widget.quip)
          .limit(1)
          .get();

      if (quipSnapshot.docs.isNotEmpty) {
        DocumentSnapshot quipDoc = quipSnapshot.docs.first;
        String senderUserId = quipDoc['senderUserId'];

        // Step 2: Check if the logged-in user has already liked this quip
        Map<String, dynamic>? quipData = quipDoc.data() as Map<String, dynamic>?;
        List<dynamic> likedBy = quipData != null && quipData.containsKey('likedBy') ? quipData['likedBy'] : [];
        String currentUserId = FirebaseAuth.instance.currentUser!.uid;

        if (!likedBy.contains(currentUserId)) {
          // Step 3: Use the senderUserId to locate the user in the "users" collection
          DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(senderUserId);

          // Step 4: Check if the "likes" field exists; if not, initialize it
          DocumentSnapshot userDoc = await userDocRef.get();
          Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
          int currentLikes = userData != null && userData.containsKey('likes')
              ? userData['likes']
              : 0;

          // Step 5: Increment the "likes" counter by 1
          await userDocRef.update({'likes': currentLikes + 1});

          // Step 6: Add the current user's ID to the likedBy list
          likedBy.add(currentUserId);
          await quipDoc.reference.update({'likedBy': likedBy});
        } else {
          print('User has already liked this quip.');
        }
      }
    } catch (e) {
      print('Error incrementing likes: $e');
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                widget.quip,
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
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black, // Set button color to black
                        foregroundColor: Colors.white, // Set text color to white
                        side: BorderSide(color: Colors.white, width: 2.0), // Add white outline
                      ),
                      onPressed: () {
                        if (revealsLeft > 0) {
                          _decrementReveals();
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return IdentityDisplay(username: widget.username);
                            },
                          );
                        } else {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Colors.black, // Set dialog background to black
                                title: Text(
                                  'No Free Reveals Left',
                                  style: TextStyle(color: Colors.white), // Set title text color to white
                                ),
                                content: Text(
                                  'You have used all your free reveals for today.',
                                  style: TextStyle(color: Colors.white), // Set content text color to white
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.white, // Set button background to white
                                    ),
                                    child: Text(
                                      'OK',
                                      style: TextStyle(color: Colors.black), // Set button text color to black
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
                      },
                      child: Row(
                        children: [
                          Icon(Icons.lock_open_outlined, color: Colors.white), // Add reveal icon
                          SizedBox(width: 5),
                          Text('Reveal'),
                        ],
                      ),
                    ),
                    Text(
                      '$revealsLeft/5 Left',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                Column(
                  children: [
                    SizedBox(
                      width: 140, // Set desired width
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, // Set button color to black
                          foregroundColor: Colors.black, // Set text color to white
                          side: BorderSide(color: Colors.white, width: 4.0), // Add white outline
                        ),
                        onPressed: () {
                          _incrementLikes();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center, // Center contents
                          children: [
                            Icon(Icons.favorite, color: Colors.red), // Add like icon
                            SizedBox(width: 5),
                            Text('Like'),
                          ],
                        ),
                      ),
                    ),
                    // Text(
                    //   'Likes: $userLikes',
                    //   style: TextStyle(color: Colors.white),
                    // ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 