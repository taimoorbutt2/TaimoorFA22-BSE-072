class Batch {
  final String id;
  final String batchName;
  final String departmentId;
  final String? advisorId;
  final DateTime createdAt;

  Batch({
    required this.id,
    required this.batchName,
    required this.departmentId,
    this.advisorId,
    required this.createdAt,
  });

  factory Batch.fromJson(Map<String, dynamic> json) {
    return Batch(
      id: json['id'] ?? '',
      batchName: json['batch_name'] ?? '',
      departmentId: json['department_id'] ?? '',
      advisorId: json['advisor_id'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'batch_name': batchName,
      'department_id': departmentId,
      'advisor_id': advisorId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Batch copyWith({
    String? id,
    String? batchName,
    String? departmentId,
    String? advisorId,
    DateTime? createdAt,
  }) {
    return Batch(
      id: id ?? this.id,
      batchName: batchName ?? this.batchName,
      departmentId: departmentId ?? this.departmentId,
      advisorId: advisorId ?? this.advisorId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Batch(id: $id, batchName: $batchName, departmentId: $departmentId, advisorId: $advisorId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Batch && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 