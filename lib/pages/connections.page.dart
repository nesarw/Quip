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
import 'package:quip/widget/connections_shimmer.dart';

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
  final Map<String, String> _contactUserIds = {};
  bool _isFetchingContacts = false;
  final List<Widget> _pages = [];
  bool _isInitialized = false;
  bool _isContactsPermissionDenied = false;

  @override
  void initState() {
    super.initState();
    print('ConnectionsPage: initState called');
    _checkProfileCompletion();
  }

  @override
  void dispose() {
    print('ConnectionsPage: dispose called');
    super.dispose();
  }

  Future<void> _checkProfileCompletion() async {
    if (_isInitialized) {
      print('ConnectionsPage: Skipping _checkProfileCompletion - already initialized');
      return;
    }

    print('ConnectionsPage: Starting _checkProfileCompletion');
    try {
      setState(() {
        _isLoading = true;
      });
      
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .get();
          
      if (!userDoc.exists) {
        print('ConnectionsPage: User document does not exist');
        setState(() {
          _isProfileIncomplete = true;
          _isLoading = false;
          _isInitialized = true;
        });
        return;
      }

      Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
      bool isIncomplete = data['dateOfBirth'] == null ||
                         data['gender'] == null ||
                         data['mobileNumber'] == null;
                         
      print('ConnectionsPage: Profile completion status: ${!isIncomplete}');
      
      setState(() {
        _isProfileIncomplete = isIncomplete;
      });
      
      // Initialize pages first
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
        _isInitialized = true;
      });

      // Only fetch contacts if profile is complete
      if (!isIncomplete && !_isFetchingContacts) {
        print('ConnectionsPage: Starting contact fetch');
        _fetchContactsInBackground();
      }
    } catch (e, stackTrace) {
      print('Error in _checkProfileCompletion: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _isLoading = false;
        _isProfileIncomplete = true;
        _isInitialized = true;
      });
    }
  }

  Future<void> _fetchContactsInBackground() async {
    if (_isFetchingContacts) {
      print('ConnectionsPage: Contact fetch already in progress');
      return;
    }
    
    print('ConnectionsPage: Starting _fetchContactsInBackground');
    setState(() {
      _isFetchingContacts = true;
    });

    try {
      if (!await FlutterContacts.requestPermission()) {
        print('ConnectionsPage: Contact permission denied');
        setState(() {
          _isFetchingContacts = false;
          _isContactsPermissionDenied = true;
        });
        return;
      }

      // Get current user's phone number first
      String currentUserPhoneNumber = '';
      DocumentSnapshot currentUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .get();
          
      if (currentUserDoc.exists) {
        currentUserPhoneNumber = (currentUserDoc.data() as Map<String, dynamic>)['mobileNumber'] as String? ?? '';
        currentUserPhoneNumber = currentUserPhoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
      }

      // Fetch contacts in chunks
      List<Contact> contacts = await FlutterContacts.getContacts(withProperties: true);
      print('ConnectionsPage: Fetched ${contacts.length} contacts from device');
      
      int chunkSize = 50;
      int totalContacts = contacts.length;
      
      // Create a map to store user phone numbers for faster lookup
      Map<String, String> phoneToUserId = {};
      
      // Fetch all users in one query and create a lookup map
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').get();
      print('ConnectionsPage: Fetched ${userSnapshot.docs.length} users from Firestore');
      
      for (var doc in userSnapshot.docs) {
        String phoneNumber = (doc.data() as Map<String, dynamic>)['mobileNumber'] as String? ?? '';
        phoneNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
        phoneToUserId[phoneNumber] = doc.id;
      }

      // Process contacts in chunks
      for (int i = 0; i < totalContacts; i += chunkSize) {
        if (!mounted) {
          print('ConnectionsPage: Widget no longer mounted, stopping contact processing');
          return;
        }

        int end = (i + chunkSize < totalContacts) ? i + chunkSize : totalContacts;
        List<Contact> chunk = contacts.sublist(i, end);
        
        List<String> newContacts = [];
        Map<String, String> newContactUserIds = {};

        for (var contact in chunk) {
          if (contact.phones.isEmpty) continue;
          
          String contactNumber = contact.phones.first.number;
          contactNumber = contactNumber.replaceAll(RegExp(r'[^0-9]'), '');
          
          if (!contactNumber.startsWith('91') && contactNumber.length == 10) {
            contactNumber = '91$contactNumber';
          }
          
          if (phoneToUserId.containsKey(contactNumber) && contactNumber != currentUserPhoneNumber) {
            newContacts.add(contact.displayName);
            newContactUserIds[contact.displayName] = phoneToUserId[contactNumber]!;
          }
        }

        // Update state with new contacts
        if (mounted) {
          setState(() {
            _contacts.addAll(newContacts);
            _contactUserIds.addAll(newContactUserIds);
            
            // Update the ConnectionsPageContent with new contacts
            _pages[0] = ConnectionsPageContent(
              user: widget.user,
              isProfileIncomplete: _isProfileIncomplete,
              contacts: _contacts,
            );
          });
        }
      }
      
      print('ConnectionsPage: Successfully processed ${_contacts.length} contacts');
    } catch (e, stackTrace) {
      print('Error in _fetchContacts: $e');
      print('Stack trace: $stackTrace');
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingContacts = false;
        });
      }
    }
  }

  void _onItemTapped(int index) {
    print('ConnectionsPage: Tab changed to index $index');
    setState(() {
      _selectedIndex = index;
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
    if (_isLoading && _selectedIndex == 0) {
      return Scaffold(
        body: ConnectionsShimmer(),
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            _onItemTapped(index);
          },
        ),
        floatingActionButton: HeartFAB(
          user: widget.user,
        ),
      );
    }

    if (_isContactsPermissionDenied && _selectedIndex == 0) {
      return Scaffold(
        body: Container(
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
                  Colors.black.withOpacity(0.4),
                ],
              ),
            ),
            child: Center(
              child: Container(
                margin: EdgeInsets.all(16.0),
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.no_accounts, color: Colors.white, size: 48.0),
                    SizedBox(height: 16.0),
                    Text(
                      'Please Allow Contacts for Connecting',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white, width: 2.0),
                      ),
                      onPressed: () {
                        setState(() {
                          _isContactsPermissionDenied = false;
                        });
                        _fetchContactsInBackground();
                      },
                      child: Text('Try Again'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            _onItemTapped(index);
          },
        ),
        floatingActionButton: HeartFAB(
          user: widget.user,
        ),
      );
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
              Colors.black.withOpacity(0.4),
            ],
          ),
        ),
        child: isProfileIncomplete
            ? Center(
                child: ProfileIncomplete(user: user, userName: user.displayName ?? ''),
              )
            : Column(
                children: <Widget>[
                  Expanded(
                    child: contacts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.sentiment_dissatisfied_sharp, color: Colors.grey, size: 50.0),
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
      ),
    );
  }
}
