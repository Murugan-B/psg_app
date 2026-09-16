class DomainModel {
  final String id;
  final String name;
  final String? description;
  final String? departmentId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  DomainModel({
    required this.id,
    required this.name,
    this.description,
    this.departmentId,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DomainModel.fromJson(Map<String, dynamic> json) {
    return DomainModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      departmentId: json['department_id'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'department_id': departmentId,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
