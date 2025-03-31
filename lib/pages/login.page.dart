import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:quip/pages/user_profile.page.dart';
import 'package:quip/widget/button.dart';
import 'package:quip/widget/textLogin.dart';
import 'package:quip/widget/verticalText.dart';
import 'package:quip/pages/connections.page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _isImageLoaded = false;

  @override
  void initState() {
    super.initState();
    _checkUserSession();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _preloadImage();
  }

  Future<void> _preloadImage() async {
    if (!_isImageLoaded) {
      try {
        await precacheImage(AssetImage('assets/images/loginpagebg.jpg'), context);
        if (mounted) {
          setState(() {
            _isImageLoaded = true;
          });
        }
      } catch (e) {
        print('Error preloading image: $e');
      }
    }
  }

  Future<void> _checkUserSession() async {
    User? user = _auth.currentUser;
    if (user != null) {
      Future.microtask(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ConnectionsPage(user: user)),
        );
      });
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return; // The user canceled the sign-in
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          final userData = {
            'name': user.displayName,
            'email': user.email,
            'photoURL': user.photoURL,
          };

          await FirebaseFirestore.instance.collection('users').doc(user.uid).set(userData);
        }

        Future.microtask(() {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ConnectionsPage(user: user)),
          );
        });
      }
    } catch (e) {
      print('Failed to sign in with Google: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sign in with Google: ${e.toString()}'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.black,
        ),
        child: Stack(
          children: [
            if (_isImageLoaded)
              Container(
                width: double.infinity,
                height: double.infinity,
                child: Image.asset(
                  'assets/images/loginpagebg.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    print('Error loading image: $error');
                    return Container(
                      color: Colors.black,
                      child: Center(
                        child: Text(
                          'Error loading background',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.5),
                  ],
                ),
              ),
            ),
            ListView(
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          VerticalText(),
                          TextLogin(),
                        ],
                      ),
                      SizedBox(height:50),
                      GestureDetector(
                        onTap: _signInWithGoogle,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 25),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 1),
                            borderRadius: BorderRadius.circular(35),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Image.network(
                                'https://cdn-icons-png.flaticon.com/512/300/300221.png',
                                height: 25,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Sign In with Google',
                                style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}