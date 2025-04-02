import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quip/pages/user_profile.page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quip/pages/login.page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class MenuPage extends StatelessWidget {
  final User user;

  const MenuPage({Key? key, required this.user}) : super(key: key);

  Future<void> _launchURL(BuildContext context, String url) async {
    try {
      final Uri uri = Uri.parse(url);
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      print('Error launching URL: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open the link. Please try again later.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();
      
      // Clear shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      // Navigate to login page and clear all previous routes
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false,
      );
    } catch (e) {
      print('Error during logout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during logout. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                Colors.black.withOpacity(0.5),
              ],
            ),
          ),
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 50.0, left: 16.0, right: 16.0, bottom: 16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    SizedBox(width: 16),
                    Text(
                      'Menu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.info_outline, color: Colors.white),
                title: Text('About Us', style: TextStyle(color: Colors.white)),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: Colors.black87,
                        title: Text('About Us', style: TextStyle(color: Colors.white)),
                        content: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome to Quip – the next-generation social networking app designed to bring meaningful, anonymous interactions between people you know. Our mission is to enable unique, thoughtful, and engaging conversations while maintaining user privacy and control over their digital interactions.\n',
                                style: TextStyle(color: Colors.white),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Our Vision',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'We believe that communication should be effortless, fun, and safe. Quip bridges the gap between anonymity and authenticity, allowing users to send predefined messages, express thoughts, and interact with their contacts in a fresh, innovative way.\n',
                                style: TextStyle(color: Colors.white),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Why Quip?',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '• Connect with Familiar Faces: Engage with people in your contact list without the pressure of revealing your identity immediately.\n\n'
                                '• Predefined Messaging: Choose from curated messages to share your thoughts, reducing the stress of composing perfect words.\n\n'
                                '• Controlled Identity Reveal: Recipients can reveal the sender\'s identity only up to 10 times per month, adding a layer of mystery and excitement.\n\n'
                                '• Privacy & Security First: Your data and interactions remain protected with our strict privacy measures.\n',
                                style: TextStyle(color: Colors.white),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Join us in redefining social networking. Whether it\'s sharing a compliment, a witty remark, or an anonymous thought, Quip makes digital conversations fun and safe.\n',
                                style: TextStyle(color: Colors.white),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'For inquiries, partnerships, or support, reach out to us at:\n'
                                'nesar.w.official@gmail.com',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Close', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.privacy_tip_outlined, color: Colors.white),
                title: Text('Privacy Policy', style: TextStyle(color: Colors.white)),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: Colors.black87,
                        title: Text('Privacy Policy', style: TextStyle(color: Colors.white)),
                        content: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Effective Date: 2nd April 2025\n',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '1. Introduction:\n',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Welcome to Quip! Your privacy is important to us. This Privacy Policy explains how we collect, use, and protect your personal data when you use our mobile application ("App"). By using the App, you agree to the terms outlined in this policy.\n',
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                '2. Information We Collect:\n',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'We collect the following types of information when you use the App:\n\n'
                                '• Personal Information: Name, email address, phone number (if provided during account creation).\n\n'
                                '• Contacts Information: We access your device\'s contacts (with permission) to display connections within the App.\n\n'
                                '• Messages & Activity: Predefined messages sent within the App, frequency of interactions, and reveal counts.\n\n'
                                '• Device Information: Device type, OS version, IP address, and app usage analytics.\n\n'
                                '• Cookies & Tracking Data: We use cookies and similar tracking technologies for analytics and app performance.\n',
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                '3. How We Use Your Information:\n',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'We use your information for the following purposes:\n\n'
                                '• To provide, maintain, and improve the App\'s functionality.\n\n'
                                '• To connect you with your contacts and facilitate anonymous messaging.\n\n'
                                '• To track and enforce message update limits and identity reveal counts.\n\n'
                                '• To send security alerts, app updates, and account notifications.\n\n'
                                '• To comply with legal obligations and prevent fraudulent activities.\n',
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                '4. Data Sharing & Disclosure:\n',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'We do not sell your personal data. However, we may share information with:\n\n'
                                '• Service Providers: Third-party vendors who assist with hosting, analytics, and security.\n\n'
                                '• Legal Compliance: If required by law, court order, or government request.\n\n'
                                '• Business Transfers: In case of a merger, acquisition, or asset sale, your data may be transferred.\n',
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                '5. Data Security:\n',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'We implement industry-standard security measures to protect your data from unauthorized access, misuse, or loss. However, no method of transmission over the internet is 100% secure.\n',
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                '6. Your Rights & Choices:\n',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '• You can access, update, or delete your personal information via the App settings.\n\n'
                                '• You can revoke contact access permissions at any time via your device settings.\n\n'
                                '• You have the right to opt out of analytics and marketing communications.\n',
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                '7. Children\'s Privacy:\n',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'The App is not intended for individuals under the age of 16. We do not knowingly collect personal data from children.\n',
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                '8. Changes to This Privacy Policy:\n',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'We may update this policy periodically. We will notify users of significant changes through in-app notifications or email.\n',
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                '9. Contact Us:\n',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'If you have any questions or concerns about this Privacy Policy, please contact us at:\n'
                                'Email: nesar.w.official@gmail.com\n'
                                'Website: https://nesarw.netlify.app/',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Close', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.help, color: Colors.white),
                title: Text('Help & Support', style: TextStyle(color: Colors.white)),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: Colors.black87,
                        title: Text('Help & Support', style: TextStyle(color: Colors.white)),
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Need help? Visit our website for support!',

                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                              SizedBox(height: 20),
                              Text(
                                'https://nesarw.netlify.app/',

                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Close', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.white),
                title: Text('Logout', style: TextStyle(color: Colors.white)),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: Colors.black87,
                        title: Text('Logout', style: TextStyle(color: Colors.white)),
                        content: Text(
                          'Are you sure you want to logout?',
                          style: TextStyle(color: Colors.white),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Cancel', style: TextStyle(color: Colors.white)),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _handleLogout(context);
                            },
                            child: Text('Logout', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
} 