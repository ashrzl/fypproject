class TimetableEntry {
  String id;
  String subjectName;
  String subjectCode;
  String startTime;
  String endTime;
  String venue;
  String lecturerName;
  String days;
  String group;


  TimetableEntry({
    required this.id,
    required this.subjectName,
    required this.subjectCode,
    required this.startTime,
    required this.endTime,
    required this.venue,
    required this.lecturerName,
    required this.days,
    required this.group,
  });

  factory TimetableEntry.fromMap(Map<String, dynamic> map, String id) {
    return TimetableEntry(
      id: id,
      subjectName: map['subjectName'] ?? '',
      subjectCode: map['subjectCode'] ?? '',
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      venue: map['venue'] ?? '',
      lecturerName: map['lecturerName'] ?? '',
      days: map['days'] ?? '',
      group: map['group'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'subjectName': subjectName,
      'subjectCode': subjectCode,
      'startTime': startTime,
      'endTime': endTime,
      'venue': venue,
      'lecturerName': lecturerName,
      'group': group,
      'days': days,
    };
  }
}
