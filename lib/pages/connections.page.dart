import 'package:flutter/material.dart';
import 'package:quip/widget/bottom_navigation_bar.dart';
import 'package:quip/pages/quipp_inbox.page.dart';
import 'package:quip/pages/user_profile.page.dart';
import 'package:quip/pages/quipp_now.page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quip/widget/profile_incomplete.widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:quip/pages/quip_display.page.dart';
import 'package:quip/widget/heart_fab.dart';

class ConnectionsPage extends StatefulWidget {
  final User user;

  const ConnectionsPage({Key? key, required this.user}) : super(key: key);

  @override
  _ConnectionsPageState createState() => _ConnectionsPageState();
}

class _ConnectionsPageState extends State<ConnectionsPage> {
  int _selectedIndex = 0;
  bool _isProfileIncomplete = false;
  bool _isLoading = true;
  List<String> _contacts = [];
  final Map<String, String> _contactUserIds = {}; // Store contact user IDs here

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
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').get();

      List<String> userPhoneNumbers = userSnapshot.docs.map((doc) {
        String phoneNumber = (doc.data() as Map<String, dynamic>)['mobileNumber'] as String? ?? '';
        return phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
      }).toList();

      setState(() {
        _contacts = contacts
            .where((contact) {
              String contactNumber = contact.phones.isNotEmpty ? contact.phones.first.number : '';
              contactNumber = contactNumber.replaceAll(RegExp(r'[^0-9]'), '');
              if (!contactNumber.startsWith('91') && contactNumber.length == 10) {
                contactNumber = '91$contactNumber';
              }
              return userPhoneNumbers.contains(contactNumber);
            })
            .map((contact) {
              String contactNumber = contact.phones.isNotEmpty ? contact.phones.first.number : '';
              contactNumber = contactNumber.replaceAll(RegExp(r'[^0-9]'), '');
              if (!contactNumber.startsWith('91') && contactNumber.length == 10) {
                contactNumber = '91$contactNumber';
              }
              String userId = '';
              for (var doc in userSnapshot.docs) {
                if ((doc.data() as Map<String, dynamic>)['mobileNumber'].replaceAll(RegExp(r'[^0-9]'), '') == contactNumber) {
                  userId = doc.id;
                  break;
                }
              }
              _contactUserIds[contact.displayName] = userId; // Store user ID
              return contact.displayName;
            })
            .toList();
        print('Filtered contacts: $_contacts'); // Add debug print
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

  void _navigateToQuippNow(String username, String receiverUserId) {
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
          receiverUserId: receiverUserId,
        ),
      ),
    );
  }

  void _navigateToQuipDisplay(String quip, String username) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuipDisplayPage(
          quip: quip,
          username: username,
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
        floatingActionButton: HeartFAB(
          user: widget.user,
        ),
      ),
    );
  }
}

class ConnectionsPageContent extends StatelessWidget {
  final User user;
  final bool isProfileIncomplete;
  final List<String> contacts;

  const ConnectionsPageContent({Key? key, 
    required this.user,
    required this.isProfileIncomplete,
    required this.contacts,
  }) : super(key: key);

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
      child: Column(
        children: <Widget>[
          if (isProfileIncomplete) ...[
            SizedBox(height: 20.0), // Add space from the top
            ProfileIncomplete(user: user, userName: user.displayName ?? ''),
          ],
          Expanded(
            child: contacts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.sentiment_dissatisfied_sharp, color: Colors.grey, size: 50.0), // Sad face icon
                        SizedBox(height: 10.0),
                        Text(
                          'No connections',
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
                      ...contacts.map((contact) {
                        String receiverUserId = parentState._contactUserIds[contact] ?? '';

                        return Material(
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
                                parentState._navigateToQuippNow(contact, receiverUserId);
                              },
                              child: Text('Quip now'),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
