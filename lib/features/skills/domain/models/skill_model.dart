import 'package:psg_app/features/skills/domain/models/domain_model.dart';

class SkillModel {
  final String id;
  final String? domainId;
  final String name;
  final String? description;
  final String difficultyLevel;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  final DomainModel? domain;
  final double? studentProgress;
  final String? studentCompetencyLevel;

  SkillModel({
    required this.id,
    this.domainId,
    required this.name,
    this.description,
    this.difficultyLevel = 'BEGINNER',
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.domain,
    this.studentProgress,
    this.studentCompetencyLevel,
  });

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    final domainJson = json['domains'] as Map<String, dynamic>?;
    final competencyJson = json['student_competencies'] as Map<String, dynamic>?;

    String? competencyLevelName;
    double? progress;
    if (competencyJson != null) {
      final pp = competencyJson['progress_percent'];
      if (pp != null) {
        progress = double.tryParse(pp.toString());
      }
      final levels = competencyJson['competency_levels'];
      if (levels is Map<String, dynamic>) {
        competencyLevelName = levels['name'] as String?;
      }
    }

    return SkillModel(
      id: json['id'] as String,
      domainId: json['domain_id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      difficultyLevel: json['difficulty_level'] as String? ?? 'BEGINNER',
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
      domain: domainJson != null ? DomainModel.fromJson(domainJson) : null,
      studentProgress: progress,
      studentCompetencyLevel: competencyLevelName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'domain_id': domainId,
      'name': name,
      'description': description,
      'difficulty_level': difficultyLevel,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
