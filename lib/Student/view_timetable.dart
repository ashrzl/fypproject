import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project2/Model/Student/timetable_model.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:project2/Student/update_timetable.dart';

class TimetableDisplayPage extends StatelessWidget {
  final String studentId;
  final List<String> daysOfWeek = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];
  final List<String> timeSlots = [
    '7:00 AM - 8:00 AM', '8:00 AM - 9:00 AM', '9:00 AM - 10:00 AM', '10:00 AM - 11:00 AM',
    '11:00 AM - 12:00 PM', '12:00 PM - 1:00 PM', '1:00 PM - 2:00 PM', '2:00 PM - 3:00 PM',
    '3:00 PM - 4:00 PM', '4:00 PM - 5:00 PM', '5:00 PM - 6:00 PM', '6:00 PM - 7:00 PM',
    '7:00 PM - 8:00 PM', '8:00 PM - 9:00 PM', '9:00 PM - 10:00 PM'
  ];

  TimetableDisplayPage({required this.studentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Timetable',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF31473A),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: () async {
              await _requestPermissions();
              final pdfFile = await _createPdf();
              if (pdfFile != null) {
                _openPdfFile(pdfFile);
              }
            },
            color: Colors.white,
          ),
        ],
      ),
      backgroundColor: Color(0xFFEDF4F2),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('timetable')
            .where('studentId', isEqualTo: studentId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No timetable entries found.'));
          }

          final data = snapshot.data!.docs.map((doc) {
            final timetableEntry = TimetableEntry.fromMap(doc.data() as Map<String, dynamic>, doc.id);
            return timetableEntry;
          }).toList();

          // Group by days and sort by time
          Map<String, List<TimetableEntry>> groupedData = {};
          for (var day in daysOfWeek) {
            groupedData[day] = [];
          }
          for (var entry in data) {
            final days = entry.days.split(',').map((day) => day.trim()).toList();
            for (var day in days) {
              final formattedDay = _formatDay(day);
              if (groupedData.containsKey(formattedDay)) {
                groupedData[formattedDay]!.add(entry);
              } else {
                print('Unexpected day: $day');
              }
            }
          }

          // Sort entries by start time for each day
          groupedData.forEach((day, entries) {
            entries.sort((a, b) {
              final aTime = _parseTime(a.startTime);
              final bTime = _parseTime(b.startTime);
              return aTime.compareTo(bTime);
            });
          });

          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(8.0),
                  children: groupedData.entries.map((entry) {
                    final day = entry.key;
                    final entries = entry.value;

                    if (entries.isEmpty) return SizedBox.shrink();

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            day,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ...entries.map((e) => Card(
                            margin: EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(e.subjectName),
                              subtitle: Text(
                                'Code: ${e.subjectCode}\n'
                                    'Group: ${e.group}\n'
                                    'Lecturer: ${e.lecturerName}\n'
                                    'Time: ${e.startTime} - ${e.endTime}\n'
                                    'Venue: ${e.venue}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => UpdateTimetablePage(timetableEntryId: e.id),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      _showDeleteConfirmationDialog(context, e.id);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          )),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Click the download icon to download the timetable',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String timetableEntryId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this timetable entry?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                await _deleteTimetableEntry(timetableEntryId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteTimetableEntry(String timetableEntryId) async {
    try {
      await FirebaseFirestore.instance
          .collection('timetable')
          .doc(timetableEntryId)
          .delete();
      print('Timetable entry deleted successfully.');
    } catch (e) {
      print('Error deleting timetable entry: $e');
    }
  }

  String _formatDay(String day) {
    switch (day.toLowerCase()) {
      case 'monday':
        return 'Monday';
      case 'tuesday':
        return 'Tuesday';
      case 'wednesday':
        return 'Wednesday';
      case 'thursday':
        return 'Thursday';
      case 'friday':
        return 'Friday';
      case 'saturday':
        return 'Saturday';
      case 'sunday':
        return 'Sunday';
      default:
        return day;
    }
  }

  DateTime _parseTime(String time) {
    try {
      final is12HourFormat = time.toLowerCase().contains('am') || time.toLowerCase().contains('pm');
      if (is12HourFormat) {
        final dateTime = DateFormat.jm().parse(time);
        return DateTime(0, 1, 1, dateTime.hour, dateTime.minute);
      }
      final parts = time.split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        return DateTime(0, 1, 1, hour, minute);
      }
      final partsShort = time.split(' ');
      if (partsShort.length == 2) {
        final hour = int.parse(partsShort[0]);
        final period = partsShort[1].toLowerCase();
        final isPM = period == 'pm';
        return DateTime(0, 1, 1, isPM ? (hour % 12) + 12 : hour % 12, 0);
      }
    } catch (e) {
      print('Error parsing time: $time. Error: $e');
    }
    return DateTime(0, 1, 1, 0, 0);
  }

  Future<void> _requestPermissions() async {
    if (await Permission.storage.request().isGranted) {
      print('Storage permission granted.');
    } else {
      print('Storage permission denied.');
    }
  }

  Future<File?> _createPdf() async {
    final pdf = pw.Document();
    try {
      // Fetch the timetable data
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('timetable')
          .where('studentId', isEqualTo: studentId)
          .get();
      final data = querySnapshot.docs.map((doc) {
        final timetableEntry = TimetableEntry.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        return timetableEntry;
      }).toList();

      // Group by days and sort by time
      Map<String, List<TimetableEntry>> groupedData = {};
      for (var day in daysOfWeek) {
        groupedData[day] = [];
      }
      for (var entry in data) {
        final days = entry.days.split(',').map((day) => day.trim()).toList();
        for (var day in days) {
          final formattedDay = _formatDay(day);
          if (groupedData.containsKey(formattedDay)) {
            groupedData[formattedDay]!.add(entry);
          } else {
            print('Unexpected day: $day');
          }
        }
      }

      // Sort entries by start time for each day
      groupedData.forEach((day, entries) {
        entries.sort((a, b) {
          final aTime = _parseTime(a.startTime);
          final bTime = _parseTime(b.startTime);
          return aTime.compareTo(bTime);
        });
      });

      // Create PDF content
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              children: [
                pw.Text(
                  'Timetable',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 20),
                pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: {
                    0: pw.IntrinsicColumnWidth(),
                    for (var i = 1; i < daysOfWeek.length + 1; i++) i: pw.FlexColumnWidth()
                  },
                  children: [
                    // Header Row with days of the week
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Time',
                            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        ...daysOfWeek.map((day) {
                          return pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              day,
                              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                              textAlign: pw.TextAlign.center,
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                    // Time Slot Rows
                    ...timeSlots.map((timeSlot) {
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              timeSlot,
                              style: pw.TextStyle(fontSize: 14),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          ...daysOfWeek.map((day) {
                            final entries = groupedData[day]!.where((entry) => entry.startTime == timeSlot.split('-')[0].trim()).toList();
                            if (entries.isEmpty) {
                              return pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(''),
                              );
                            } else {
                              final entry = entries[0];
                              return pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  '${entry.subjectName}\n'
                                      '(${entry.subjectCode})\n'
                                      'Time: ${entry.startTime} - ${entry.endTime}\n'
                                      'Venue: ${entry.venue}\n'
                                      'Lecturer: ${entry.lecturerName}',
                                  style: pw.TextStyle(fontSize: 12),
                                  textAlign: pw.TextAlign.left,
                                ),
                              );
                            }
                          }).toList(),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ],
            );
          },
        ),
      );

      // Save the PDF file
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/timetable.pdf');
      await file.writeAsBytes(await pdf.save());
      print('PDF created successfully.');
      return file;
    } catch (e) {
      print('Error creating PDF: $e');
      return null;
    }
  }

  void _openPdfFile(File file) {
    OpenFile.open(file.path).then((result) {
      print('PDF opened: $result');
    }).catchError((error) {
      print('Error opening PDF: $error');
    });
  }
}
