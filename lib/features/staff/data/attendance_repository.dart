import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:psg_app/features/staff/domain/models/attendance_session_model.dart';
import 'dart:math';
import 'dart:convert';
import 'package:crypto/crypto.dart';

import 'package:psg_app/core/providers/supabase_provider.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return AttendanceRepository(supabase);
});

class AttendanceRepository {
  final SupabaseClient _supabase;

  AttendanceRepository(this._supabase);

  // Generate OTP
  String generateOtp() {
    final random = Random();
    final otp = (100000 + random.nextInt(900000)).toString(); // 6 digits
    return otp;
  }

  // Create an attendance session
  Future<AttendanceSessionModel?> createSession({
    required String classId,
    required String staffId,
    required String otp,
    required int durationMinutes,
    String? timetableId,
    DateTime? customDateTime,
  }) async {
    try {
      final now = customDateTime ?? DateTime.now();
      final expiresAt = now.add(Duration(minutes: durationMinutes));
      
      final sessionData = {
        'class_id': classId,
        'staff_id': staffId,
        if (timetableId != null) 'timetable_id': timetableId,
        'date': "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}",
        'start_time': "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:00",
        'end_time': "${expiresAt.hour.toString().padLeft(2, '0')}:${expiresAt.minute.toString().padLeft(2, '0')}:00",
        'otp_hash': otp, // Storing raw OTP for now, hash in prod
        'status': 'OPEN',
        'expires_at': expiresAt.toIso8601String(),
      };

      final response = await _supabase
          .from('attendance_sessions')
          .insert(sessionData)
          .select()
          .single();

      return AttendanceSessionModel.fromJson(response);
    } catch (e) {
      print('Error creating attendance session: $e');
      return null;
    }
  }
  
  // Generate End OTP
  Future<String?> generateEndOtp(String sessionId) async {
    try {
      final otp = generateOtp();
      await _supabase
          .from('attendance_sessions')
          .update({'end_otp_hash': otp})
          .eq('id', sessionId);
      return otp;
    } catch (e) {
      print('Error generating end OTP: $e');
      return null;
    }
  }

  // Submit Attendance OTP (for student)
  Future<String> submitAttendanceOtp(String otp, String studentId) async {
    try {
      // Find session with this OTP (either start or end) that is OPEN
      final sessions = await _supabase
          .from('attendance_sessions')
          .select()
          .eq('status', 'OPEN')
          .or('otp_hash.eq.$otp,end_otp_hash.eq.$otp');

      if (sessions.isEmpty) {
        return 'Invalid or Expired OTP';
      }

      final session = sessions.first;
      final isStart = session['otp_hash'] == otp;
      final status = isStart ? 'Present (Start)' : 'Present (Full)';

      // Fetch Staff Name
      final staffProfile = await _supabase
          .from('profiles')
          .select('full_name')
          .eq('id', session['staff_id'])
          .maybeSingle();
      final staffName = (staffProfile != null) ? (staffProfile['full_name'] ?? 'Faculty') : 'Faculty';

      // Check if record already exists
      final existingRecords = await _supabase
          .from('attendance_records')
          .select()
          .eq('session_id', session['id'])
          .eq('student_id', studentId);

      if (existingRecords.isNotEmpty) {
        final currentStatus = existingRecords.first['status'];
        if (currentStatus == status) {
          return 'Attendance already marked for this stage.';
        }
        await _supabase
            .from('attendance_records')
            .update({'status': status})
            .eq('id', existingRecords.first['id']);
      } else {
        await _supabase
            .from('attendance_records')
            .insert({
              'session_id': session['id'],
              'student_id': studentId,
              'attendance_method': 'OTP',
              'status': status,
            });
      }

      return 'Attendance marked for $staffName (${isStart ? "Start" : "End"})';
    } catch (e) {
      print('Error submitting attendance: $e');
      return 'Error submitting attendance';
    }
  }

  // Stream attendance records for a specific session
  Stream<List<Map<String, dynamic>>> getLiveAttendance(String sessionId) {
    return _supabase
        .from('attendance_records')
        .stream(primaryKey: ['id'])
        .eq('session_id', sessionId)
        .order('marked_at', ascending: false);
  }

  // Update Start OTP for repeating timer
  Future<void> updateStartOtp(String sessionId, String newOtp) async {
    try {
      await _supabase
          .from('attendance_sessions')
          .update({'otp_hash': newOtp})
          .eq('id', sessionId);
    } catch (e) {
      print('Error updating Start OTP: $e');
    }
  }

  // Update End OTP for repeating timer
  Future<void> updateEndOtp(String sessionId, String newOtp) async {
    try {
      await _supabase
          .from('attendance_sessions')
          .update({'end_otp_hash': newOtp})
          .eq('id', sessionId);
    } catch (e) {
      print('Error updating End OTP: $e');
    }
  }

  // Close an attendance session
  Future<void> closeSession(String sessionId) async {
    try {
      await _supabase
          .from('attendance_sessions')
          .update({
            'status': 'CLOSED',
            'closed_at': DateTime.now().toIso8601String(),
          })
          .eq('id', sessionId);
    } catch (e) {
      print('Error closing session: $e');
    }
  }
}
