class Course {
  final int courseId;
  final int teacherId;
  final String title;
  final String imageUrl;
  final String key;

  Course({
    required this.courseId,
    required this.teacherId,
    required this.title,
    required this.imageUrl,
    required this.key
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
        courseId: json["courseId"] as int,
        teacherId: json["teacherId"] as int,
        title: json["title"] as String,
        imageUrl: json["imageUrl"] as String,
        key: json["key"] as String
    );
  }
}