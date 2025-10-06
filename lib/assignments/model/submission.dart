class Submission {
  final int id;
  final int assignmentId;
  final int studentId;
  final String content;
  final int score;
  final String imageUrl;
  final String status;
  final List<String> fileUrls;

  Submission({

    required this.id,
    required this.assignmentId,
    required this.studentId,
    required this.content,
    required this.score,
    required this.imageUrl,
    required this.status,
    required this.fileUrls,

  });

  factory Submission.fromJson(Map<String, dynamic> json) {
    return Submission(
      id: json['id'] as int,
      assignmentId: json['assignment_id'] as int,
      studentId: json['student_id'] as int,
      content: json['content'] as String,
      score: json['score'] as int,
      imageUrl: json['image_url'] ?? '',
      status: json['status'] as String,
      fileUrls: List<String>.from(json['file_urls'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assignment_id': assignmentId,
      'student_id': studentId,
      'content': content,
      'score': score,
      'image_url': imageUrl,
      'status': status,
      'file_urls': fileUrls,
    };
  }
}