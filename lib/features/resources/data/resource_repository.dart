import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:psg_app/core/providers/supabase_provider.dart';
import 'package:psg_app/features/resources/domain/models/learning_resource_model.dart';
import 'package:psg_app/features/resources/domain/models/resource_type_model.dart';
import 'package:psg_app/features/resources/domain/models/student_resource_view_model.dart';

final resourceRepositoryProvider = Provider<ResourceRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return ResourceRepository(supabase);
});

class ResourceRepository {
  final SupabaseClient _supabase;

  ResourceRepository(this._supabase);

  String? get currentUserId => _supabase.auth.currentUser?.id;

  Future<List<ResourceTypeModel>> getResourceTypes() async {
    try {
      final response = await _supabase.from('resource_types').select('*').order('name');
      return (response as List)
          .map((json) => ResourceTypeModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching resource types: $e');
      return [];
    }
  }

  Future<List<LearningResourceModel>> getAllResources() async {
    try {
      final response = await _supabase
          .from('learning_resources')
          .select('*, resource_types:resource_type_id(*), skills:skill_id(*), domains:domain_id(*)')
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => LearningResourceModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching all resources: $e');
      return [];
    }
  }

  Future<List<LearningResourceModel>> getResourcesBySkill(String skillId) async {
    try {
      final response = await _supabase
          .from('learning_resources')
          .select('*, resource_types:resource_type_id(*), skills:skill_id(*), domains:domain_id(*)')
          .eq('skill_id', skillId)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => LearningResourceModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching resources by skill: $e');
      return [];
    }
  }

  Future<List<LearningResourceModel>> getResourcesByDomain(String domainId) async {
    try {
      final response = await _supabase
          .from('learning_resources')
          .select('*, resource_types:resource_type_id(*), skills:skill_id(*), domains:domain_id(*)')
          .eq('domain_id', domainId)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => LearningResourceModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching resources by domain: $e');
      return [];
    }
  }

  Future<LearningResourceModel?> getResourceDetail(String resourceId) async {
    try {
      final response = await _supabase
          .from('learning_resources')
          .select('*, resource_types:resource_type_id(*), skills:skill_id(*), domains:domain_id(*), student_resource_views!left(id, completion_percentage, completed, view_duration_seconds)')
          .eq('id', resourceId)
          .eq('is_active', true)
          .maybeSingle();

      if (response == null) return null;
      return LearningResourceModel.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching resource detail: $e');
      return null;
    }
  }

  Future<List<LearningResourceModel>> searchResources(String query) async {
    try {
      final response = await _supabase
          .from('learning_resources')
          .select('*, resource_types:resource_type_id(*), skills:skill_id(*), domains:domain_id(*)')
          .eq('is_active', true)
          .ilike('title', '%$query%')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => LearningResourceModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error searching resources: $e');
      return [];
    }
  }

  Future<void> recordResourceView({
    required String resourceId,
    required String studentId,
    int? viewDurationSeconds,
    bool completed = false,
    double completionPercentage = 0,
  }) async {
    try {
      await _supabase.from('student_resource_views').upsert({
        'student_id': studentId,
        'resource_id': resourceId,
        'view_duration_seconds': viewDurationSeconds,
        'completed': completed,
        'viewed_at': DateTime.now().toUtc().toIso8601String(),
        'completion_percentage': completionPercentage,
      }, onConflict: 'student_id, resource_id');
    } catch (e) {
      debugPrint('Error recording resource view: $e');
      rethrow;
    }
  }

  Future<StudentResourceViewModel?> getResourceView(String resourceId, String studentId) async {
    try {
      final response = await _supabase
          .from('student_resource_views')
          .select('*')
          .eq('resource_id', resourceId)
          .eq('student_id', studentId)
          .maybeSingle();

      if (response == null) return null;
      return StudentResourceViewModel.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching resource view: $e');
      return null;
    }
  }
}
