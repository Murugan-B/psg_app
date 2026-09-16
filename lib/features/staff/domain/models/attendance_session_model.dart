class AttendanceSessionModel {
  final String id;
  final String classId;
  final String staffId;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String? otpHash;
  final String? endOtpHash;
  final String? qrTokenHash;
  final String status;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime? closedAt;

  AttendanceSessionModel({
    required this.id,
    required this.classId,
    required this.staffId,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.otpHash,
    this.endOtpHash,
    this.qrTokenHash,
    this.status = 'CREATED',
    this.expiresAt,
    required this.createdAt,
    this.closedAt,
  });

  factory AttendanceSessionModel.fromJson(Map<String, dynamic> json) {
    return AttendanceSessionModel(
      id: json['id'] as String,
      classId: json['class_id'] as String,
      staffId: json['staff_id'] as String,
      date: DateTime.parse(json['date'] as String),
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      otpHash: json['otp_hash'] as String?,
      endOtpHash: json['end_otp_hash'] as String?,
      qrTokenHash: json['qr_token_hash'] as String?,
      status: json['status'] as String? ?? 'CREATED',
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      closedAt: json['closed_at'] != null ? DateTime.parse(json['closed_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'class_id': classId,
      'staff_id': staffId,
      'date': "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
      'start_time': startTime,
      'end_time': endTime,
      'otp_hash': otpHash,
      'end_otp_hash': endOtpHash,
      'qr_token_hash': qrTokenHash,
      'status': status,
      'expires_at': expiresAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'closed_at': closedAt?.toIso8601String(),
    };
  }
}
