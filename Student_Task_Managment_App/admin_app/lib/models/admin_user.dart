class AdminUser {
  final String uid;
  final String email;
  final String role;

  AdminUser({
    required this.uid,
    required this.email,
    required this.role,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json, String uid) {
    return AdminUser(
      uid: uid,
      email: json['email'] ?? '',
      role: json['role'] ?? 'admin',
    );
  }
}