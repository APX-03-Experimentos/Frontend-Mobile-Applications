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
      assignmentId: json['assignmentId'] as int,
      studentId: json['studentId'] as int,
      content: json['content'] as String,
      score: json['score'] as int,
      imageUrl: json['imageUrl'] ?? '',
      status: json['status'] as String,
      fileUrls: List<String>.from(json['fileUrls'] ?? []),
    );
  }

}