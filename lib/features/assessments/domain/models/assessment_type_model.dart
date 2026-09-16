class AssessmentTypeModel {
  final String id;
  final String name;
  final String? code;
  final String? description;
  final bool isActive;
  final DateTime createdAt;

  AssessmentTypeModel({
    required this.id,
    required this.name,
    this.code,
    this.description,
    this.isActive = true,
    required this.createdAt,
  });

  factory AssessmentTypeModel.fromJson(Map<String, dynamic> json) {
    return AssessmentTypeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String?,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
