import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:psg_app/core/providers/supabase_provider.dart';
import 'package:psg_app/features/recommendations/domain/models/recommendation_model.dart';
import 'package:psg_app/features/recommendations/domain/models/recommendation_rule_model.dart';

final recommendationRepositoryProvider = Provider<RecommendationRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return RecommendationRepository(supabase);
});

class RecommendationRepository {
  final SupabaseClient _supabase;

  RecommendationRepository(this._supabase);

  String? get currentUserId => _supabase.auth.currentUser?.id;

  Future<List<RecommendationRuleModel>> getRecommendationRules() async {
    try {
      final response = await _supabase
          .from('recommendation_rules')
          .select('*')
          .eq('is_active', true)
          .order('priority');

      return (response as List)
          .map((json) => RecommendationRuleModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error fetching recommendation rules: $e');
      return [];
    }
  }

  Future<List<RecommendationModel>> getMyRecommendations() async {
    final userId = currentUserId;
    if (userId == null) return [];

    try {
      final response = await _supabase
          .from('recommendations')
          .select('*, recommendation_rules:rule_id(*), learning_resources:resource_id(*), assessments:assessment_id(*), skills:skill_id(*)')
          .eq('student_id', userId)
          .eq('is_dismissed', false)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => RecommendationModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error fetching recommendations: $e');
      return [];
    }
  }

  Future<List<RecommendationModel>> getAllRecommendations({bool includeDismissed = false}) async {
    final userId = currentUserId;
    if (userId == null) return [];

    try {
      var query = _supabase
          .from('recommendations')
          .select('*, recommendation_rules:rule_id(*), learning_resources:resource_id(*), assessments:assessment_id(*), skills:skill_id(*)')
          .eq('student_id', userId);

      if (!includeDismissed) {
        query = query.eq('is_dismissed', false);
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List)
          .map((json) => RecommendationModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error fetching all recommendations: $e');
      return [];
    }
  }

  Future<void> dismissRecommendation(String recommendationId) async {
    try {
      await _supabase
          .from('recommendations')
          .update({'is_dismissed': true, 'updated_at': DateTime.now().toUtc().toIso8601String()})
          .eq('id', recommendationId);
    } catch (e) {
      debugPrint('Error dismissing recommendation: $e');
      rethrow;
    }
  }

  Future<void> markRecommendationCompleted(String recommendationId) async {
    try {
      await _supabase
          .from('recommendations')
          .update({
            'is_completed': true,
            'is_dismissed': true,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', recommendationId);
    } catch (e) {
      debugPrint('Error completing recommendation: $e');
      rethrow;
    }
  }

  Future<void> insertRecommendation({
    required String studentId,
    String? ruleId,
    String? skillId,
    String? resourceId,
    String? assessmentId,
    required String title,
    String? description,
    double? score,
    DateTime? validUntil,
  }) async {
    try {
      await _supabase.from('recommendations').insert({
        'student_id': studentId,
        'rule_id': ruleId,
        'skill_id': skillId,
        'resource_id': resourceId,
        'assessment_id': assessmentId,
        'title': title,
        'description': description,
        'score': score,
        'valid_until': validUntil?.toUtc().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error inserting recommendation: $e');
      rethrow;
    }
  }
}
