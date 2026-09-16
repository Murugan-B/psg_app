import 'package:psg_app/features/skills/domain/models/skill_model.dart';
import 'package:psg_app/features/assessments/domain/models/question_option_model.dart';

class QuestionModel {
  final String id;
  final String assessmentId;
  final String questionText;
  final String questionType;
  final String? skillId;
  final int orderIndex;
  final double maxMarks;
  final String? difficultyLevel;
  final bool isRequired;
  final DateTime createdAt;
  final DateTime updatedAt;

  final List<QuestionOptionModel>? options;
  final SkillModel? skill;

  QuestionModel({
    required this.id,
    required this.assessmentId,
    required this.questionText,
    required this.questionType,
    this.skillId,
    this.orderIndex = 0,
    this.maxMarks = 1,
    this.difficultyLevel,
    this.isRequired = true,
    required this.createdAt,
    required this.updatedAt,
    this.options,
    this.skill,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    final optionsJson = json['question_options'];
    final skillJson = json['skills'] as Map<String, dynamic>?;

    List<QuestionOptionModel>? parsedOptions;
    if (optionsJson != null) {
      if (optionsJson is List) {
        parsedOptions = optionsJson
            .map((e) => QuestionOptionModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (optionsJson is Map<String, dynamic>) {
        parsedOptions = [QuestionOptionModel.fromJson(optionsJson)];
      }
    }

    return QuestionModel(
      id: json['id'] as String,
      assessmentId: json['assessment_id'] as String,
      questionText: json['question_text'] as String,
      questionType: json['question_type'] as String,
      skillId: json['skill_id'] as String?,
      orderIndex: json['order_index'] as int? ?? 0,
      maxMarks: double.tryParse(json['max_marks'].toString()) ?? 1,
      difficultyLevel: json['difficulty_level'] as String?,
      isRequired: json['is_required'] as bool? ?? true,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
      options: parsedOptions,
      skill: skillJson != null ? SkillModel.fromJson(skillJson) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assessment_id': assessmentId,
      'question_text': questionText,
      'question_type': questionType,
      'skill_id': skillId,
      'order_index': orderIndex,
      'max_marks': maxMarks,
      'difficulty_level': difficultyLevel,
      'is_required': isRequired,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isMcq => questionType == 'MCQ';
  bool get isMultiSelect => questionType == 'MULTI_SELECT';
  bool get isTextAnswer => questionType == 'SHORT_ANSWER' || questionType == 'LONG_ANSWER';
  bool get isNumerical => questionType == 'NUMERICAL';
  bool get hasOptions => isMcq || isMultiSelect;
}
