import 'package:psg_app/features/recommendations/domain/models/recommendation_rule_model.dart';
import 'package:psg_app/features/resources/domain/models/learning_resource_model.dart';
import 'package:psg_app/features/assessments/domain/models/assessment_model.dart';
import 'package:psg_app/features/skills/domain/models/skill_model.dart';

class RecommendationModel {
  final String id;
  final String studentId;
  final String? ruleId;
  final String? skillId;
  final String? resourceId;
  final String? assessmentId;
  final String title;
  final String? description;
  final double? score;
  final bool isDismissed;
  final bool isCompleted;
  final DateTime? validUntil;
  final DateTime createdAt;
  final DateTime updatedAt;

  final RecommendationRuleModel? rule;
  final LearningResourceModel? resource;
  final AssessmentModel? assessment;
  final SkillModel? skill;

  RecommendationModel({
    required this.id,
    required this.studentId,
    this.ruleId,
    this.skillId,
    this.resourceId,
    this.assessmentId,
    required this.title,
    this.description,
    this.score,
    this.isDismissed = false,
    this.isCompleted = false,
    this.validUntil,
    required this.createdAt,
    required this.updatedAt,
    this.rule,
    this.resource,
    this.assessment,
    this.skill,
  });

  factory RecommendationModel.fromJson(Map<String, dynamic> json) {
    final ruleJson = json['recommendation_rules'] as Map<String, dynamic>?;
    final resourceJson = json['learning_resources'] as Map<String, dynamic>?;
    final assessmentJson = json['assessments'] as Map<String, dynamic>?;
    final skillJson = json['skills'] as Map<String, dynamic>?;

    return RecommendationModel(
      id: json['id'] as String,
      studentId: json['student_id'] as String,
      ruleId: json['rule_id'] as String?,
      skillId: json['skill_id'] as String?,
      resourceId: json['resource_id'] as String?,
      assessmentId: json['assessment_id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      score: json['score'] != null ? double.tryParse(json['score'].toString()) : null,
      isDismissed: json['is_dismissed'] as bool? ?? false,
      isCompleted: json['is_completed'] as bool? ?? false,
      validUntil: json['valid_until'] != null
          ? DateTime.tryParse(json['valid_until'] as String)
          : null,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
      rule: ruleJson != null ? RecommendationRuleModel.fromJson(ruleJson) : null,
      resource: resourceJson != null ? LearningResourceModel.fromJson(resourceJson) : null,
      assessment: assessmentJson != null ? AssessmentModel.fromJson(assessmentJson) : null,
      skill: skillJson != null ? SkillModel.fromJson(skillJson) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'rule_id': ruleId,
      'skill_id': skillId,
      'resource_id': resourceId,
      'assessment_id': assessmentId,
      'title': title,
      'description': description,
      'score': score,
      'is_dismissed': isDismissed,
      'is_completed': isCompleted,
      'valid_until': validUntil?.toUtc().toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isActive => !isDismissed && !isCompleted && (validUntil == null || validUntil!.isAfter(DateTime.now()));
}
