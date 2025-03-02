import 'package:flutter/material.dart';
import 'package:quip/pages/quipp_inbox.page.dart'; // Add this import
import 'package:quip/pages/user_profile.page.dart'; // Add this import

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({Key? key, required this.currentIndex, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(0.0), // Add spacing around the navigation bar
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7), // Black with 50% opacity
        border: Border.all(
          color: Colors.black.withOpacity(0.1), // Black border with 10% opacity
          width: 0.0,
        ),
        boxShadow: [
          BoxShadow(
            // color: Colors.black.withOpacity(0.5),
            spreadRadius: 7,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50.0), // Ensure the child is clipped to the circular shape
        child: BottomNavigationBar(
          backgroundColor: Colors.black.withOpacity(0.1), // Black with 50% opacity
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: false, // Hide labels
          showUnselectedLabels: false, // Hide labels
          currentIndex: currentIndex,
          onTap: (index) {
            onTap(index);
            if (index == 2) {
              Navigator.pushReplacementNamed(context, '/user_profile');
            }
          },
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home, size: 30), // Increase icon size
              label: '', // Remove label
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inbox_outlined, size: 35), // Increase icon size
              label: '', // Remove label
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, size: 30), // Increase icon size
              label: '', // Remove label
            ),
          ],
        ),
      ),
    );
  }
}
