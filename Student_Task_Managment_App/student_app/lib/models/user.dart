class User {
  final String id;
  final String name;
  final String role;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.role,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      role: json['role'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}