import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Add this import
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quip/widget/bottom_navigation_bar.dart';
import 'dart:io'; // Add this import

class EditProfilePage extends StatefulWidget {
  final User user;

  EditProfilePage({required this.user});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  int _selectedIndex = 2;
  String userName = 'John Doe';
  DateTime? selectedDate;
  String mobileNumber = '+91'; // Default country code included
  String gender = '';
  File? _image; // Add this variable
  final TextEditingController _mobileController = TextEditingController(text: '+91'); // Initialize with +91

  final List<String> genders = ['Male', 'Female', 'Other', "Don't want to say"];


  @override
  void initState() {
    super.initState();
    _checkUserDataInDatabase();
  }

  Future<void> _checkUserDataInDatabase() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.user.uid).get();
    if (userDoc.exists) {
      _loadUserData();
    } else {
      _fetchUserData();
    }
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedName = prefs.getString('userName');
    String? cachedDateOfBirth = prefs.getString('dateOfBirth');
    String? cachedMobileNumber = prefs.getString('mobileNumber');
    String? cachedGender = prefs.getString('gender');
    String? cachedPhotoURL = prefs.getString('photoURL');

    if (cachedName != null) {
      setState(() {
        userName = cachedName;
      });
    }

    if (cachedDateOfBirth != null) {
      setState(() {
        selectedDate = DateTime.parse(cachedDateOfBirth);
      });
    }

    if (cachedMobileNumber != null) {
      setState(() {
        mobileNumber = cachedMobileNumber;
        _mobileController.text = cachedMobileNumber;
      });
    }

    if (cachedGender != null) {
      setState(() {
        gender = cachedGender;
      });
    }

    if (cachedPhotoURL != null) {
      setState(() {
        _image = File(cachedPhotoURL);
      });
    }
  }

  Future<void> _fetchUserData() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.user.uid).get();
    if (userDoc.exists) {
      setState(() {
        userName = userDoc['name'];
        selectedDate = userDoc['dateOfBirth'] != null ? DateTime.parse(userDoc['dateOfBirth']) : null;
        mobileNumber = userDoc['mobileNumber'] ?? '+91';
        gender = userDoc['gender'] ?? '';
        _mobileController.text = mobileNumber;
        if (userDoc['photoURL'] != null) {
          _image = File(userDoc['photoURL']);
        }
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('userName', userName);
      prefs.setString('dateOfBirth', selectedDate?.toLocal().toString().split(' ')[0] ?? '');
      prefs.setString('mobileNumber', mobileNumber);
      prefs.setString('gender', gender);
      if (_image != null) {
        prefs.setString('photoURL', _image!.path);
      }
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

    // Save the profile details to SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', userName);
    await prefs.setString('dateOfBirth', selectedDate?.toLocal().toString().split(' ')[0] ?? '');
    await prefs.setString('mobileNumber', mobileNumber);
    await prefs.setString('gender', gender);
    if (_image != null) {
      await prefs.setString('photoURL', _image!.path);
    }

    // Show a confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Profile updated successfully'),
        duration: Duration(seconds: 2),
      ),
    );
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
      body: Container(
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
                            backgroundImage: _image == null
                                ? AssetImage('assets/profile_photo.jpg')
                                : FileImage(_image!) as ImageProvider,
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
                            'Email: ${widget.user.email}',
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
      ),
    );
  }
}
