import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Add this import
import 'dart:io'; // Add this import

class EditProfilePage extends StatefulWidget {
  final User user;
  final String userName; // Add this parameter
  final String email; // Add this parameter

  EditProfilePage({
    required this.user,
    required this.userName, // Add this parameter
    required this.email, // Add this parameter
  });

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  int _selectedIndex = 2;
  String userName = 'John Doe';
  DateTime? selectedDate;
  String mobileNumber = '+91'; // Default country code included
  String gender = '';
  String? photoURL; // Add this variable
  File? _image; // Add this variable
  final TextEditingController _mobileController = TextEditingController(text: '+91'); // Initialize with +91
  late Future<void> _userDataFuture; // Add this variable

  final List<String> genders = ['Male', 'Female', 'Other', "Don't want to say"];

  @override
  void initState() {
    super.initState();
    userName = widget.userName; // Initialize with the passed userName
    _userDataFuture = _fetchUserData(); // Initialize the future
  }

  Future<void> _fetchUserData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.user.uid).get();
      if (userDoc.exists) {
        setState(() {
          userName = userDoc['name'] ?? widget.userName;
          selectedDate = userDoc['dateOfBirth'] != null ? DateTime.parse(userDoc['dateOfBirth']) : null;
          mobileNumber = userDoc['mobileNumber'] ?? '+91';
          gender = userDoc['gender'] ?? '';
          photoURL = userDoc['photoURL'];
          _mobileController.text = mobileNumber;
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.black87,
              onPrimary: Colors.white,
              surface: Colors.black87,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.black,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white, // Text color
                side: BorderSide(color: Colors.white), // Border color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (selectedDate == null || gender.isEmpty || mobileNumber == '+91' || mobileNumber.length != 13) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all the mandatory fields correctly.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Save the profile details to Firestore
    await FirebaseFirestore.instance.collection('users').doc(widget.user.uid).update({
      'dateOfBirth': selectedDate?.toLocal().toString().split(' ')[0],
      'mobileNumber': _mobileController.text,
      'gender': gender,
      if (_image != null) 'photoURL': _image!.path,
    });

    // Show a confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Profile updated successfully'),
        duration: Duration(seconds: 2),
      ),
    );

    // Redirect to connections page
    Navigator.pushReplacementNamed(context, '/connections');
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
      body: FutureBuilder(
        future: _userDataFuture, // Use the initialized future
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              color: Colors.black,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading user data',
                style: TextStyle(color: Colors.white),
              ),
            );
          } else {
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
                      Padding(
                        padding: const EdgeInsets.only(top: 50.0, left: 16.0, right: 16.0, bottom: 16.0),
                        child: Text(
                          'Edit Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: <Widget>[
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundImage: photoURL != null
                                      ? NetworkImage(photoURL!)
                                      : AssetImage('assets/profile_photo.jpg') as ImageProvider,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black,
                                    ),
                                    child: IconButton(
                                      icon: Icon(Icons.camera_alt, color: Colors.white),
                                      onPressed: () {
                                        showModalBottomSheet(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return SafeArea(
                                              child: Wrap(
                                                children: <Widget>[
                                                  ListTile(
                                                    leading: Icon(Icons.photo_library),
                                                    title: Text('Gallery'),
                                                    onTap: () {
                                                      _pickImage(ImageSource.gallery);
                                                      Navigator.of(context).pop();
                                                    },
                                                  ),
                                                  ListTile(
                                                    leading: Icon(Icons.photo_camera),
                                                    title: Text('Camera'),
                                                    onTap: () {
                                                      _pickImage(ImageSource.camera);
                                                      Navigator.of(context).pop();
                                                    },
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Name: $userName',
                                  style: TextStyle(color: Colors.white, fontSize: 18),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Email: ${widget.email}',
                                  style: TextStyle(color: Colors.white, fontSize: 18),
                                ),
                                SizedBox(height: 16),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                    side: BorderSide(color: Colors.white, width: 2.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                                  ),
                                  onPressed: _saveProfile,
                                  child: Text('Save Changes'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () => _selectDate(context),
                              child: AbsorbPointer(
                                child: TextField(
                                  controller: TextEditingController(
                                    text: selectedDate == null
                                        ? ''
                                        : "${selectedDate!.toLocal()}".split(' ')[0],
                                  ),
                                  style: TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    labelText: 'Date of Birth',
                                    labelStyle: TextStyle(color: Colors.white),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.white),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.black87),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            TextField(
                              controller: _mobileController,
                              keyboardType: TextInputType.phone,
                              maxLength: 13, // +91 followed by 10 digits
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                counterText: '',
                                labelText: 'Mobile Number',
                                labelStyle: TextStyle(color: Colors.white),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black87),
                                ),
                              ),
                              onTap: () {
                                if (!_mobileController.text.startsWith('+91')) {
                                  _mobileController.text = '+91';
                                }
                              },
                              onChanged: (value) {
                                setState(() {
                                  mobileNumber = value;
                                });
                              },
                            ),
                            SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: gender.isEmpty ? null : gender,
                              decoration: InputDecoration(
                                labelText: 'Gender',
                                labelStyle: TextStyle(color: Colors.white),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: gender.isEmpty ? Colors.black87 : Colors.white),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: gender.isEmpty ? Colors.black87 : Colors.white),
                                ),
                              ),
                              dropdownColor: Colors.black87,
                              style: TextStyle(color: Colors.white),
                              onChanged: (String? newValue) {
                                setState(() {
                                  gender = newValue!;
                                });
                              },
                              items: genders.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
