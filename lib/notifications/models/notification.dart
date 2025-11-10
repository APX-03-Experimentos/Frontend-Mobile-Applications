class NotificationDataModel{
  final int id;
  final int userId;
  final String title;
  final String message;
  final String type;
  final bool read;
  final DateTime ocurredAt;
  final int sourceCourseId;
  final int sourceAssignmentId;

  NotificationDataModel({
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

  factory NotificationDataModel.fromJson(Map<String,dynamic> json){
    return NotificationDataModel(
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

  NotificationDataModel copyWith({
    int? id,
    int? userId,
    String? title,
    String? message,
    String? type,
    bool? read,
    DateTime? ocurredAt,
    int? sourceCourseId,
    int? sourceAssignmentId,
  }) {
    return NotificationDataModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      read: read ?? this.read,
      ocurredAt: ocurredAt ?? this.ocurredAt,
      sourceCourseId: sourceCourseId ?? this.sourceCourseId,
      sourceAssignmentId: sourceAssignmentId ?? this.sourceAssignmentId,
    );
  }

  bool getReadStatus(){
    return read;
  }
}


