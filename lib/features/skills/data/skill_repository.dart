import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:psg_app/core/providers/supabase_provider.dart';
import 'package:psg_app/features/skills/domain/models/domain_model.dart';
import 'package:psg_app/features/skills/domain/models/skill_model.dart';

final skillRepositoryProvider = Provider<SkillRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SkillRepository(supabase);
});

class SkillRepository {
  final SupabaseClient _supabase;

  SkillRepository(this._supabase);

  String? get currentUserId => _supabase.auth.currentUser?.id;

  Future<List<DomainModel>> getDomains({String? departmentId}) async {
    try {
      var query = _supabase.from('domains').select('*');
      if (departmentId != null) {
        query = query.eq('department_id', departmentId);
      }
      final response = await query
          .eq('is_active', true)
          .order('name');

      return (response as List)
          .map((json) => DomainModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching domains: $e');
      return [];
    }
  }

  Future<List<SkillModel>> getSkillsByDomain(String domainId) async {
    try {
      final response = await _supabase
          .from('skills')
          .select('*, domains:domain_id(*)')
          .eq('domain_id', domainId)
          .eq('is_active', true)
          .order('name');

      return (response as List)
          .map((json) => SkillModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching skills by domain: $e');
      return [];
    }
  }

  Future<SkillModel?> getSkillDetail(String skillId) async {
    try {
      final userId = currentUserId;
      if (userId != null) {
        final response = await _supabase
            .from('skills')
            .select('*, domains:domain_id(*), student_competencies!inner(progress_percent, competency_levels:competency_level_id(*))')
            .eq('id', skillId)
            .eq('student_competencies.student_id', userId)
            .maybeSingle();

      if (response == null) return null;
      return SkillModel.fromJson(response);
    }

    final response = await _supabase
          .from('skills')
          .select('*, domains:domain_id(*)')
          .eq('id', skillId)
          .maybeSingle();

      if (response == null) return null;
      return SkillModel.fromJson(response);
  } catch (e) {
      debugPrint('Error fetching skill detail: $e');
      return null;
    }
  }

  Future<List<SkillModel>> getAllSkills() async {
    try {
      final response = await _supabase
          .from('skills')
          .select('*, domains:domain_id(*)')
          .eq('is_active', true)
          .order('name');

      return (response as List)
          .map((json) => SkillModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching all skills: $e');
      return [];
    }
  }

  Future<List<SkillModel>> searchSkills(String query) async {
    try {
      final response = await _supabase
          .from('skills')
          .select('*, domains:domain_id(*)')
          .eq('is_active', true)
          .ilike('name', '%$query%')
          .order('name');

      return (response as List)
          .map((json) => SkillModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error searching skills: $e');
      return [];
    }
  }

  Future<List<SkillModel>> getStudentSkills() async {
    final userId = currentUserId;
    if (userId == null) return [];

    try {
      final response = await _supabase
          .from('skills')
          .select('*, domains:domain_id(*), student_competencies!inner(progress_percent, competency_levels:competency_level_id(*))')
          .eq('is_active', true)
          .eq('student_competencies.student_id', userId)
          .order('name');

      return (response as List)
          .map((json) => SkillModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching student skills: $e');
      return [];
    }
  }
}
