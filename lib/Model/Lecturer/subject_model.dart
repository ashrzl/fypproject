class Subject {
  final String lecturerId;
  final String subjectCode;
  final String subjectName;
  final String group;
  final String lecturerName;
  final String classLink;

  Subject({
    required this.lecturerId,
    required this.subjectCode,
    required this.subjectName,
    required this.group,
    required this.lecturerName,
    required this.classLink,
  });

  factory Subject.fromFirestore(String id, Map<String, dynamic> data) {
    return Subject(
      lecturerId: data['lecturerId'],
      subjectCode: id,
      subjectName: data['subjectName'],
      group: data['group'],
      lecturerName: data['lecturerName'],
      classLink: data['classLink'],
    );
  }
}
