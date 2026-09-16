import 'package:psg_app/features/skills/domain/models/domain_model.dart';
import 'package:psg_app/features/skills/domain/models/skill_model.dart';
import 'package:psg_app/features/resources/domain/models/resource_type_model.dart';

class LearningResourceModel {
  final String id;
  final String title;
  final String? description;
  final String? resourceTypeId;
  final String url;
  final String? skillId;
  final String? domainId;
  final String? difficultyLevel;
  final int? estimatedDurationMinutes;
  final bool isActive;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  final ResourceTypeModel? resourceType;
  final SkillModel? skill;
  final DomainModel? domain;

  double? studentProgress;
  bool? studentCompleted;

  LearningResourceModel({
    required this.id,
    required this.title,
    this.description,
    this.resourceTypeId,
    required this.url,
    this.skillId,
    this.domainId,
    this.difficultyLevel,
    this.estimatedDurationMinutes,
    this.isActive = true,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.resourceType,
    this.skill,
    this.domain,
    this.studentProgress,
    this.studentCompleted,
  });

  factory LearningResourceModel.fromJson(Map<String, dynamic> json) {
    final typeJson = json['resource_types'] as Map<String, dynamic>?;
    final skillJson = json['skills'] as Map<String, dynamic>?;
    final domainJson = json['domains'] as Map<String, dynamic>?;
    final viewJson = json['student_resource_views'] as Map<String, dynamic>?;

    double? progress;
    bool? completed;
    if (viewJson != null) {
      final cp = viewJson['completion_percentage'];
      if (cp != null) {
        progress = double.tryParse(cp.toString());
      }
      completed = viewJson['completed'] as bool?;
    }

    return LearningResourceModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      resourceTypeId: json['resource_type_id'] as String?,
      url: json['url'] as String,
      skillId: json['skill_id'] as String?,
      domainId: json['domain_id'] as String?,
      difficultyLevel: json['difficulty_level'] as String?,
      estimatedDurationMinutes: json['estimated_duration_minutes'] as int?,
      isActive: json['is_active'] as bool? ?? true,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
      resourceType: typeJson != null ? ResourceTypeModel.fromJson(typeJson) : null,
      skill: skillJson != null ? SkillModel.fromJson(skillJson) : null,
      domain: domainJson != null ? DomainModel.fromJson(domainJson) : null,
      studentProgress: progress,
      studentCompleted: completed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'resource_type_id': resourceTypeId,
      'url': url,
      'skill_id': skillId,
      'domain_id': domainId,
      'difficulty_level': difficultyLevel,
      'estimated_duration_minutes': estimatedDurationMinutes,
      'is_active': isActive,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isVideo => resourceType?.name == 'Video' || url.contains('youtube') || url.contains('youtu.be');
  bool get isArticle => resourceType?.name == 'Article';
  bool get isDocument => resourceType?.name == 'Document';
  bool get isLink => resourceType?.name == 'Link';
  bool get isInteractive => resourceType?.name == 'Interactive';
}
