import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:project2/Lecturer/pdf_viewscreen.dart';

class TimetableUpload extends StatefulWidget {
  final String lecturerId;
  TimetableUpload({required this.lecturerId});

  @override
  _TimetableUploadState createState() => _TimetableUploadState();
}

class _TimetableUploadState extends State<TimetableUpload> {
  File? _file;
  bool _isUploading = false;
  DocumentSnapshot? _existingTimetable;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkExistingFile();
  }

  Future<void> _checkExistingFile() async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('timetables')
        .where('lecturerId', isEqualTo: widget.lecturerId)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        _existingTimetable = querySnapshot.docs.first;
      });
    }
  }

  Future<void> _pickFile() async {
    if (await _requestPermission(Permission.storage)) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        setState(() {
          _file = file;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No file selected')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Storage permission denied')),
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

  Future<void> _deleteFile(String fileName, String docId) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('timetables/$fileName');
      await storageRef.delete();
      await FirebaseFirestore.instance.collection('timetables').doc(docId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File deleted successfully!')),
      );

      setState(() {
        _existingTimetable = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete file: $e')),
      );
    }
  }

  Future<void> _uploadFile() async {
    if (_file == null) return;

    if (_existingTimetable != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please delete the existing file first')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final fileName = _file!.path.split('/').last;
      final storageRef = FirebaseStorage.instance.ref().child('timetables/$fileName');
      await storageRef.putFile(_file!);
      final fileURL = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('timetables').add({
        'fileName': fileName,
        'fileURL': fileURL,
        'uploadDate': DateTime.now(),
        'lecturerId': widget.lecturerId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File uploaded successfully!')),
      );

      setState(() {
        _isUploading = false;
        _file = null;
        _checkExistingFile();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload file: $e')),
      );
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _handleBottomNavigationTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        _pickFile();
        break;
      case 1:
        if (_existingTimetable != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PDFViewerScreen(
                url: _existingTimetable!['fileURL'],
                lecturerId: '',
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No existing timetable to view')),
          );
        }
        break;
      case 2:
        if (_existingTimetable != null) {
          _deleteFile(_existingTimetable!['fileName'], _existingTimetable!.id);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No existing timetable to delete')),
          );
        }
        break;
      case 3:
        _uploadFile();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Timetable Upload',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF31473A),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Color(0xFFEDF4F2),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Lecturer can only upload maximum one file only',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              if (_existingTimetable != null)
                Column(
                  children: [
                    Text('Existing File: ${_existingTimetable!['fileName']}'),
                    SizedBox(height: 20),
                  ],
                ),
              if (_file != null)
                Text('Selected File: ${_file!.path.split('/').last}'),
              SizedBox(height: 20),
              _isUploading ? CircularProgressIndicator() : Container(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF31473A),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_file),
            label: 'Select PDF',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.visibility),
            label: 'View',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.delete),
            label: 'Delete',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud_upload),
            label: 'Upload',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: _handleBottomNavigationTap,
      ),
    );
  }
}
