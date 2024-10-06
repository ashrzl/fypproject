import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project2/Lecturer/view_subject.dart';

class SubjectPage extends StatefulWidget {
  final String lecturerId;

  SubjectPage({required this.lecturerId});

  @override
  _SubjectPageState createState() => _SubjectPageState();
}

class _SubjectPageState extends State<SubjectPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectNameController = TextEditingController();
  final TextEditingController _subjectCodeController = TextEditingController();
  final TextEditingController _groupController = TextEditingController();
  final TextEditingController _lecturerNameController = TextEditingController();
  final TextEditingController _classLinkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Ensure text is always in uppercase
    _subjectNameController.addListener(() {
      String text = _subjectNameController.text.toUpperCase();
      if (text != _subjectNameController.text) {
        _subjectNameController.text = text;
        _subjectNameController.selection = TextSelection.fromPosition(
          TextPosition(offset: text.length),
        );
      }
    });

    _subjectCodeController.addListener(() {
      String text = _subjectCodeController.text.toUpperCase();
      if (text != _subjectCodeController.text) {
        _subjectCodeController.text = text;
        _subjectCodeController.selection = TextSelection.fromPosition(
          TextPosition(offset: text.length),
        );
      }
    });

    _groupController.addListener(() {
      String text = _groupController.text.toUpperCase();
      if (text != _groupController.text) {
        _groupController.text = text;
        _groupController.selection = TextSelection.fromPosition(
          TextPosition(offset: text.length),
        );
      }
    });
  }

  @override
  void dispose() {
    _subjectNameController.dispose();
    _subjectCodeController.dispose();
    _groupController.dispose();
    _lecturerNameController.dispose();
    _classLinkController.dispose();
    super.dispose();
  }

  Future<void> _submitForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      Map<String, String> subjectDetails = {
        'subjectName': _subjectNameController.text,
        'subjectCode': _subjectCodeController.text,
        'group': _groupController.text,
        'lecturerName': _lecturerNameController.text,
        'lecturerId': widget.lecturerId,
        'classLink': _classLinkController.text,
      };

      try {
        await FirebaseFirestore.instance
            .collection('subjects')
            .doc(_subjectCodeController.text)
            .set(subjectDetails);

        // Clear the fields after submission
        _subjectNameController.clear();
        _subjectCodeController.clear();
        _groupController.clear();
        _lecturerNameController.clear();
        _classLinkController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Subject details submitted successfully!')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ViewSubjectsPage(lecturerId: widget.lecturerId),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit subject details: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Subject Page',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF31473A),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Color(0xFFEDF4F2),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _subjectNameController,
                  decoration: InputDecoration(
                    labelText: 'Course Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the course name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _subjectCodeController,
                  decoration: InputDecoration(
                    labelText: 'Course Code',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the course code';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _groupController,
                  decoration: InputDecoration(
                    labelText: 'Group',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the group';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
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
                      return 'Please enter the lecturer name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _classLinkController,
                  decoration: InputDecoration(
                    labelText: 'Class Link',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the class link';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _submitForm(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF31473A),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                  child: Text(
                    'Submit',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF31473A),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewSubjectsPage(lecturerId: widget.lecturerId),
                      ),
                    );

                  },
                  child: Text(
                    'View Subjects',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
