import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project2/Model/Lecturer/subject_model.dart';
import 'package:project2/Student/lecturer_details.dart';
import 'package:project2/Student/student_homepage.dart';
import 'package:project2/Student/student_timetable.dart';
import 'package:url_launcher/url_launcher.dart';

class SubjectHomePage extends StatefulWidget {
  final String studentId;

  SubjectHomePage({required this.studentId});

  @override
  _SubjectHomePageState createState() => _SubjectHomePageState();
}

class _SubjectHomePageState extends State<SubjectHomePage> {
  final TextEditingController _subjectCodeController = TextEditingController();
  final List<Subject> _subjects = [];

  @override
  void initState() {
    super.initState();

    // Ensure text is always in uppercase
    _subjectCodeController.addListener(() {
      String text = _subjectCodeController.text.toUpperCase();
      if (text != _subjectCodeController.text) {
        _subjectCodeController.text = text;
        _subjectCodeController.selection = TextSelection.fromPosition(
          TextPosition(offset: text.length),
        );
      }
    });
  }

  void _addSubject() async {
    String subjectCode = _subjectCodeController.text;
    if (subjectCode.isEmpty) return;

    try {
      DocumentSnapshot subjectSnapshot = await FirebaseFirestore.instance
          .collection('subjects')
          .doc(subjectCode)
          .get();

      if (subjectSnapshot.exists) {
        Map<String, dynamic> subjectData = subjectSnapshot.data() as Map<String, dynamic>;
        setState(() {
          _subjects.add(Subject.fromFirestore(subjectCode, subjectData));
          _subjectCodeController.clear();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Subject not found!'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching subject data: $e'),
        ),
      );
    }
  }

  Future<void> _launchURL(String url) async {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not launch $url'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Class List Generator for ODL',
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
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => StudentHomePage(studentId: widget.studentId)),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.schedule),
              title: Text('Timetable'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TimetablePage(studentId: '',)),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Text(
                'CLASS LIST',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _subjectCodeController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter Course Code',
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF31473A),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
                onPressed: _addSubject,
                child: Text(
                  'ADD',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _subjects.length,
                itemBuilder: (context, index) {
                  Subject subject = _subjects[index];
                  return Card(
                    child: ListTile(
                      title: Text(subject.subjectName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Code: ${subject.subjectCode}'),
                          Text('Group: ${subject.group}'),
                          Text('Lecturer: ${subject.lecturerName}'),
                          SizedBox(height: 8),
                          Text('Class Link:'),
                          InkWell(
                            onTap: () => _launchURL(subject.classLink),
                            child: Text(
                              subject.classLink,
                              style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.info),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LecturerDetailsPage(subjectCode: subject.subjectCode),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
