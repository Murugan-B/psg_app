import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:psg_app/features/staff/domain/models/class_model.dart';
import 'package:psg_app/core/providers/supabase_provider.dart';

final staffRepositoryProvider = Provider<StaffRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return StaffRepository(supabase);
});

class StaffRepository {
  final SupabaseClient _supabase;

  StaffRepository(this._supabase);

  // Get current logged in staff member's ID
  String? get currentStaffId => _supabase.auth.currentUser?.id;

  Future<List<ClassModel>> getMyClasses() async {
    final staffId = currentStaffId;
    if (staffId == null) return [];

    try {
      final Map<String, ClassModel> uniqueClasses = {};

      // 1. Fetch from classes table directly (legacy or direct assignment)
      try {
        final directResponse = await _supabase
            .from('classes')
            .select()
            .eq('faculty_id', staffId);
        for (var json in (directResponse as List)) {
          final cls = ClassModel.fromJson(json);
          uniqueClasses[cls.id] = cls;
        }
      } catch (e) {
        print('Error fetching direct classes: $e');
      }

      // 2. Fetch from staff_class_assignments
      try {
        final assignedResponse = await _supabase
            .from('staff_class_assignments')
            .select('classes(*)')
            .eq('staff_id', staffId)
            .eq('is_active', true);
        for (var row in (assignedResponse as List)) {
          if (row['classes'] != null) {
            final cls = ClassModel.fromJson(row['classes']);
            uniqueClasses[cls.id] = cls;
          }
        }
      } catch (e) {
        print('Error fetching assigned classes: $e');
      }

      // 3. Fetch from timetable
      try {
        final timetableResponse = await _supabase
            .from('timetable')
            .select('classes:class_id(*)')
            .eq('staff_id', staffId)
            .eq('is_active', true);
        for (var row in (timetableResponse as List)) {
          if (row['classes'] != null) {
            final cls = ClassModel.fromJson(row['classes']);
            uniqueClasses[cls.id] = cls;
          }
        }
      } catch (e) {
        print('Error fetching timetable classes (staff_id): $e');
        try {
          final legacyTimetableResponse = await _supabase
              .from('timetable')
              .select('classes:class_id(*)')
              .eq('faculty_id', staffId);
          for (var row in (legacyTimetableResponse as List)) {
            if (row['classes'] != null) {
              final cls = ClassModel.fromJson(row['classes']);
              uniqueClasses[cls.id] = cls;
            }
          }
        } catch (legacyErr) {
          print('Error fetching timetable classes (faculty_id fallback): $legacyErr');
        }
      }

      final classList = uniqueClasses.values.toList();
      classList.sort((a, b) => a.subjectName.compareTo(b.subjectName));
      return classList;
    } catch (e) {
      print('Error in getMyClasses overall: $e');
      return [];
    }
  }

  // Fetch today's classes from the timetable
  Future<List<Map<String, dynamic>>> getTodayTimetable() async {
    final staffId = currentStaffId;
    if (staffId == null) return [];

    final today = _getDayOfWeek(DateTime.now().weekday);

    try {
      // Fetch relational timetable
      final response = await _supabase
          .from('timetable')
          .select('''
            *,
            courses:subject_id (
              subject_name,
              subject_code
            ),
            classes:class_id (
              subject_name,
              subject_code,
              department,
              section,
              batch,
              year
            )
          ''')
          .eq('staff_id', staffId)
          .eq('day_of_week', today)
          .eq('is_active', true)
          .order('start_time');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching today timetable (relational): $e');
      
      // Legacy fallback
      try {
        final legacyResponse = await _supabase
            .from('timetable')
            .select('''
              *,
              classes:class_id (
                subject_name,
                subject_code,
                department,
                section,
                year
              )
            ''')
            .eq('faculty_id', staffId)
            .eq('day_of_week', today)
            .order('start_time');
        return List<Map<String, dynamic>>.from(legacyResponse);
      } catch (fallbackErr) {
         return [];
      }
    }
  }

  // Fetch all classes from timetable for the current faculty
  Future<List<Map<String, dynamic>>> getWeeklyTimetable() async {
    final staffId = currentStaffId;
    if (staffId == null) return [];

    try {
      final response = await _supabase
          .from('timetable')
          .select('''
            *,
            courses:subject_id (
              subject_name,
              subject_code
            ),
            classes:class_id (
              subject_name,
              subject_code,
              department,
              section,
              batch,
              year
            )
          ''')
          .eq('staff_id', staffId)
          .eq('is_active', true)
          .order('start_time');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching weekly timetable (relational): $e');
      
      // Legacy fallback
      try {
        final legacyResponse = await _supabase
            .from('timetable')
            .select('''
              *,
              classes:class_id (
                subject_name,
                subject_code,
                department,
                section,
                year
              )
            ''')
            .eq('faculty_id', staffId)
            .order('start_time');
        return List<Map<String, dynamic>>.from(legacyResponse);
      } catch (fallbackErr) {
         return [];
      }
    }
  }

  String _getDayOfWeek(int weekday) {
    switch (weekday) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return 'Monday';
    }
  }
}
