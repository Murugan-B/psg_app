import 'package:psg_app/features/assessments/domain/models/question_model.dart';

class AssessmentResponseModel {
  final String id;
  final String assessmentId;
  final String questionId;
  final String studentId;
  final String? selectedOptionId;
  final String? textAnswer;
  final double? numericAnswer;
  final String? fileUrl;
  final double? marksAwarded;
  final bool isAutoScored;
  final String? scoredBy;
  final DateTime? scoredAt;
  final int attemptNumber;
  final DateTime submittedAt;
  final DateTime createdAt;

  final QuestionModel? question;

  AssessmentResponseModel({
    required this.id,
    required this.assessmentId,
    required this.questionId,
    required this.studentId,
    this.selectedOptionId,
    this.textAnswer,
    this.numericAnswer,
    this.fileUrl,
    this.marksAwarded,
    this.isAutoScored = false,
    this.scoredBy,
    this.scoredAt,
    this.attemptNumber = 1,
    required this.submittedAt,
    required this.createdAt,
    this.question,
  });

  factory AssessmentResponseModel.fromJson(Map<String, dynamic> json) {
    final questionJson = json['questions'] as Map<String, dynamic>?;

    return AssessmentResponseModel(
      id: json['id'] as String,
      assessmentId: json['assessment_id'] as String,
      questionId: json['question_id'] as String,
      studentId: json['student_id'] as String,
      selectedOptionId: json['selected_option_id'] as String?,
      textAnswer: json['text_answer'] as String?,
      numericAnswer: json['numeric_answer'] != null
          ? double.tryParse(json['numeric_answer'].toString())
          : null,
      fileUrl: json['file_url'] as String?,
      marksAwarded: json['marks_awarded'] != null
          ? double.tryParse(json['marks_awarded'].toString())
          : null,
      isAutoScored: json['is_auto_scored'] as bool? ?? false,
      scoredBy: json['scored_by'] as String?,
      scoredAt: json['scored_at'] != null
          ? DateTime.tryParse(json['scored_at'] as String)
          : null,
      attemptNumber: json['attempt_number'] as int? ?? 1,
      submittedAt: DateTime.tryParse(json['submitted_at'] as String? ?? '') ?? DateTime.now(),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      question: questionJson != null ? QuestionModel.fromJson(questionJson) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assessment_id': assessmentId,
      'question_id': questionId,
      'student_id': studentId,
      'selected_option_id': selectedOptionId,
      'text_answer': textAnswer,
      'numeric_answer': numericAnswer,
      'file_url': fileUrl,
      'marks_awarded': marksAwarded,
      'is_auto_scored': isAutoScored,
      'scored_by': scoredBy,
      'scored_at': scoredAt?.toIso8601String(),
      'attempt_number': attemptNumber,
      'submitted_at': submittedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  AssessmentResponseModel copyWith({
    String? selectedOptionId,
    String? textAnswer,
    double? numericAnswer,
  }) {
    return AssessmentResponseModel(
      id: id,
      assessmentId: assessmentId,
      questionId: questionId,
      studentId: studentId,
      selectedOptionId: selectedOptionId ?? this.selectedOptionId,
      textAnswer: textAnswer ?? this.textAnswer,
      numericAnswer: numericAnswer ?? this.numericAnswer,
      fileUrl: fileUrl,
      marksAwarded: marksAwarded,
      isAutoScored: isAutoScored,
      scoredBy: scoredBy,
      scoredAt: scoredAt,
      attemptNumber: attemptNumber,
      submittedAt: submittedAt,
      createdAt: createdAt,
      question: question,
    );
  }
}
