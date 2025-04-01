import 'package:cloud_firestore/cloud_firestore.dart'; // Add this import
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add this import
import 'package:quip/widget/bottom_navigation_bar.dart'; // Add this import
import 'package:quip/pages/edit_profile.page.dart'; // Add this import
import 'package:quip/pages/menu_page.dart';
import 'package:quip/widget/profile_shimmer.dart';
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
  bool _isLoading = true;
  int userLikes = 0; // Add this variable
  int totalQuipsReceived = 0; // Add a variable to store the total number of quips received
  List<String> recentQuips = []; // Add a variable to store the recent quips

  final List<String> topQuips = [
    'Top Quip 1: This is the first top quip.',
    'Top Quip 2: This is the second top quip.',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      await Future.wait([
        _fetchUserData(),
        _fetchUserLikes(),
        _fetchTotalQuipsReceived(),
        _fetchRecentQuips(),
      ]);
    } catch (e) {
      print("Error loading user data: $e");
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchUserData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.user.uid).get();
      if (userDoc.exists) {
        setState(() {
          userName = userDoc['name'];
          photoURL = userDoc['photoURL'];
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
      print('Current User ID: $currentUserId');

      // Query the 'quips' collection to get all quips where the user is the sender
      QuerySnapshot quipSnapshot = await FirebaseFirestore.instance
          .collection('quips')
          .where('senderUserId', isEqualTo: currentUserId)
          .get();

      print('Number of quips found: ${quipSnapshot.docs.length}');

      // Count the total likes from all quips sent by the user
      int totalLikes = 0;
      for (var doc in quipSnapshot.docs) {
        Map<String, dynamic> quipData = doc.data() as Map<String, dynamic>;
        print('Quip Data: $quipData');
        
        // Get the likedBy array and count its length
        List<dynamic>? likedBy = quipData['likedBy'] as List<dynamic>?;
        if (likedBy != null) {
          totalLikes += likedBy.length;
          print('Updated total likes: $totalLikes');
        }
      }

      print('Final total likes: $totalLikes');

      // Update the state with the total likes count
      setState(() {
        userLikes = totalLikes;
      });
    } catch (e) {
      print('Error fetching user likes: $e');
    }
  }

  Future<void> _fetchTotalQuipsReceived() async {
    try {
      // Fetch the current user's ID
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;

      // Query the 'quips' collection to count the number of quips received by the user
      QuerySnapshot quipSnapshot = await FirebaseFirestore.instance
          .collection('quips')
          .where('receiverUserId', isEqualTo: currentUserId)
          .get();

      // Update the state with the total number of quips received
      setState(() {
        totalQuipsReceived = quipSnapshot.docs.length;
      });
    } catch (e) {
      print('Error fetching total quips received: $e');
    }
  }

  Future<void> _fetchRecentQuips() async {
    try {
      // Fetch the current user's ID
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;

      // Query the 'quips' collection to get all quips received by the user
      QuerySnapshot quipSnapshot = await FirebaseFirestore.instance
          .collection('quips')
          .where('receiverUserId', isEqualTo: currentUserId)
          .get();

      // Sort the quips by timestamp in descending order and select the top two
      List<QueryDocumentSnapshot> sortedQuips = quipSnapshot.docs;
      sortedQuips.sort((a, b) {
        Timestamp timestampA = a['timestamp'];
        Timestamp timestampB = b['timestamp'];
        return timestampB.compareTo(timestampA);
      });

      // Update the state with the recent quips
      setState(() {
        recentQuips = sortedQuips.take(2).map((doc) => doc['currentSentQuip'] as String).toList();
      });
    } catch (e) {
      print('Error fetching recent quips: $e');
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
      body: _isLoading
          ? ProfileShimmer()
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
                      Colors.black.withOpacity(0.5),
                      Colors.black.withOpacity(0.5),
                    ],
                  ),
                ),
                child: ListView(
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // Align to the left
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 50.0, left: 16.0, right: 16.0, bottom: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'User Profile',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 34,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.menu, color: Colors.white),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MenuPage(user: widget.user),
                                    ),
                                  );
                                },
                              ),
                            ],
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
                                      '$totalQuipsReceived', // Display total quips received
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
                            children: recentQuips.map((quip) => ListTile(
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
              ),
            ),
    );
  }
}