import 'package:flutter/material.dart';
import 'package:quip/widget/bottom_navigation_bar.dart'; // Add this import
import 'package:quip/pages/quipp_inbox.page.dart'; // Add this import
import 'package:quip/pages/user_profile.page.dart'; // Add this import
import 'package:quip/pages/quipp_now.page.dart'; // Add this import

class ConnectionsPage extends StatefulWidget {
  @override
  _ConnectionsPageState createState() => _ConnectionsPageState();
}

class _ConnectionsPageState extends State<ConnectionsPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    ConnectionsPageContent(),
    QuippInboxPage(),
    UserProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
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
              MaterialPageRoute(builder: (context) => ConnectionsPage()),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Disable back navigation
      child: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}

class ConnectionsPageContent extends StatelessWidget {
  final List<String> connections = [
    'Aarav Sharma',
    'Vivaan Patel',
    'Aditya Singh',
    'Vihaan Gupta',
    'Arjun Kumar',
    'Sai Reddy',
    'Reyansh Verma',
    'Ayaan Mehta',
    'Krishna Joshi',
    'Ishaan Nair',
    'Shaurya Rao',
    'Atharv Iyer',
    'Dhruv Desai',
    'Kabir Chatterjee',
    'Ritvik Bhatt',
  ];

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
            crossAxisAlignment: CrossAxisAlignment.start, // Align to the left
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 50.0, left: 16.0, right: 16.0, bottom: 16.0), // Add margin from the top
                child: Text(
                  'Connections',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              ...connections.map((user) => Material(
                color: Colors.transparent, // Make the Material widget transparent
                child: ListTile(
                  title: Text(
                    user,
                    style: TextStyle(color: Colors.white),
                  ),
                  leading: Icon(Icons.person, color: Colors.white),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black, // Set button color to black
                      foregroundColor: Colors.white, // Set text color to white
                      side: BorderSide(color: Colors.white, width: 2.0), // Add white outline
                    ),
                    onPressed: () {
                      parentState._navigateToQuippNow(user);
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
