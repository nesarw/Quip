import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quip/widget/liked_quips_shimmer.dart';

class LikedQuipsPage extends StatefulWidget {
  final User user;

  const LikedQuipsPage({Key? key, required this.user}) : super(key: key);

  @override
  _LikedQuipsPageState createState() => _LikedQuipsPageState();
}

class _LikedQuipsPageState extends State<LikedQuipsPage> {
  List<Map<String, dynamic>> likedQuips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLikedQuips();
  }

  Future<void> _fetchLikedQuips() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      // Get all quips sent by the current user
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('quips')
          .where('senderUserId', isEqualTo: widget.user.uid)
          .get();

      List<Map<String, dynamic>> tempLikedQuips = [];

      // Filter quips that have been liked
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<dynamic> likedBy = data['likedBy'] ?? [];
        
        if (likedBy.isNotEmpty) {
          // Add additional information to the quip data
          data['quipId'] = doc.id;
          tempLikedQuips.add(data);
        }
      }

      // Sort by timestamp in descending order (most recent first)
      tempLikedQuips.sort((a, b) {
        Timestamp timestampA = a['timestamp'] as Timestamp;
        Timestamp timestampB = b['timestamp'] as Timestamp;
        return timestampB.compareTo(timestampA);
      });

      if (!mounted) return;
      setState(() {
        likedQuips = tempLikedQuips;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching liked quips: $e");
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Liked Quips',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? LikedQuipsShimmer()
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
                child: likedQuips.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.favorite_border,
                              color: Colors.grey,
                              size: 50.0,
                            ),
                            SizedBox(height: 10.0),
                            Text(
                              'No liked quips yet',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 32,
                                fontWeight: FontWeight.w200,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: likedQuips.length,
                        itemBuilder: (context, index) {
                          final quip = likedQuips[index];
                          return Card(
                            margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            color: Colors.white.withOpacity(0.1),
                            child: ListTile(
                              title: Text(
                                quip['currentSentQuip'] ?? 'No Quip',
                                style: TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                'Liked by ${quip['receiverName'] ?? 'Unknown'}',
                                style: TextStyle(color: Colors.white70),
                              ),
                              leading: Icon(Icons.favorite, color: Colors.red),
                            ),
                          );
                        },
                      ),
              ),
            ),
    );
  }
} 