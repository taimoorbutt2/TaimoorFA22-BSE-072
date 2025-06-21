class Complaint {
  final String id;
  final String studentId;
  final String batchId;
  final String? advisorId;
  final String? hodId;
  final String title;
  final String description;
  final String? mediaUrl;
  final String status;
  final int sameTitleCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastActionAt;

  Complaint({
    required this.id,
    required this.studentId,
    required this.batchId,
    this.advisorId,
    this.hodId,
    required this.title,
    required this.description,
    this.mediaUrl,
    required this.status,
    required this.sameTitleCount,
    required this.createdAt,
    required this.updatedAt,
    required this.lastActionAt,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id'] ?? '',
      studentId: json['student_id'] ?? '',
      batchId: json['batch_id'] ?? '',
      advisorId: json['advisor_id'],
      hodId: json['hod_id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      mediaUrl: json['media_url'],
      status: json['status'] ?? 'Submitted',
      sameTitleCount: json['same_title_count'] ?? 1,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      lastActionAt: DateTime.parse(json['last_action_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'batch_id': batchId,
      'advisor_id': advisorId,
      'hod_id': hodId,
      'title': title,
      'description': description,
      'media_url': mediaUrl,
      'status': status,
      'same_title_count': sameTitleCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_action_at': lastActionAt.toIso8601String(),
    };
  }

  Complaint copyWith({
    String? id,
    String? studentId,
    String? batchId,
    String? advisorId,
    String? hodId,
    String? title,
    String? description,
    String? mediaUrl,
    String? status,
    int? sameTitleCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastActionAt,
  }) {
    return Complaint(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      batchId: batchId ?? this.batchId,
      advisorId: advisorId ?? this.advisorId,
      hodId: hodId ?? this.hodId,
      title: title ?? this.title,
      description: description ?? this.description,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      status: status ?? this.status,
      sameTitleCount: sameTitleCount ?? this.sameTitleCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastActionAt: lastActionAt ?? this.lastActionAt,
    );
  }

  @override
  String toString() {
    return 'Complaint(id: $id, studentId: $studentId, batchId: $batchId, advisorId: $advisorId, hodId: $hodId, title: $title, description: $description, mediaUrl: $mediaUrl, status: $status, sameTitleCount: $sameTitleCount, createdAt: $createdAt, updatedAt: $updatedAt, lastActionAt: $lastActionAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Complaint && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 