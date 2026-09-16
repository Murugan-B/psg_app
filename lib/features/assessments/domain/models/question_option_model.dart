class QuestionOptionModel {
  final String id;
  final String questionId;
  final String optionText;
  final int optionOrder;
  final bool isCorrect;
  final double? scoreOverride;
  final DateTime createdAt;

  QuestionOptionModel({
    required this.id,
    required this.questionId,
    required this.optionText,
    this.optionOrder = 0,
    this.isCorrect = false,
    this.scoreOverride,
    required this.createdAt,
  });

  factory QuestionOptionModel.fromJson(Map<String, dynamic> json) {
    return QuestionOptionModel(
      id: json['id'] as String,
      questionId: json['question_id'] as String,
      optionText: json['option_text'] as String,
      optionOrder: json['option_order'] as int? ?? 0,
      isCorrect: json['is_correct'] as bool? ?? false,
      scoreOverride: json['score_override'] != null
          ? double.tryParse(json['score_override'].toString())
          : null,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_id': questionId,
      'option_text': optionText,
      'option_order': optionOrder,
      'is_correct': isCorrect,
      'score_override': scoreOverride,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
