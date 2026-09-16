class StaffModel {
  final String id;
  final String fullName;
  final String? employeeId;
  final String? department;
  final String? designation;
  final String? phone;
  final String? imageUrl;
  final String role;

  StaffModel({
    required this.id,
    required this.fullName,
    this.employeeId,
    this.department,
    this.designation,
    this.phone,
    this.imageUrl,
    this.role = 'faculty',
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      employeeId: json['employee_id'] as String?,
      department: json['department'] as String?,
      designation: json['designation'] as String?,
      phone: json['phone'] as String?,
      imageUrl: json['image_url'] as String?,
      role: json['role'] as String? ?? 'faculty',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'employee_id': employeeId,
      'department': department,
      'designation': designation,
      'phone': phone,
      'image_url': imageUrl,
      'role': role,
    };
  }
}
