class TimetableEntry {
  final String id;
  final String? classId;
  final String? staffId;
  final String? subjectId;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String? room;
  final String type;
  final String? sessionType;
  final String? academicYear;
  final String? semester;

  // Joined data
  final String? subjectCode;
  final String? subjectName;
  final String? classSection;
  final String? classBatch;

  TimetableEntry({
    required this.id,
    this.classId,
    this.staffId,
    this.subjectId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.room,
    required this.type,
    this.sessionType,
    this.academicYear,
    this.semester,
    this.subjectCode,
    this.subjectName,
    this.classSection,
    this.classBatch,
  });

  factory TimetableEntry.fromJson(Map<String, dynamic> json) {
    // Handle joins
    final courseJson = json['courses'] as Map<String, dynamic>?;
    final classJson = json['classes'] as Map<String, dynamic>?;

    return TimetableEntry(
      id: json['id'] as String,
      classId: json['class_id'] as String?,
      staffId: json['staff_id'] as String?,
      subjectId: json['subject_id'] as String?,
      dayOfWeek: json['day_of_week'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      room: json['room'] as String?,
      type: json['type'] as String? ?? 'THEORY',
      sessionType: json['session_type'] as String?,
      academicYear: json['academic_year'] as String?,
      semester: json['semester'] as String?,
      subjectCode: courseJson?['subject_code'] as String? ?? classJson?['subject_code'] as String?,
      subjectName: courseJson?['subject_name'] as String? ?? classJson?['subject_name'] as String?,
      classSection: classJson?['section'] as String?,
      classBatch: classJson?['batch'] as String?,
    );
  }
}
