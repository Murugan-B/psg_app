import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:psg_app/core/providers/supabase_provider.dart';
import 'package:psg_app/features/assessments/domain/models/assessment_model.dart';
import 'package:psg_app/features/assessments/domain/models/assessment_score_model.dart';
import 'package:psg_app/features/assessments/domain/models/assessment_type_model.dart';
import 'package:psg_app/features/assessments/domain/models/question_model.dart';
import 'package:psg_app/features/assessments/domain/models/question_option_model.dart';

final assessmentRepositoryProvider = Provider<AssessmentRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return AssessmentRepository(supabase);
});

class AssessmentRepository {
  final SupabaseClient _supabase;

  AssessmentRepository(this._supabase);

  String? get currentUserId => _supabase.auth.currentUser?.id;

  Future<List<AssessmentTypeModel>> getAssessmentTypes() async {
    try {
      final response = await _supabase
          .from('assessment_types')
          .select('*')
          .eq('is_active', true)
          .order('name');

      return (response as List)
          .map((json) => AssessmentTypeModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching assessment types: $e');
      return [];
    }
  }

  Future<List<AssessmentModel>> getPublishedAssessments() async {
    try {
      final response = await _supabase
          .from('assessments')
          .select('*, assessment_types:assessment_type_id(*), skills:skill_id(*), domains:domain_id(*)')
          .eq('is_published', true)
          .order('due_date', ascending: false);

      return (response as List)
          .map((json) => AssessmentModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching published assessments: $e');
      return [];
    }
  }

  Future<AssessmentModel?> getAssessmentDetail(String assessmentId) async {
    try {
      final response = await _supabase
          .from('assessments')
          .select('*, assessment_types:assessment_type_id(*), skills:skill_id(*), domains:domain_id(*)')
          .eq('id', assessmentId)
          .maybeSingle();

      if (response == null) return null;
      return AssessmentModel.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching assessment detail: $e');
      return null;
    }
  }

  Future<List<QuestionModel>> getAssessmentQuestions(String assessmentId) async {
    try {
      final response = await _supabase
          .from('questions')
          .select('*, question_options:question_options(*)')
          .eq('assessment_id', assessmentId)
          .order('order_index');

      return (response as List)
          .map((json) => QuestionModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching questions: $e');
      return [];
    }
  }

  Future<List<QuestionOptionModel>> getQuestionOptions(String questionId) async {
    try {
      final response = await _supabase
          .from('question_options')
          .select('*')
          .eq('question_id', questionId)
          .order('option_order');

      return (response as List)
          .map((json) => QuestionOptionModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching question options: $e');
      return [];
    }
  }

  Future<void> upsertResponse({
    required String assessmentId,
    required String questionId,
    required String studentId,
    String? selectedOptionId,
    String? textAnswer,
    double? numericAnswer,
    String? fileUrl,
    int attemptNumber = 1,
  }) async {
    try {
      await _supabase.from('assessment_responses').upsert({
        'assessment_id': assessmentId,
        'question_id': questionId,
        'student_id': studentId,
        'selected_option_id': selectedOptionId,
        'text_answer': textAnswer,
        'numeric_answer': numericAnswer,
        'file_url': fileUrl,
        'attempt_number': attemptNumber,
        'submitted_at': DateTime.now().toUtc().toIso8601String(),
      }, onConflict: 'assessment_id, question_id, student_id, attempt_number');
    } catch (e) {
      debugPrint('Error upserting response: $e');
      rethrow;
    }
  }

  Future<double> calculateScore(String assessmentId, String studentId, int attemptNumber) async {
    try {
      final questions = await getAssessmentQuestions(assessmentId);
      final responses = await _supabase
          .from('assessment_responses')
          .select('*, questions:question_id(*)')
          .eq('assessment_id', assessmentId)
          .eq('student_id', studentId)
          .eq('attempt_number', attemptNumber);

      double totalScore = 0;
      final responseList = responses as List;

      for (final question in questions) {
        final questionResponses = responseList.where(
          (r) => r['question_id'] == question.id,
        ).toList();

        if (questionResponses.isEmpty) continue;

        final response = questionResponses.first;
        final questionMaxMarks = question.maxMarks;

        if (question.isMcq) {
          final selectedOptionId = response['selected_option_id'] as String?;
          if (selectedOptionId != null) {
            final correctOption = question.options?.firstWhere(
              (o) => o.isCorrect,
              orElse: () => QuestionOptionModel(
                id: '',
                questionId: question.id,
                optionText: '',
                isCorrect: false,
                createdAt: DateTime.now(),
              ),
            );
            if (selectedOptionId == correctOption?.id) {
              totalScore += questionMaxMarks;
            }
          }
        } else if (question.isMultiSelect) {
          final selectedIds = response['selected_option_id'] as String?;
          final correctOptions = question.options?.where((o) => o.isCorrect).toList() ?? [];
          if (correctOptions.isNotEmpty && selectedIds != null) {
            final selectedId = selectedIds;
            if (correctOptions.any((o) => o.id == selectedId)) {
              totalScore += questionMaxMarks;
            }
          }
        } else if (question.isNumerical) {
          final numericAnswer = response['numeric_answer'] != null
              ? double.tryParse(response['numeric_answer'].toString())
              : null;
          if (numericAnswer != null) {
            final options = question.options ?? [];
            final correctOption = options.firstWhere(
              (o) => o.isCorrect,
              orElse: () => options.isNotEmpty ? options.first : QuestionOptionModel(
                id: '',
                questionId: question.id,
                optionText: '',
                isCorrect: false,
                createdAt: DateTime.now(),
              ),
            );
            final correctValue = correctOption.optionText;
            if (correctValue.isNotEmpty && numericAnswer.toString().contains(correctValue)) {
              totalScore += questionMaxMarks;
            }
          }
        }
      }

      return totalScore;
    } catch (e) {
      debugPrint('Error calculating score: $e');
      rethrow;
    }
  }

  Future<AssessmentScoreModel?> submitAssessment({
    required String assessmentId,
    required String studentId,
    required int attemptNumber,
    required double scoreObtained,
    double? maxScore,
  }) async {
    try {
      final assessment = await getAssessmentDetail(assessmentId);
      final effectiveMaxScore = maxScore ?? assessment?.maxScore ?? 100;
      final percentage = effectiveMaxScore > 0
          ? (scoreObtained / effectiveMaxScore * 100).clamp(0, 100)
          : 0.0;

      final status = percentage >= 60 ? 'PASSED' : 'FAILED';

      final response = await _supabase
          .from('assessment_scores')
          .upsert({
            'assessment_id': assessmentId,
            'student_id': studentId,
            'score_obtained': scoreObtained,
            'max_score': effectiveMaxScore,
            'percentage': percentage,
            'status': status,
            'attempt_number': attemptNumber,
            'submitted_at': DateTime.now().toUtc().toIso8601String(),
          }, onConflict: 'assessment_id, student_id, attempt_number')
          .select()
          .maybeSingle();

      if (response == null) return null;
      return AssessmentScoreModel.fromJson(response);
    } catch (e) {
      debugPrint('Error submitting assessment: $e');
      rethrow;
    }
  }

  Future<List<AssessmentScoreModel>> getStudentScores(String studentId) async {
    try {
      final response = await _supabase
          .from('assessment_scores')
          .select('*, assessments:assessment_id(*)')
          .eq('student_id', studentId)
          .order('submitted_at', ascending: false);

      return (response as List)
          .map((json) => AssessmentScoreModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching student scores: $e');
      return [];
    }
  }

  Future<AssessmentScoreModel?> getStudentScore(String assessmentId, String studentId) async {
    try {
      final response = await _supabase
          .from('assessment_scores')
          .select('*, assessments:assessment_id(*)')
          .eq('assessment_id', assessmentId)
          .eq('student_id', studentId)
          .maybeSingle();

      if (response == null) return null;
      return AssessmentScoreModel.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching student score: $e');
      return null;
    }
  }

  Future<int> getNextAttemptNumber(String assessmentId, String studentId) async {
    try {
      final response = await _supabase
          .from('assessment_scores')
          .select('attempt_number')
          .eq('assessment_id', assessmentId)
          .eq('student_id', studentId)
          .order('attempt_number', ascending: false)
          .limit(1);

      if (response.isEmpty) return 1;
      final maxAttempt = (response as List).first['attempt_number'] as int? ?? 0;
      return maxAttempt + 1;
    } catch (e) {
      debugPrint('Error fetching next attempt number: $e');
      return 1;
    }
  }

  Future<bool> canAttempt(String assessmentId) async {
    try {
      final assessment = await getAssessmentDetail(assessmentId);
      if (assessment == null) return false;

      final studentId = currentUserId;
      if (studentId == null) return false;

      final response = await _supabase
          .from('assessment_scores')
          .select('id')
          .eq('assessment_id', assessmentId)
          .eq('student_id', studentId);

      final count = (response as List).length;
      return count < assessment.maxAttempts;
    } catch (e) {
      debugPrint('Error checking if can attempt: $e');
      return false;
    }
  }

  Future<List<AssessmentModel>> getAssessmentsBySkill(String skillId) async {
    try {
      final response = await _supabase
          .from('assessments')
          .select('*, assessment_types:assessment_type_id(*), skills:skill_id(*), domains:domain_id(*)')
          .eq('skill_id', skillId)
          .eq('is_published', true)
          .order('due_date', ascending: false);

      return (response as List)
          .map((json) => AssessmentModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching assessments by skill: $e');
      return [];
    }
  }
}
