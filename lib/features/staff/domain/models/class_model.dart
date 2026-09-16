class ClassModel {
  final String id;
  final String subjectCode;
  final String subjectName;
  final String department;
  final String? year;
  final String? section;
  final String? semester;
  final String? academicYear;
  final String classType;
  final String? facultyId;
  final int studentCount;

  ClassModel({
    required this.id,
    required this.subjectCode,
    required this.subjectName,
    required this.department,
    this.year,
    this.section,
    this.semester,
    this.academicYear,
    this.classType = 'Theory',
    this.facultyId,
    this.studentCount = 0,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'] as String,
      subjectCode: json['subject_code'] as String,
      subjectName: json['subject_name'] as String,
      department: json['department'] as String,
      year: json['year'] as String?,
      section: json['section'] as String?,
      semester: json['semester'] as String?,
      academicYear: json['academic_year'] as String?,
      classType: json['class_type'] as String? ?? 'Theory',
      facultyId: json['faculty_id'] as String?,
      studentCount: json['student_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject_code': subjectCode,
      'subject_name': subjectName,
      'department': department,
      'year': year,
      'section': section,
      'semester': semester,
      'academic_year': academicYear,
      'class_type': classType,
      'faculty_id': facultyId,
      'student_count': studentCount,
    };
  }
}
