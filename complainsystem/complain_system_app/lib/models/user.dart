class User {
  final String id;
  final String email;
  final String role;
  final String name;
  final String? batchId;
  final String? departmentId;
  final String? phoneNo;
  final String? studentId;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.role,
    required this.name,
    this.batchId,
    this.departmentId,
    this.phoneNo,
    this.studentId,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      name: json['name'] ?? '',
      batchId: json['batch_id'],
      departmentId: json['department_id'],
      phoneNo: json['phone_no'],
      studentId: json['student_id'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'name': name,
      'batch_id': batchId,
      'department_id': departmentId,
      'phone_no': phoneNo,
      'student_id': studentId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? role,
    String? name,
    String? batchId,
    String? departmentId,
    String? phoneNo,
    String? studentId,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      name: name ?? this.name,
      batchId: batchId ?? this.batchId,
      departmentId: departmentId ?? this.departmentId,
      phoneNo: phoneNo ?? this.phoneNo,
      studentId: studentId ?? this.studentId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, role: $role, name: $name, batchId: $batchId, departmentId: $departmentId, phoneNo: $phoneNo, studentId: $studentId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 