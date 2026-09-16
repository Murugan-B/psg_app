class AssessmentScoreModel {
  final String id;
  final String assessmentId;
  final String studentId;
  final double? scoreObtained;
  final double? maxScore;
  final double? percentage;
  final String status;
  final int attemptNumber;
  final DateTime? submittedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  AssessmentScoreModel({
    required this.id,
    required this.assessmentId,
    required this.studentId,
    this.scoreObtained,
    this.maxScore,
    this.percentage,
    this.status = 'NOT_ATTEMPTED',
    this.attemptNumber = 1,
    this.submittedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AssessmentScoreModel.fromJson(Map<String, dynamic> json) {
    return AssessmentScoreModel(
      id: json['id'] as String,
      assessmentId: json['assessment_id'] as String,
      studentId: json['student_id'] as String,
      scoreObtained: json['score_obtained'] != null
          ? double.tryParse(json['score_obtained'].toString())
          : null,
      maxScore: json['max_score'] != null
          ? double.tryParse(json['max_score'].toString())
          : null,
      percentage: json['percentage'] != null
          ? double.tryParse(json['percentage'].toString())
          : null,
      status: json['status'] as String? ?? 'NOT_ATTEMPTED',
      attemptNumber: json['attempt_number'] as int? ?? 1,
      submittedAt: json['submitted_at'] != null
          ? DateTime.tryParse(json['submitted_at'] as String)
          : null,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assessment_id': assessmentId,
      'student_id': studentId,
      'score_obtained': scoreObtained,
      'max_score': maxScore,
      'percentage': percentage,
      'status': status,
      'attempt_number': attemptNumber,
      'submitted_at': submittedAt?.toUtc().toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isPassed => status == 'PASSED';
  bool get isFailed => status == 'FAILED';
  bool get isPending => status == 'PENDING';
  bool get isNotAttempted => status == 'NOT_ATTEMPTED';

  String get displayScore {
    if (scoreObtained == null || maxScore == null) return 'Not scored';
    return '${scoreObtained!.toStringAsFixed(scoreObtained! % 1 == 0 ? 0 : 1)} / ${maxScore!.toStringAsFixed(maxScore! % 1 == 0 ? 0 : 1)}';
  }
}
