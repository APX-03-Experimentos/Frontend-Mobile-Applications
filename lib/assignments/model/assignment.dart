class Assignment {
  final int id;
  final String title;
  final String description;
  final int courseId;
  final DateTime? deadline;
  final String imageUrl;
  final List<String>? fileUrls;

  Assignment({
    required this.id,
    required this.title,
    required this.description,
    required this.courseId,
    this.deadline,
    required this.imageUrl,
    this.fileUrls,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json["id"] as int,
      title: json["title"] as String,
      description: json["description"] as String,
      courseId: json["courseId"] as int,
      deadline: json["deadline"] != null
          ? DateTime.parse(json["deadline"] as String)
          : null,
      imageUrl: json["imageUrl"] as String,
      fileUrls: json["fileUrls"] != null
          ? List<String>.from(json["fileUrls"])
          : null,
    );
  }
}