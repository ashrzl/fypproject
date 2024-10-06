import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'lecturerlogin_page.dart';

class LecturerSignupPage extends StatefulWidget {
  @override
  _LecturerSignupPageState createState() => _LecturerSignupPageState();
}

class _LecturerSignupPageState extends State<LecturerSignupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _lecturerNameController = TextEditingController();
  final TextEditingController _lecturerIdController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _roomNumberController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _image;

  @override
  void dispose() {
    _lecturerNameController.dispose();
    _lecturerIdController.dispose();
    _emailController.dispose();
    _roomNumberController.dispose();
    _phoneNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Sign up the user with Firebase Authentication
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        User? user = userCredential.user;
        if (user != null) {
          // Upload profile picture if available
          String? imageUrl;
          if (_image != null) {
            final storageRef = FirebaseStorage.instance
                .ref()
                .child('lecturers/${_lecturerIdController.text}/profile.jpg');
            await storageRef.putFile(_image!);
            imageUrl = await storageRef.getDownloadURL();
          }

          // Save lecturer data in Firestore
          await FirebaseFirestore.instance.collection('lecturers').doc(_lecturerIdController.text).set({
            'lecturer_name': _lecturerNameController.text,
            'lecturer_id': _lecturerIdController.text,
            'email': _emailController.text,
            'room_number': _roomNumberController.text,
            'phone_number': _phoneNumberController.text,
            'password': _passwordController.text,
            'image_url': imageUrl ?? '',
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Signup Successful')),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LecturerLoginPage()),
          );
        }
      } catch (e) {
        print('Signup error: $e'); // Debugging statement
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred. Please try again.')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _takePicture() async {
    final XFile? takenPicture = await _picker.pickImage(source: ImageSource.camera);
    if (takenPicture != null) {
      setState(() {
        _image = File(takenPicture.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lecturer Signup',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF31473A),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Color(0xFFEDF4F2),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              Center(
                child: GestureDetector(
                  onTap: () => _showImageSourceDialog(context),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _image != null
                        ? FileImage(_image!)
                        : AssetImage('assets/default_avatar.png') as ImageProvider,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Center(
                child: Text(
                  'Tap to upload profile picture',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _lecturerNameController,
                decoration: InputDecoration(
                  labelText: 'Lecturer Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  // Ensure name is in all capital letters
                  if (value != value.toUpperCase()) {
                    return 'Name must be in all capital letters';
                  }
                  // Ensure name contains at least two parts (first and last name)
                  if (!value.contains(' ') || value.split(' ').length < 2) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _lecturerIdController,
                decoration: InputDecoration(
                  labelText: 'Lecturer ID',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your lecturer ID';
                  } else if (value.length != 6) {
                    return 'Lecturer ID must be exactly 10 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  // Regular expression for email validation
                  String pattern = r'^[^@]+@[^@]+\.[^@]+';
                  RegExp regex = RegExp(pattern);
                  if (!regex.hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _roomNumberController,
                decoration: InputDecoration(
                  labelText: 'Room Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your room number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _phoneNumberController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  // Regular expression for digits only and 11 digits or less
                  String pattern = r'^\d{1,11}$';
                  RegExp regex = RegExp(pattern);
                  if (!regex.hasMatch(value)) {
                    return 'Please enter a valid phone number with 11 digits or less';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF31473A),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
                onPressed: _signup,
                child: Text(
                  'Signup',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Choose Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.camera),
              title: Text('Take a picture'),
              onTap: () {
                Navigator.pop(context);
                _takePicture();
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Pick from gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
          ],
        ),
      ),
    );
  }
}
