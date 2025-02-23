import 'package:flutter/material.dart';
import 'package:quip/widget/bottom_navigation_bar.dart';
import 'package:quip/pages/quipp_inbox.page.dart';
import 'package:quip/pages/user_profile.page.dart';
import 'package:quip/pages/quipp_now.page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quip/widget/profile_incomplete.widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ConnectionsPage extends StatefulWidget {
  final User user;

  ConnectionsPage({required this.user});

  @override
  _ConnectionsPageState createState() => _ConnectionsPageState();
}

class _ConnectionsPageState extends State<ConnectionsPage> {
  int _selectedIndex = 0;
  bool _isProfileIncomplete = false;
  bool _isLoading = true;
  List<String> _contacts = [];

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _checkProfileCompletion();
  }

  Future<void> _checkProfileCompletion() async {
    setState(() {
      _isLoading = true;
    });
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.user.uid).get();
    if (userDoc.exists) {
      Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
      bool isIncomplete = false;
      if (data['dateOfBirth'] == null) {
        isIncomplete = true;
      }
      if (data['gender'] == null) {
        isIncomplete = true;
      }
      if (data['mobileNumber'] == null) {
        isIncomplete = true;
      }
      setState(() {
        _isProfileIncomplete = isIncomplete;
      });
    }
    await _fetchContacts(); // Fetch contacts after checking profile completion
    setState(() {
      _pages.clear();
      _pages.addAll([
        ConnectionsPageContent(
          user: widget.user,
          isProfileIncomplete: _isProfileIncomplete,
          contacts: _contacts,
        ),
        QuippInboxPage(user: widget.user),
        UserProfilePage(user: widget.user),
      ]);
      _isLoading = false;
    });
  }

  Future<void> _fetchContacts() async {
    if (await FlutterContacts.requestPermission()) {
      List<Contact> contacts = await FlutterContacts.getContacts(withProperties: true);
      setState(() {
        _contacts = contacts.map((contact) => contact.displayName).toList();
        print('Fetched contacts: $_contacts'); // Add debug print
      });
    } else {
      print('Permission denied'); // Add debug print
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _checkProfileCompletion(); // Re-check profile completion and fetch contacts on tab change
    });
  }

  void _navigateToQuippNow(String username) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuippNowPage(
          username: username,
          onQuippNowComplete: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ConnectionsPage(user: widget.user)),
            );
          },
          user: widget.user,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            _onItemTapped(index);
          },
        ),
      ),
    );
  }
}

class ConnectionsPageContent extends StatelessWidget {
  final User user;
  final bool isProfileIncomplete;
  final List<String> contacts;

  ConnectionsPageContent({
    required this.user,
    required this.isProfileIncomplete,
    required this.contacts,
  });

  @override
  Widget build(BuildContext context) {
    final _ConnectionsPageState parentState = context.findAncestorStateOfType<_ConnectionsPageState>()!;

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (isProfileIncomplete)
                ProfileIncomplete(user: user, userName: user.displayName ?? ''),
              Padding(
                padding: const EdgeInsets.only(top: 50.0, left: 16.0, right: 16.0, bottom: 16.0),
                child: Text(
                  'Connections',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              ...contacts.map((contact) => Material(
                color: Colors.transparent,
                child: ListTile(
                  title: Text(
                    contact,
                    style: TextStyle(color: Colors.white),
                  ),
                  leading: Icon(Icons.person, color: Colors.white),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white, width: 2.0),
                    ),
                    onPressed: () {
                      parentState._navigateToQuippNow(contact);
                    },
                    child: Text('Quip now'),
                  ),
                ),
              )),
            ],
          ),
        ],
      ),
    );
  }
}
