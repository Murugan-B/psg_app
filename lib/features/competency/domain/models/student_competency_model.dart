import 'package:psg_app/features/skills/domain/models/skill_model.dart';
import 'package:psg_app/features/competency/domain/models/competency_level_model.dart';

class StudentCompetencyModel {
  final String id;
  final String studentId;
  final String skillId;
  final String? competencyLevelId;
  final double? progressPercent;
  final double? score;
  final DateTime? assessedAt;
  final DateTime? lastAssessedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  final SkillModel? skill;
  final CompetencyLevelModel? competencyLevel;

  StudentCompetencyModel({
    required this.id,
    required this.studentId,
    required this.skillId,
    this.competencyLevelId,
    this.progressPercent,
    this.score,
    this.assessedAt,
    this.lastAssessedAt,
    required this.createdAt,
    required this.updatedAt,
    this.skill,
    this.competencyLevel,
  });

  factory StudentCompetencyModel.fromJson(Map<String, dynamic> json) {
    final skillJson = json['skills'] as Map<String, dynamic>?;
    final levelJson = json['competency_levels'] as Map<String, dynamic>?;

    return StudentCompetencyModel(
      id: json['id'] as String,
      studentId: json['student_id'] as String,
      skillId: json['skill_id'] as String,
      competencyLevelId: json['competency_level_id'] as String?,
      progressPercent: json['progress_percent'] != null
          ? double.tryParse(json['progress_percent'].toString())
          : null,
      score: json['score'] != null ? double.tryParse(json['score'].toString()) : null,
      assessedAt: json['assessed_at'] != null
          ? DateTime.tryParse(json['assessed_at'] as String)
          : null,
      lastAssessedAt: json['last_assessed_at'] != null
          ? DateTime.tryParse(json['last_assessed_at'] as String)
          : null,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
      skill: skillJson != null ? SkillModel.fromJson(skillJson) : null,
      competencyLevel: levelJson != null ? CompetencyLevelModel.fromJson(levelJson) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'skill_id': skillId,
      'competency_level_id': competencyLevelId,
      'progress_percent': progressPercent,
      'score': score,
      'assessed_at': assessedAt?.toIso8601String(),
      'last_assessed_at': lastAssessedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
