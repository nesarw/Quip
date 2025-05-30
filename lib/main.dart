import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quip/pages/login.page.dart';
import 'package:quip/pages/connections.page.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'dart:async';

void main() async {
  try {
    WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
    
    await Firebase.initializeApp();
    print('Firebase initialized successfully');
    
    // Remove splash screen after initialization
    FlutterNativeSplash.remove();
    
    runApp(MyApp());
  } catch (e, stackTrace) {
    print('Error initializing Firebase: $e');
    print('Stack trace: $stackTrace');
    // Show error UI instead of crashing
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Error initializing app. Please try again later.'),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    return MaterialApp(
      title: 'Quip',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: currentUser != null
          ? ConnectionsPage(user: currentUser)
          : LoginPage(),
      routes: {
        '/connections': (context) => ConnectionsPage(user: FirebaseAuth.instance.currentUser!),
      },
    );
  }
}