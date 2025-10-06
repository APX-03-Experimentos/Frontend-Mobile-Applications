class User {
  final int id;
  final String username;
  final String role;
  final String? token;

  User({
    required this.id,
    required this.username,
    required this.role,
    this.token
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json["id"] as int,
        username: json['username'] ?? json['userName'],
        role: json['roles'][0] as String,
        token: json['token'] as String?
    );
  }

}