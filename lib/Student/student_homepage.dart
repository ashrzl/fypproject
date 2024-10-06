import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project2/Model/Student/student_model.dart';
import 'package:project2/Student/student_class.dart';
import 'package:project2/Student/student_timetable.dart';
import 'studentlogin_page.dart';
import 'dart:io';

class StudentHomePage extends StatefulWidget {
  final String studentId;

  StudentHomePage({required this.studentId});

  @override
  _StudentHomePageState createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  Student? student;
  bool isLoading = true;
  final ImagePicker _picker = ImagePicker();
  File? _image;

  @override
  void initState() {
    super.initState();
    fetchStudentData();
  }

  Future<void> fetchStudentData() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('students')
          .doc(widget.studentId)
          .get();

      if (documentSnapshot.exists) {
        setState(() {
          student = Student.fromFirestore(documentSnapshot.data() as Map<String, dynamic>);
          isLoading = false;
        });
      } else {
        print('No such document!');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching student data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateStudentDetails(String newName, String newPhone, String newEmail, String newClassName) async {
    try {
      await FirebaseFirestore.instance
          .collection('students')
          .doc(widget.studentId)
          .update({
        'student_name': newName,
        'phone_number': newPhone,
        'email': newEmail,
        'class_name': newClassName,
      });

      await fetchStudentData();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Details updated successfully!'),
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pop(context);

    } catch (e) {
      print('Error updating details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update details.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> deleteAccount() async {
    try {
      bool confirmDelete = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirm Delete'),
            content: Text('Are you sure you want to delete your account? This action cannot be undone.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  await FirebaseFirestore.instance.collection('students').doc(widget.studentId).delete();
                  Navigator.of(context).pop(true);
                },
                child: Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          );
        },
      );

      if (confirmDelete == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => StudentLoginPage()),
        );
      }
    } catch (e) {
      print('Error deleting account: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete account.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('students/${widget.studentId}/profile.jpg');
      await storageRef.putFile(_image!);
      final imageUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('students')
          .doc(widget.studentId)
          .update({'image_url': imageUrl});

      await fetchStudentData();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile picture updated successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload image.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showUpdateDialog() {
    TextEditingController nameController = TextEditingController(text: student?.student_name ?? '');
    TextEditingController phoneController = TextEditingController(text: student?.phone_number ?? '');
    TextEditingController emailController = TextEditingController(text: student?.email ?? '');
    TextEditingController classnameController = TextEditingController(text: student?.class_name ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Details'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Student Name'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(labelText: 'Phone Number'),
                ),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: classnameController,
                  decoration: InputDecoration(labelText: 'Group'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: student != null
                  ? () {
                String newName = nameController.text;
                String newPhone = phoneController.text;
                String newEmail = emailController.text;
                String newClassName = classnameController.text;

                updateStudentDetails(newName, newPhone, newEmail, newClassName);
              }
                  : null,
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showChangePasswordDialog() {
    TextEditingController newPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Password'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: newPasswordController,
                  decoration: InputDecoration(labelText: 'New Password'),
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String newPassword = newPasswordController.text;
                try {
                  await FirebaseFirestore.instance
                      .collection('students')
                      .doc(widget.studentId)
                      .update({'password': newPassword});

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Password updated successfully!'),
                      duration: Duration(seconds: 2),
                    ),
                  );

                  Navigator.pop(context);

                } catch (e) {
                  print('Error updating password: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update password.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Text('Change'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Student Home Page',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF31473A),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Color(0xFFEDF4F2),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/headerbackground3.jpeg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Class List Generator',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 8),
                  Image.asset(
                    'assets/logo.png',
                    width: 100,
                    height: 100,
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.class_),
              title: Text('Class'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SubjectHomePage(studentId: widget.studentId)),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.schedule),
              title: Text('Timetable'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TimetablePage(studentId: widget.studentId),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.lock),
              title: Text('Change Password'),
              onTap: () {
                Navigator.pop(context);
                _showChangePasswordDialog();
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Delete Account'),
              onTap: () {
                deleteAccount();
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Log Out'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Logging out...'),
                    duration: Duration(seconds: 2),
                  ),
                );
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => StudentLoginPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : student != null
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: student!.image_url.isNotEmpty
                            ? NetworkImage(student!.image_url)
                            : AssetImage('assets/default_avatar.png') as ImageProvider,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap to update profile picture',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Welcome, ${student!.student_name}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Student ID: ${student!.student_id}',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 8),
              Text(
                'Email: ${student!.email}',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 8),
              Text(
                'Group: ${student!.class_name}',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 8),
              Text(
                'Phone Number: ${student!.phone_number}',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF31473A),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
                onPressed: _showUpdateDialog,
                child: Text(
                    'Update Details',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          )
              : Center(
            child: Text(
              'No data available for the provided student ID.',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}
