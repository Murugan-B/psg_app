import 'package:psg_app/features/skills/domain/models/domain_model.dart';
import 'package:psg_app/features/skills/domain/models/skill_model.dart';
import 'package:psg_app/features/assessments/domain/models/assessment_type_model.dart';

class AssessmentModel {
  final String id;
  final String title;
  final String? description;
  final String? assessmentTypeId;
  final String? skillId;
  final String? domainId;
  final double maxScore;
  final int maxAttempts;
  final int? durationMinutes;
  final DateTime? dueDate;
  final bool isPublished;
  final bool isMandatory;
  final String? academicYear;
  final String? semester;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  final AssessmentTypeModel? assessmentType;
  final SkillModel? skill;
  final DomainModel? domain;

  AssessmentModel({
    required this.id,
    required this.title,
    this.description,
    this.assessmentTypeId,
    this.skillId,
    this.domainId,
    this.maxScore = 100,
    this.maxAttempts = 1,
    this.durationMinutes,
    this.dueDate,
    this.isPublished = false,
    this.isMandatory = true,
    this.academicYear,
    this.semester,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.assessmentType,
    this.skill,
    this.domain,
  });

  factory AssessmentModel.fromJson(Map<String, dynamic> json) {
    final typeJson = json['assessment_types'] as Map<String, dynamic>?;
    final skillJson = json['skills'] as Map<String, dynamic>?;
    final domainJson = json['domains'] as Map<String, dynamic>?;

    return AssessmentModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      assessmentTypeId: json['assessment_type_id'] as String?,
      skillId: json['skill_id'] as String?,
      domainId: json['domain_id'] as String?,
      maxScore: double.tryParse(json['max_score'].toString()) ?? 100,
      maxAttempts: json['max_attempts'] as int? ?? 1,
      durationMinutes: json['duration_minutes'] as int?,
      dueDate: json['due_date'] != null
          ? DateTime.tryParse(json['due_date'] as String)
          : null,
      isPublished: json['is_published'] as bool? ?? false,
      isMandatory: json['is_mandatory'] as bool? ?? true,
      academicYear: json['academic_year'] as String?,
      semester: json['semester'] as String?,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
      assessmentType: typeJson != null ? AssessmentTypeModel.fromJson(typeJson) : null,
      skill: skillJson != null ? SkillModel.fromJson(skillJson) : null,
      domain: domainJson != null ? DomainModel.fromJson(domainJson) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'assessment_type_id': assessmentTypeId,
      'skill_id': skillId,
      'domain_id': domainId,
      'max_score': maxScore,
      'max_attempts': maxAttempts,
      'duration_minutes': durationMinutes,
      'due_date': dueDate?.toUtc().toIso8601String(),
      'is_published': isPublished,
      'is_mandatory': isMandatory,
      'academic_year': academicYear,
      'semester': semester,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
