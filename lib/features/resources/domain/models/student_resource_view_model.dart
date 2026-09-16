class StudentResourceViewModel {
  final String id;
  final String studentId;
  final String resourceId;
  final int? viewDurationSeconds;
  final bool completed;
  final DateTime viewedAt;
  final double completionPercentage;

  StudentResourceViewModel({
    required this.id,
    required this.studentId,
    required this.resourceId,
    this.viewDurationSeconds,
    this.completed = false,
    required this.viewedAt,
    this.completionPercentage = 0,
  });

  factory StudentResourceViewModel.fromJson(Map<String, dynamic> json) {
    return StudentResourceViewModel(
      id: json['id'] as String,
      studentId: json['student_id'] as String,
      resourceId: json['resource_id'] as String,
      viewDurationSeconds: json['view_duration_seconds'] as int?,
      completed: json['completed'] as bool? ?? false,
      viewedAt: DateTime.tryParse(json['viewed_at'] as String? ?? '') ?? DateTime.now(),
      completionPercentage: json['completion_percentage'] != null
          ? double.tryParse(json['completion_percentage'].toString()) ?? 0
          : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'resource_id': resourceId,
      'view_duration_seconds': viewDurationSeconds,
      'completed': completed,
      'viewed_at': viewedAt.toIso8601String(),
      'completion_percentage': completionPercentage,
    };
  }
}
