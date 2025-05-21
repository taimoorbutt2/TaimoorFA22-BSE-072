class Task {
  final String id;
  final String title;
  final String? description;
  final String assignedTo;
  final String status;
  final DateTime? dueDate;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? completed_at;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.assignedTo,
    required this.status,
    this.dueDate,
    required this.createdBy,
    required this.createdAt,
    this.completed_at,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      assignedTo: json['assigned_to']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      dueDate: json['due_date'] != null ? DateTime.tryParse(json['due_date'] as String) : null,
      createdBy: json['created_by']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      completed_at: json['completed_at'] != null ? DateTime.tryParse(json['completed_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'assigned_to': assignedTo,
      'status': status,
      'due_date': dueDate?.toIso8601String(),
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completed_at?.toIso8601String(),
    };
  }
}