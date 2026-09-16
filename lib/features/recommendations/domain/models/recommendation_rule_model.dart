class RecommendationRuleModel {
  final String id;
  final String name;
  final String? description;
  final String ruleType;
  final int priority;
  final Map<String, dynamic>? conditions;
  final Map<String, dynamic>? action;
  final bool isActive;
  final String? mlModelName;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  RecommendationRuleModel({
    required this.id,
    required this.name,
    this.description,
    required this.ruleType,
    required this.priority,
    this.conditions,
    this.action,
    this.isActive = true,
    this.mlModelName,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RecommendationRuleModel.fromJson(Map<String, dynamic> json) {
    return RecommendationRuleModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      ruleType: json['rule_type'] as String,
      priority: json['priority'] as int? ?? 10,
      conditions: json['conditions'] as Map<String, dynamic>?,
      action: json['action'] as Map<String, dynamic>?,
      isActive: json['is_active'] as bool? ?? true,
      mlModelName: json['ml_model_name'] as String?,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'rule_type': ruleType,
      'priority': priority,
      'conditions': conditions,
      'action': action,
      'is_active': isActive,
      'ml_model_name': mlModelName,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get actionTitle {
    if (action == null) return name;
    final title = action!['title'] as String?;
    return title ?? name;
  }

  String get actionDescription {
    if (action == null) return description ?? '';
    final desc = action!['description'] as String?;
    return desc ?? description ?? '';
  }
}
