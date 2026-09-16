class CompetencyLevelModel {
  final String id;
  final String name;
  final String? description;
  final int sortOrder;
  final DateTime createdAt;

  CompetencyLevelModel({
    required this.id,
    required this.name,
    this.description,
    required this.sortOrder,
    required this.createdAt,
  });

  factory CompetencyLevelModel.fromJson(Map<String, dynamic> json) {
    return CompetencyLevelModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
