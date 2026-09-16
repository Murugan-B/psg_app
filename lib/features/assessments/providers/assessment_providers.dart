import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:psg_app/features/assessments/data/assessment_repository.dart';
import 'package:psg_app/features/assessments/domain/models/assessment_model.dart';
import 'package:psg_app/features/assessments/domain/models/assessment_response_model.dart';
import 'package:psg_app/features/assessments/domain/models/assessment_score_model.dart';
import 'package:psg_app/features/assessments/domain/models/assessment_type_model.dart';
import 'package:psg_app/features/assessments/domain/models/question_model.dart';

final assessmentTypesProvider = FutureProvider.autoDispose<List<AssessmentTypeModel>>((ref) async {
  final repository = ref.watch(assessmentRepositoryProvider);
  return repository.getAssessmentTypes();
});

final publishedAssessmentsProvider = FutureProvider.autoDispose<List<AssessmentModel>>((ref) async {
  final repository = ref.watch(assessmentRepositoryProvider);
  return repository.getPublishedAssessments();
});

final assessmentDetailProvider = FutureProvider.family.autoDispose<AssessmentModel?, String>((ref, assessmentId) async {
  final repository = ref.watch(assessmentRepositoryProvider);
  return repository.getAssessmentDetail(assessmentId);
});

final assessmentQuestionsProvider = FutureProvider.family.autoDispose<List<QuestionModel>, String>((ref, assessmentId) async {
  final repository = ref.watch(assessmentRepositoryProvider);
  return repository.getAssessmentQuestions(assessmentId);
});

final myScoresProvider = FutureProvider.autoDispose<List<AssessmentScoreModel>>((ref) async {
  final repository = ref.watch(assessmentRepositoryProvider);
  final userId = repository.currentUserId;
  if (userId == null) return [];
  return repository.getStudentScores(userId);
});

final assessmentScoreProvider = FutureProvider.family.autoDispose<AssessmentScoreModel?, (String, String)>((ref, params) async {
  final (assessmentId, studentId) = params;
  final repository = ref.watch(assessmentRepositoryProvider);
  return repository.getStudentScore(assessmentId, studentId);
});

final canAttemptProvider = FutureProvider.family.autoDispose<bool, String>((ref, assessmentId) async {
  final repository = ref.watch(assessmentRepositoryProvider);
  return repository.canAttempt(assessmentId);
});

final nextAttemptProvider = FutureProvider.family.autoDispose<int, (String, String)>((ref, params) async {
  final (assessmentId, studentId) = params;
  final repository = ref.watch(assessmentRepositoryProvider);
  return repository.getNextAttemptNumber(assessmentId, studentId);
});

class _AssessmentResponseNotifier extends Notifier<List<AssessmentResponseModel>> {
  @override
  List<AssessmentResponseModel> build() => [];

  void addResponse(AssessmentResponseModel response) {
    state = [
      ...state.where((r) => r.questionId != response.questionId),
      response,
    ];
  }

  void updateResponse(String questionId, {String? selectedOptionId, String? textAnswer, double? numericAnswer}) {
    final existing = state.where((r) => r.questionId == questionId).toList();
    if (existing.isEmpty) {
      state = [...state];
    } else {
      final updated = existing.first.copyWith(
        selectedOptionId: selectedOptionId,
        textAnswer: textAnswer,
        numericAnswer: numericAnswer,
      );
      state = [
        ...state.where((r) => r.questionId != questionId),
        updated,
      ];
    }
  }

  AssessmentResponseModel? getResponse(String questionId) {
    final matches = state.where((r) => r.questionId == questionId);
    return matches.isEmpty ? null : matches.first;
  }

  void clear() {
    state = [];
  }
}

final assessmentResponseProvider = NotifierProvider<_AssessmentResponseNotifier, List<AssessmentResponseModel>>(
  () => _AssessmentResponseNotifier(),
);
