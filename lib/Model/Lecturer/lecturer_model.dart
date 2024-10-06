class Lecturer {
  String lecturer_id;
  String lecturer_name;
  String phone_number;
  String email;
  String room_number;
  String image_url;

  Lecturer({
    required this.lecturer_id,
    required this.lecturer_name,
    required this.phone_number,
    required this.email,
    required this.room_number,
    required this.image_url,
  });

  factory Lecturer.fromFirestore(Map<String, dynamic> data) {
    return Lecturer(
      lecturer_id: data['lecturer_id'] ?? '',
      lecturer_name: data['lecturer_name'] ?? '',
      phone_number: data['phone_number'] ?? '',
      email: data['email'] ?? '',
      room_number: data['room_number'] ?? '',
      image_url: data['image_url'] ?? '',
    );
  }
}
