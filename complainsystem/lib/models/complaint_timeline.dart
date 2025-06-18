class ComplaintTimeline {
  final String id;
  final String complaintId;
  final String? comment;
  final String? status;
  final String createdBy;
  final DateTime createdAt;

  ComplaintTimeline({
    required this.id,
    required this.complaintId,
    this.comment,
    this.status,
    required this.createdBy,
    required this.createdAt,
  });

  factory ComplaintTimeline.fromJson(Map<String, dynamic> json) {
    return ComplaintTimeline(
      id: json['id'] ?? '',
      complaintId: json['complaint_id'] ?? '',
      comment: json['comment'],
      status: json['status'],
      createdBy: json['created_by'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'complaint_id': complaintId,
      'comment': comment,
      'status': status,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ComplaintTimeline copyWith({
    String? id,
    String? complaintId,
    String? comment,
    String? status,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return ComplaintTimeline(
      id: id ?? this.id,
      complaintId: complaintId ?? this.complaintId,
      comment: comment ?? this.comment,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'ComplaintTimeline(id: $id, complaintId: $complaintId, comment: $comment, status: $status, createdBy: $createdBy, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ComplaintTimeline && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 