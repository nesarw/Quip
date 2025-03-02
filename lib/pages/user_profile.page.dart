import 'package:cloud_firestore/cloud_firestore.dart'; // Add this import
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add this import
import 'package:quip/widget/bottom_navigation_bar.dart'; // Add this import
import 'package:quip/pages/edit_profile.page.dart'; // Add this import
import 'dart:io'; // Add this import

class UserProfilePage extends StatefulWidget {
  final User user;

  const UserProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  int _selectedIndex = 2; // Set the selected index to 2 for the profile page
  String userName = 'John Doe'; // Default value
  String? photoURL; // Add this variable
  late Future<void> _userDataFuture; // Add this variable
  int userLikes = 0; // Add this variable

  final List<String> topQuips = [
    'Top Quip 1: This is the first top quip.',
    'Top Quip 2: This is the second top quip.',
  ];

  @override
  void initState() {
    super.initState();
    _userDataFuture = _fetchUserData(); // Initialize the future
    _fetchUserLikes(); // Fetch user likes
  }

  Future<void> _fetchUserData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.user.uid).get();
      if (userDoc.exists) {
        setState(() {
          userName = userDoc['name'];
          photoURL = userDoc['photoURL'];
          Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
          userLikes = userData != null && userData.containsKey('likes') ? userData['likes'] : 0; // Fetch likes
        });

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('userName', userName);
        if (photoURL != null) {
          prefs.setString('photoURL', photoURL!);
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Future<void> _fetchUserLikes() async {
    try {
      // Fetch the current user's ID
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;

      // Retrieve the user document from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUserId).get();

      // Safely access the user data
      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

      // Update the state with the likes count
      setState(() {
        userLikes = userData != null && userData.containsKey('likes') ? userData['likes'] : 0;
      });
    } catch (e) {
      print('Error fetching user likes: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/connections');
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, '/quipp_inbox');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _userDataFuture, // Use the initialized future
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              color: Colors.black,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading user data',
                style: TextStyle(color: Colors.white),
              ),
            );
          } else {
            return Container(
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
                          'User Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: <Widget>[
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: photoURL != null
                                  ? NetworkImage(photoURL!)
                                  : AssetImage('assets/profile_photo.jpg') as ImageProvider,
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Name: $userName',
                                    style: TextStyle(color: Colors.white, fontSize: 18),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Email: ${widget.user.email}',
                                    style: TextStyle(color: Colors.white, fontSize: 18),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  SizedBox(height: 16),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black, // Set button color to black
                                      foregroundColor: Colors.white, // Set text color to white
                                      side: BorderSide(color: Colors.white, width: 2.0), // Add white outline
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30), // Rounded edges
                                      ),
                                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditProfilePage(
                                            user: widget.user,
                                            userName: userName,
                                            email: widget.user.email!,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.person, color: Colors.white),
                                        SizedBox(width: 5),
                                        Text('Edit Profile'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 54.0), // Add left padding
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    "Quip's:",
                                    style: TextStyle(color: Colors.white, fontSize: 20),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    '150',
                                    style: TextStyle(color: Colors.white, fontSize: 20),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 54.0), // Add right padding
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    "Like's:",
                                    style: TextStyle(color: Colors.white, fontSize: 20),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    '$userLikes',
                                    style: TextStyle(color: Colors.white, fontSize: 20),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 28),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Top Quipps:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: topQuips.map((quip) => ListTile(
                            title: Text(
                              quip,
                              style: TextStyle(color: Colors.white),
                            ),
                            leading: Icon(Icons.message, color: Colors.white),
                          )).toList(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}