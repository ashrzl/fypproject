import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LecturerDetailsPage extends StatefulWidget {
  final String subjectCode;

  LecturerDetailsPage({required this.subjectCode});

  @override
  _LecturerDetailsPageState createState() => _LecturerDetailsPageState();
}

class _LecturerDetailsPageState extends State<LecturerDetailsPage> {
  Map<String, dynamic>? _lecturerDetails;

  @override
  void initState() {
    super.initState();
    _fetchLecturerDetails();
  }

  Future<void> _fetchLecturerDetails() async {
    try {
      // Fetch the subject data using the subject code
      DocumentSnapshot subjectSnapshot = await FirebaseFirestore.instance
          .collection('subjects')
          .doc(widget.subjectCode)
          .get();

      if (subjectSnapshot.exists) {
        final subjectData = subjectSnapshot.data() as Map<String, dynamic>?;

        if (subjectData != null && subjectData.containsKey('lecturerId')) {
          String lecturerId = subjectData['lecturerId'];

          // Fetch the lecturer details using the lecturer ID
          DocumentSnapshot lecturerSnapshot = await FirebaseFirestore.instance
              .collection('lecturers')
              .doc(lecturerId)
              .get();

          if (lecturerSnapshot.exists) {
            setState(() {
              _lecturerDetails = lecturerSnapshot.data() as Map<String, dynamic>?;
            });
          } else {
            setState(() {
              _lecturerDetails = null;
            });
            _showError('Lecturer not found');
          }
        } else {
          setState(() {
            _lecturerDetails = null;
          });
          _showError('Lecturer ID not found in subject document');
        }
      } else {
        setState(() {
          _lecturerDetails = null;
        });
        _showError('Subject not found');
      }
    } catch (e) {
      setState(() {
        _lecturerDetails = null;
      });
      _showError('An error occurred while fetching the lecturer details: $e');
      print('Error fetching lecturer details: $e'); // Detailed error logging
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lecturer Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF31473A),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Color(0xFFEDF4F2),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _lecturerDetails != null
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lecturer Image
            Center(
              child: _lecturerDetails!['image_url'] != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  _lecturerDetails!['image_url'],
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              )
                  : Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[300],
                ),
                child: Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.grey[600],
                ),
              ),
            ),
            SizedBox(height: 16),
            // Lecturer Details Table
            Expanded(
              child: SingleChildScrollView(
                child: Table(
                  border: TableBorder.all(color: Colors.grey, width: 1),
                  columnWidths: {
                    0: FlexColumnWidth(1),
                    1: FlexColumnWidth(2),
                  },
                  children: [
                    _buildTableRow('Lecturer Name:', _lecturerDetails!['lecturer_name'] ?? 'N/A'),
                    _buildTableRow('Room Number:', _lecturerDetails!['room_number'] ?? 'N/A'),
                    _buildTableRow('Phone Number:', _lecturerDetails!['phone_number'] ?? 'N/A'),
                    _buildTableRow('Email:', _lecturerDetails!['email'] ?? 'N/A'),
                  ],
                ),
              ),
            ),
          ],
        )
            : Center(child: CircularProgressIndicator()),
      ),
    );
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
