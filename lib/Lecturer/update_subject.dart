import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateSubjectPage extends StatefulWidget {
  final String subjectId;

  UpdateSubjectPage({required this.subjectId});

  @override
  _UpdateSubjectPageState createState() => _UpdateSubjectPageState();
}

class _UpdateSubjectPageState extends State<UpdateSubjectPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectNameController = TextEditingController();
  final TextEditingController _subjectCodeController = TextEditingController();
  final TextEditingController _groupController = TextEditingController();
  final TextEditingController _lecturerNameController = TextEditingController();
  final TextEditingController _lecturerIdController = TextEditingController();
  final TextEditingController _classLinkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSubjectDetails();
  }

  Future<void> _fetchSubjectDetails() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('subjects').doc(widget.subjectId).get();

    if (doc.exists) {
      Map<String, dynamic> subjectData = doc.data() as Map<String, dynamic>;
      _subjectNameController.text = subjectData['subjectName'];
      _subjectCodeController.text = subjectData['subjectCode'];
      _groupController.text = subjectData['group'];
      _lecturerNameController.text = subjectData['lecturerName'];
      _lecturerIdController.text = subjectData['lecturerId'];
      _classLinkController.text = subjectData['classLink'];
    }
  }

  Future<void> _updateSubjectDetails() async {
    if (_formKey.currentState!.validate()) {
      // Update the subject details in Firestore
      Map<String, String> updatedSubjectDetails = {
        'subjectName': _subjectNameController.text,
        'subjectCode': _subjectCodeController.text,
        'group': _groupController.text,
        'lecturerName': _lecturerNameController.text,
        'lecturerId': _lecturerIdController.text,
        'classLink': _classLinkController.text,
      };

      await FirebaseFirestore.instance.collection('subjects').doc(widget.subjectId).update(updatedSubjectDetails);

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Subject details updated successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Update Subject',
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
                  decoration: InputDecoration(labelText: 'Subject Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the subject name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _subjectCodeController,
                  decoration: InputDecoration(labelText: 'Subject Code'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the subject code';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _groupController,
                  decoration: InputDecoration(labelText: 'Group'),
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
                  decoration: InputDecoration(labelText: 'Lecturer Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the lecturer name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _lecturerIdController,
                  decoration: InputDecoration(labelText: 'Lecturer Id'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the lecturer id';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _classLinkController,
                  decoration: InputDecoration(labelText: 'Class Link'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the class link';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF31473A),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                  onPressed: _updateSubjectDetails,
                  child: Text(
                    'Update',
                    style: TextStyle(color: Colors.white),
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
