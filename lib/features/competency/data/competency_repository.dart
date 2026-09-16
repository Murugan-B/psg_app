import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:psg_app/core/providers/supabase_provider.dart';
import 'package:psg_app/features/competency/domain/models/competency_level_model.dart';
import 'package:psg_app/features/competency/domain/models/student_competency_model.dart';

final competencyRepositoryProvider = Provider<CompetencyRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return CompetencyRepository(supabase);
});

class CompetencyRepository {
  final SupabaseClient _supabase;

  CompetencyRepository(this._supabase);

  String? get currentUserId => _supabase.auth.currentUser?.id;

  Future<List<CompetencyLevelModel>> getCompetencyLevels() async {
    try {
      final response = await _supabase
          .from('competency_levels')
          .select('*')
          .order('sort_order');

      return (response as List)
          .map((json) => CompetencyLevelModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching competency levels: $e');
      return [];
    }
  }

  Future<List<StudentCompetencyModel>> getStudentCompetencies(String studentId) async {
    try {
      final response = await _supabase
          .from('student_competencies')
          .select('*, skills:skill_id(*), competency_levels:competency_level_id(*)')
      .eq('student_id', studentId)
      .order('updated_at', ascending: false);

      return (response as List)
          .map((json) => StudentCompetencyModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching student competencies: $e');
      return [];
    }
  }

  Future<StudentCompetencyModel?> getStudentCompetency(
    String studentId,
    String skillId,
  ) async {
    try {
      final response = await _supabase
          .from('student_competencies')
          .select('*, skills:skill_id(*), competency_levels:competency_level_id(*)')
          .eq('student_id', studentId)
          .eq('skill_id', skillId)
          .maybeSingle();

      if (response == null) return null;
      return StudentCompetencyModel.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching student competency: $e');
      return null;
    }
  }

  Future<void> upsertStudentCompetency({
    required String studentId,
    required String skillId,
    required String competencyLevelId,
    double? progressPercent,
    double? score,
  }) async {
    try {
      final now = DateTime.now().toUtc();
      await _supabase.from('student_competencies').upsert({
        'student_id': studentId,
        'skill_id': skillId,
        'competency_level_id': competencyLevelId,
        'progress_percent': progressPercent,
        'score': score,
        'assessed_at': now.toIso8601String(),
        'last_assessed_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      }, onConflict: 'student_id, skill_id');
    } catch (e) {
      debugPrint('Error upserting student competency: $e');
      rethrow;
    }
  }

  Future<void> updateCompetency({
    required String competencyId,
    String? competencyLevelId,
    double? progressPercent,
    double? score,
  }) async {
    try {
      await _supabase.from('student_competencies').update({
        'updated_at': DateTime.now().toUtc().toIso8601String(),
        if (competencyLevelId != null) 'competency_level_id': competencyLevelId,
        if (progressPercent != null) 'progress_percent': progressPercent,
        if (score != null) 'score': score,
        'last_assessed_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', competencyId);
    } catch (e) {
      debugPrint('Error updating competency: $e');
      rethrow;
    }
  }

  Future<List<StudentCompetencyModel>> getClassCompetencies(String classId) async {
    try {
      final response = await _supabase
          .from('student_competencies')
          .select('*, skills:skill_id(*), competency_levels:competency_level_id(*), profiles:student_id(*)')
          .eq('student_id.in', _getStudentIdsForClass(classId))
          .order('updated_at', ascending: false);

      return (response as List)
          .map((json) => StudentCompetencyModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching class competencies: $e');
      return [];
    }
  }

  Future<List<String>> _getStudentIdsForClass(String classId) async {
    try {
      final response = await _supabase
          .from('class_students')
          .select('student_id')
          .eq('class_id', classId)
          .eq('is_active', true);

      return (response as List)
          .map((json) => json['student_id'] as String)
          .toList();
    } catch (e) {
      debugPrint('Error fetching student IDs for class: $e');
      return [];
    }
  }
}
