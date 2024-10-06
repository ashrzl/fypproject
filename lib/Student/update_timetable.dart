import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project2/Model/Student/timetable_model.dart';

class UpdateTimetablePage extends StatefulWidget {
  final String timetableEntryId;

  UpdateTimetablePage({required this.timetableEntryId});

  @override
  _UpdateTimetablePageState createState() => _UpdateTimetablePageState();
}

class _UpdateTimetablePageState extends State<UpdateTimetablePage> {
  final _formKey = GlobalKey<FormState>();
  late TimetableEntry _timetableEntry;
  bool _isLoading = true;

  final TextEditingController _subjectNameController = TextEditingController();
  final TextEditingController _subjectCodeController = TextEditingController();
  final TextEditingController _groupController = TextEditingController();
  final TextEditingController _lecturerNameController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _venueController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchTimetableEntry();
  }

  Future<void> _fetchTimetableEntry() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('timetable')
          .doc(widget.timetableEntryId)
          .get();

      _timetableEntry = TimetableEntry.fromMap(doc.data() as Map<String, dynamic>, doc.id);

      _subjectNameController.text = _timetableEntry.subjectName;
      _subjectCodeController.text = _timetableEntry.subjectCode;
      _groupController.text = _timetableEntry.group;
      _lecturerNameController.text = _timetableEntry.lecturerName;
      _startTimeController.text = _timetableEntry.startTime;
      _endTimeController.text = _timetableEntry.endTime;
      _venueController.text = _timetableEntry.venue;
      _daysController.text = _timetableEntry.days;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching timetable entry: $e');
    }
  }

  Future<void> _updateTimetableEntry() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance
            .collection('timetable')
            .doc(widget.timetableEntryId)
            .update({
          'subjectName': _subjectNameController.text,
          'subjectCode': _subjectCodeController.text,
          'group': _groupController.text,
          'lecturerName': _lecturerNameController.text,
          'startTime': _startTimeController.text,
          'endTime': _endTimeController.text,
          'venue': _venueController.text,
          'days': _daysController.text,
        });

        Navigator.of(context).pop();
      } catch (e) {
        print('Error updating timetable entry: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Timetable Entry'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
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
              TextFormField(
                controller: _startTimeController,
                decoration: InputDecoration(labelText: 'Start Time'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the start time';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _endTimeController,
                decoration: InputDecoration(labelText: 'End Time'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the end time';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _venueController,
                decoration: InputDecoration(labelText: 'Venue'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the venue';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _daysController,
                decoration: InputDecoration(labelText: 'Days (comma separated)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the days';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateTimetableEntry,
                child: Text('Update Timetable Entry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _subjectNameController.dispose();
    _subjectCodeController.dispose();
    _groupController.dispose();
    _lecturerNameController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _venueController.dispose();
    _daysController.dispose();
    super.dispose();
  }
}
