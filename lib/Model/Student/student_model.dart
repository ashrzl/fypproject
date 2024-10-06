class Student {
  final String student_name;
  final String student_id;
  final String email;
  final String class_name;
  final String phone_number;
  final String image_url; // Add this field

  Student({
    required this.student_name,
    required this.student_id,
    required this.email,
    required this.class_name,
    required this.phone_number,
    required this.image_url,
  });

  factory Student.fromFirestore(Map<String, dynamic> data) {
    return Student(
      student_name: data['student_name'] ?? '',
      student_id: data['student_id'] ?? '',
      email: data['email'] ?? '',
      class_name: data['class_name'] ?? '',
      phone_number: data['phone_number'] ?? '',
      image_url: data['image_url'] ?? '', // Initialize this field
    );
  }
}



