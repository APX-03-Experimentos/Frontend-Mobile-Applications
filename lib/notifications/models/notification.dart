class Notification{
  final int id;
  final int userId;
  final String title;
  final String message;
  final String type;
  final bool read;
  final DateTime ocurredAt;
  final int sourceCourseId;
  final int sourceAssignmentId;

  Notification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.read,
    required this.ocurredAt,
    required this.sourceCourseId,
    required this.sourceAssignmentId
  });

  factory Notification.fromJson(Map<String,dynamic> json){
    return Notification(
      id: json["id"] as int,
      userId: json["userId"] as int,
      title: json["title"] as String,
      message: json["message"] as String,
      type: json["type"] as String,
      read: json["read"] as bool,
      ocurredAt: DateTime.parse(json["ocurredAt"] as String),
      sourceCourseId: json["sourceCourseId"] as int,
      sourceAssignmentId: json["sourceAssignmentId"] as int
    );

  }
}


