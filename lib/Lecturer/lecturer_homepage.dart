import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:project2/Model/Lecturer/lecturer_model.dart';
import 'lecturer_subjectpage.dart';
import 'lecturer_timetable.dart';
import 'lecturerlogin_page.dart';

class LecturerHomePage extends StatefulWidget {
  final String lecturerId;

  LecturerHomePage({required this.lecturerId});

  @override
  _LecturerHomePageState createState() => _LecturerHomePageState();
}

class _LecturerHomePageState extends State<LecturerHomePage> {
  Lecturer? lecturer;
  bool isLoading = true;
  final ImagePicker _picker = ImagePicker();
  File? _image;

  @override
  void initState() {
    super.initState();
    fetchLecturerData();
  }

  Future<void> fetchLecturerData() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('lecturers')
          .doc(widget.lecturerId)
          .get();

      if (documentSnapshot.exists) {
        setState(() {
          lecturer = Lecturer.fromFirestore(documentSnapshot.data() as Map<String, dynamic>);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching lecturer data: $e');
    }
  }

  Future<void> updateLecturerDetails(String newName, String newPhone, String newEmail, String newRoomNumber) async {
    try {
      await FirebaseFirestore.instance
          .collection('lecturers')
          .doc(widget.lecturerId)
          .update({
        'lecturer_name': newName,
        'phone_number': newPhone,
        'email': newEmail,
        'room_number': newRoomNumber,
      });

      await fetchLecturerData();

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
                  await FirebaseFirestore.instance.collection('lecturers').doc(widget.lecturerId).delete();
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
          MaterialPageRoute(builder: (context) => LecturerLoginPage()),
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
    if (await _requestPermission(Permission.storage)) {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
        await _uploadImage();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Storage permission denied')),
      );
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('lecturers/${widget.lecturerId}/profile.jpg');
      await storageRef.putFile(_image!);
      final imageUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('lecturers')
          .doc(widget.lecturerId)
          .update({'image_url': imageUrl});

      await fetchLecturerData();

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

  Future<bool> _requestPermission(Permission permission) async {
    AndroidDeviceInfo build = await DeviceInfoPlugin().androidInfo;
    if (build.version.sdkInt >= 30) {
      var result = await Permission.manageExternalStorage.request();
      return result.isGranted;
    } else {
      if (await permission.isGranted) {
        return true;
      } else {
        var result = await permission.request();
        return result.isGranted;
      }
    }
  }

  void _showUpdateDialog() {
    TextEditingController nameController = TextEditingController(text: lecturer?.lecturer_name ?? '');
    TextEditingController phoneController = TextEditingController(text: lecturer?.phone_number ?? '');
    TextEditingController emailController = TextEditingController(text: lecturer?.email ?? '');
    TextEditingController roomnumberController = TextEditingController(text: lecturer?.room_number ?? '');

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
                  decoration: InputDecoration(labelText: 'Lecturer Name'),
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
                  controller: roomnumberController,
                  decoration: InputDecoration(labelText: 'Room Number'),
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
              onPressed: lecturer != null
                  ? () {
                String newName = nameController.text;
                String newPhone = phoneController.text;
                String newEmail = emailController.text;
                String newRoomNumber = roomnumberController.text;

                updateLecturerDetails(newName, newPhone, newEmail, newRoomNumber);
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
                      .collection('lecturers')
                      .doc(widget.lecturerId)
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
          'Lecturer Home Page',
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
                  MaterialPageRoute(builder: (context) => SubjectPage(lecturerId: widget.lecturerId)),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.schedule),
              title: Text('Upload Timetable'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TimetableUpload(lecturerId: widget.lecturerId),
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
                  MaterialPageRoute(builder: (context) => LecturerLoginPage()),
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
              : lecturer != null
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
                        backgroundImage: lecturer!.image_url.isNotEmpty
                            ? NetworkImage(lecturer!.image_url)
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
                'Welcome, ${lecturer!.lecturer_name}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Lecturer ID: ${lecturer!.lecturer_id}',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 8),
              Text(
                'Email: ${lecturer!.email}',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 8),
              Text(
                'Room Number: ${lecturer!.room_number}',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 8),
              Text(
                'Phone Number: ${lecturer!.phone_number}',
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
              'No data available for the provided lecturer ID.',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}
