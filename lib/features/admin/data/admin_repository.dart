import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:psg_app/core/providers/supabase_provider.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return AdminRepository(supabase);
});

class AdminRepository {
  final SupabaseClient _supabase;

  AdminRepository(this._supabase);

  // Fetch all staff
  Future<List<Map<String, dynamic>>> getAllStaff() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('''
            *,
            departments:department_id (
              name
            )
          ''')
          .inFilter('role', ['faculty', 'staff', 'admin'])
          .eq('is_active', true)
          .order('full_name');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching staff: $e');
      return [];
    }
  }

  // Create Staff (Mock auth linking for now, just creates profile)
  Future<void> createStaffProfile({
    required String id, // Provide a UUID or Auth ID
    required String fullName,
    required String employeeId,
    required String email,
    required String phone,
    required String departmentId,
    required String designation,
    required String staffType,
  }) async {
    try {
      await _supabase.from('profiles').insert({
        'id': id,
        'role': 'faculty',
        'full_name': fullName,
        'employee_id': employeeId,
        'phone': phone,
        'department_id': departmentId,
        'designation': designation,
        'staff_type': staffType,
        'is_active': true,
      });
    } catch (e) {
      print('Error creating staff profile: $e');
      rethrow;
    }
  }

  // Fetch all students
  Future<List<Map<String, dynamic>>> getAllStudents() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('''
            *,
            departments:department_id (
              name
            )
          ''')
          .eq('role', 'student')
          .eq('is_active', true)
          .order('full_name');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching students: $e');
      return [];
    }
  }

  // Create Student Profile
  Future<void> createStudentProfile({
    required String id,
    required String fullName,
    required String rollNumber,
    required String email,
    required String phone,
    required String departmentId,
    required String batch,
    required String currentYear,
  }) async {
    try {
      await _supabase.from('profiles').insert({
        'id': id,
        'role': 'student',
        'full_name': fullName,
        'roll_number': rollNumber,
        'phone': phone,
        'department_id': departmentId,
        'batch': batch,
        'current_year': currentYear,
        'is_active': true,
      });
    } catch (e) {
      print('Error creating student profile: $e');
      rethrow;
    }
  }

  // Create or Update Staff Assignment to Class
  Future<void> assignStaffToClass({
    required String staffId,
    required String classId,
    required String academicYear,
    required String semester,
    required String assignedBy,
  }) async {
    try {
      await _supabase.from('staff_class_assignments').upsert({
        'staff_id': staffId,
        'class_id': classId,
        'academic_year': academicYear,
        'semester': semester,
        'is_active': true,
        'assigned_by': assignedBy,
        'assigned_at': DateTime.now().toIso8601String(),
      }, onConflict: 'staff_id, class_id');
    } catch (e) {
      print('Error assigning staff to class: $e');
      rethrow;
    }
  }

  // Create Timetable Entry
  Future<void> createTimetableEntry({
    required String staffId,
    required String classId,
    required String subjectId,
    required String dayOfWeek,
    required String startTime,
    required String endTime,
    required String sessionType,
    required String academicYear,
    required String semester,
    String? room,
  }) async {
    try {
      await _supabase.from('timetable').insert({
        'staff_id': staffId,
        'class_id': classId,
        'subject_id': subjectId,
        'day_of_week': dayOfWeek,
        'start_time': startTime,
        'end_time': endTime,
        'session_type': sessionType,
        'academic_year': academicYear,
        'semester': semester,
        'room': room,
        'is_active': true,
      });
    } catch (e) {
      print('Error creating timetable entry: $e');
      rethrow;
    }
  }

  // Fetch all classes
  Future<List<Map<String, dynamic>>> getClasses() async {
    try {
      final response = await _supabase
          .from('classes')
          .select('*')
          .order('year')
          .order('section');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching classes: $e');
      return [];
    }
  }

  // Fetch available faculty
  Future<List<Map<String, dynamic>>> getAvailableFaculty(DateTime date, String timeSlot) async {
    try {
      // timeSlot format: "09:00 AM - 10:00 AM" (or similar)
      // We will parse out the start time to match against timetable
      // In a real production app, we would ideally pass explicit start/end times.
      String startTimeStr = '09:00:00';
      if (timeSlot.contains('10:10')) startTimeStr = '10:10:00';
      else if (timeSlot.contains('11:20')) startTimeStr = '11:20:00';
      else if (timeSlot.contains('01:30')) startTimeStr = '13:30:00';
      else if (timeSlot.contains('02:40')) startTimeStr = '14:40:00';
      else if (timeSlot.contains('03:50')) startTimeStr = '15:50:00';

      final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      final dayOfWeek = weekdays[date.weekday - 1];
      final dateString = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      // 1. Get all faculty
      final allFaculty = await getAllStaff();
      
      // 2. Get timetable conflicts
      final timetableConflicts = await _supabase
          .from('timetable')
          .select('faculty_id')
          .eq('day_of_week', dayOfWeek)
          .eq('start_time', startTimeStr);
          
      // 3. Get substitute conflicts (already assigned as substitute on this date & time)
      final subConflicts = await _supabase
          .from('substitute_requests')
          .select('substitute_staff_id')
          .eq('date', dateString)
          .eq('time_slot', timeSlot)
          .eq('status', 'APPROVED');

      final busyFacultyIds = <String>{};
      
      for (var row in timetableConflicts) {
        if (row['faculty_id'] != null) busyFacultyIds.add(row['faculty_id'].toString());
      }
      for (var row in subConflicts) {
        if (row['substitute_staff_id'] != null) busyFacultyIds.add(row['substitute_staff_id'].toString());
      }

      // Filter available
      return allFaculty.where((faculty) {
        return !busyFacultyIds.contains(faculty['id'].toString());
      }).toList();
    } catch (e) {
      print('Error fetching available faculty: $e');
      return [];
    }
  }

  // Assign Substitute
  Future<void> assignSubstitute({
    required String classId,
    required String substituteStaffId,
    required DateTime date,
    required String timeSlot,
    required String assignedBy,
  }) async {
    try {
      final dateString = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      
      // We pass the substitute as original as well to satisfy NOT NULL constraints if this is just an extra class
      // Ideally schema would allow original_staff_id to be NULL for extra classes
      await _supabase.from('substitute_requests').insert({
        'class_id': classId,
        'original_staff_id': substituteStaffId,
        'substitute_staff_id': substituteStaffId,
        'date': dateString,
        'time_slot': timeSlot,
        'status': 'APPROVED',
        'requested_by': assignedBy,
      });
    } catch (e) {
      print('Error assigning substitute: $e');
      rethrow;
    }
  }

  // Create a new class
  Future<void> createClass({
    required String subjectCode,
    required String subjectName,
    required String department,
    required String year,
    required String section,
    String? semester,
    String? academicYear,
  }) async {
    try {
      await _supabase.from('classes').insert({
        'subject_code': subjectCode,
        'subject_name': subjectName,
        'department': department,
        'year': year,
        'section': section,
        'semester': semester,
        'academic_year': academicYear,
      });
    } catch (e) {
      print('Error creating class: $e');
      rethrow;
    }
  }

  // Fetch timetable for a class
  Future<List<Map<String, dynamic>>> getTimetableForClass(String classId) async {
    try {
      final response = await _supabase
          .from('timetable')
          .select('''
            *,
            faculty:faculty_id (
              full_name,
              designation
            )
          ''')
          .eq('class_id', classId);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching timetable for class: $e');
      return [];
    }
  }

  // Assign a slot in the timetable
  Future<void> assignTimetableSlot({
    required String classId,
    required String facultyId,
    required String dayOfWeek,
    required String startTime,
    required String endTime,
    String type = 'Theory',
  }) async {
    try {
      // Check if a slot already exists for this class, day, and time
      final existing = await _supabase
          .from('timetable')
          .select('id')
          .eq('class_id', classId)
          .eq('day_of_week', dayOfWeek)
          .eq('start_time', startTime)
          .maybeSingle();

      if (existing != null) {
        // Update existing slot
        await _supabase.from('timetable').update({
          'faculty_id': facultyId,
          'type': type,
        }).eq('id', existing['id']);
      } else {
        // Insert new slot
        await _supabase.from('timetable').insert({
          'class_id': classId,
          'faculty_id': facultyId,
          'day_of_week': dayOfWeek,
          'start_time': startTime,
          'end_time': endTime,
          'type': type,
        });
      }
    } catch (e) {
      print('Error assigning timetable slot: $e');
      rethrow;
    }
  }

  // Delete Timetable Slot
  Future<void> deleteTimetableSlot(String slotId) async {
    try {
      await _supabase.from('timetable').delete().eq('id', slotId);
    } catch (e) {
      print('Error deleting timetable slot: $e');
      rethrow;
    }
  }

  // Update Class
  Future<void> updateClass(String classId, Map<String, dynamic> data) async {
    try {
      await _supabase.from('classes').update(data).eq('id', classId);
    } catch (e) {
      print('Error updating class: $e');
      rethrow;
    }
  }

  // Delete Class
  Future<void> deleteClass(String classId) async {
    try {
      await _supabase.from('classes').delete().eq('id', classId);
    } catch (e) {
      print('Error deleting class: $e');
      rethrow;
    }
  }

  // Update Profile (Student or Faculty)
  Future<void> updateProfile(String profileId, Map<String, dynamic> data) async {
    try {
      await _supabase.from('profiles').update(data).eq('id', profileId);
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  // Delete Profile (Student or Faculty) - Soft Delete
  Future<void> deleteProfile(String profileId) async {
    try {
      await _supabase.from('profiles').update({'is_active': false}).eq('id', profileId);
    } catch (e) {
      print('Error deleting profile: $e');
      rethrow;
    }
  }

  // Dashboard Stats
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final studentsRes = await _supabase.from('profiles').select('id').eq('role', 'student');
      final totalStudents = (studentsRes as List).length;

      final facultyRes = await _supabase.from('profiles').select('id').eq('role', 'faculty');
      final totalFaculty = (facultyRes as List).length;

      final classesRes = await _supabase.from('classes').select('id');
      final totalClasses = (classesRes as List).length;

      final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      final today = weekdays[DateTime.now().weekday - 1];
      final timetableRes = await _supabase.from('timetable').select('id').eq('day_of_week', today);
      final scheduledToday = (timetableRes as List).length;

      final todayStr = DateTime.now().toIso8601String().substring(0, 10);
      final sessionsRes = await _supabase.from('attendance_sessions')
          .select('id, status, created_at')
          .gte('created_at', '${todayStr}T00:00:00')
          .lte('created_at', '${todayStr}T23:59:59');
      final sessionsList = sessionsRes as List;
      final attendanceMarked = sessionsList.length;
      
      final inProgress = sessionsList.where((s) => s['status'] == 'Active').length;
      final pendingAttendance = (scheduledToday - attendanceMarked) > 0 ? (scheduledToday - attendanceMarked) : 0;

      // Mock Average Attendance (e.g. 85%) for now
      final avgAttendance = sessionsList.isEmpty ? 0 : 85; 

      return {
        'totalStudents': totalStudents,
        'totalFaculty': totalFaculty,
        'totalClasses': totalClasses,
        'avgAttendance': avgAttendance,
        'scheduledToday': scheduledToday,
        'attendanceMarked': attendanceMarked,
        'inProgress': inProgress,
        'pendingAttendance': pendingAttendance,
      };
    } catch (e) {
      print('Error fetching dashboard stats: $e');
      return {
        'totalStudents': 0,
        'totalFaculty': 0,
        'totalClasses': 0,
        'avgAttendance': 0,
        'scheduledToday': 0,
        'attendanceMarked': 0,
        'inProgress': 0,
        'pendingAttendance': 0,
      };
    }
  }
}
