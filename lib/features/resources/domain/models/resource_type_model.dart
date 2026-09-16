class ResourceTypeModel {
  final String id;
  final String name;
  final DateTime createdAt;

  ResourceTypeModel({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory ResourceTypeModel.fromJson(Map<String, dynamic> json) {
    return ResourceTypeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
