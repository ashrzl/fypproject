import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:project2/Student/view_timetable.dart';  // Ensure this import is correct

class TimetablePage extends StatefulWidget {
  final String studentId;

  TimetablePage({required this.studentId});

  @override
  _TimetablePageState createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  final _formKey = GlobalKey<FormState>();
  final _subjectNameController = TextEditingController();
  final _subjectCodeController = TextEditingController();
  final _groupController = TextEditingController();
  final _lecturerNameController = TextEditingController();
  final _daysController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _venueController = TextEditingController();

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  @override
  void dispose() {
    _subjectNameController.dispose();
    _subjectCodeController.dispose();
    _groupController.dispose();
    _lecturerNameController.dispose();
    _daysController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _venueController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(TimeOfDay initialTime, Function(TimeOfDay) onTimeSelected) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null && picked != initialTime) {
      onTimeSelected(picked);
      final formattedTime = formatTimeOfDay(picked);
      setState(() {
        if (onTimeSelected == _selectStartTime) {
          _startTimeController.text = formattedTime;
        } else {
          _endTimeController.text = formattedTime;
        }
      });
    }
  }

  void _selectStartTime(TimeOfDay picked) {
    setState(() {
      _startTime = picked;
    });
  }

  void _selectEndTime(TimeOfDay picked) {
    setState(() {
      _endTime = picked;
    });
  }

  String formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format = DateFormat.jm();
    return format.format(dt);
  }

  void _addTimetableEntry() {
    if (_formKey.currentState!.validate()) {
      final timetableEntry = {
        'studentId': widget.studentId,
        'subjectName': _subjectNameController.text.toUpperCase(),
        'subjectCode': _subjectCodeController.text.toUpperCase(),
        'group': _groupController.text.toUpperCase(),
        'lecturerName': _lecturerNameController.text.toUpperCase(),
        'days': _daysController.text.toUpperCase(),
        'startTime': _startTimeController.text.toUpperCase(),
        'endTime': _endTimeController.text.toUpperCase(),
        'venue': _venueController.text.toUpperCase(),
      };

      FirebaseFirestore.instance.collection('timetable').add(timetableEntry).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Timetable entry added successfully!'),
            duration: Duration(seconds: 2),
          ),
        );

        // Optionally clear the fields after saving
        _subjectNameController.clear();
        _subjectCodeController.clear();
        _groupController.clear();
        _lecturerNameController.clear();
        _daysController.clear();
        _startTimeController.clear();
        _endTimeController.clear();
        _venueController.clear();
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add timetable entry: $error'),
            duration: Duration(seconds: 2),
          ),
        );
      });
    }
  }

  void _navigateToTimetableDisplayPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TimetableDisplayPage(studentId: widget.studentId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Timetable Entry',
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
              TextFormField(
                controller: _subjectNameController,
                decoration: InputDecoration(
                    labelText: 'Course Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    )
                ),
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Z\s]'))],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the course name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _subjectCodeController,
                decoration: InputDecoration(
                    labelText: 'Course Code',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    )
                ),
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]'))],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the course code';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _groupController,
                decoration: InputDecoration(
                    labelText: 'Group',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    )
                ),
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]'))],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the group';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _lecturerNameController,
                decoration: InputDecoration(
                    labelText: 'Lecturer Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    )
                ),
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Z\s]'))],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the lecturer name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _daysController,
                decoration: InputDecoration(
                    labelText: 'Days',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    )
                ),
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Z,\s]'))],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the days';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _startTimeController,
                decoration: InputDecoration(
                  labelText: 'Start Time',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.access_time),
                    onPressed: () => _selectTime(TimeOfDay.now(), _selectStartTime),
                  ),
                ),
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select the start time';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _endTimeController,
                decoration: InputDecoration(
                  labelText: 'End Time',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.access_time),
                    onPressed: () => _selectTime(TimeOfDay.now(), _selectEndTime),
                  ),
                ),
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select the end time';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _venueController,
                decoration: InputDecoration(
                    labelText: 'Venue',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    )
                ),
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9\s]'))],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the venue';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addTimetableEntry,
                child: Text(
                  'Add Timetable Entry',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF31473A),
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _navigateToTimetableDisplayPage,
                child: Text(
                  'View Timetable',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF31473A),
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
