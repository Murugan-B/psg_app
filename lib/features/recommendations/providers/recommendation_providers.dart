import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:psg_app/features/recommendations/data/recommendation_repository.dart';
import 'package:psg_app/features/recommendations/domain/models/recommendation_model.dart';
import 'package:psg_app/features/recommendations/domain/models/recommendation_rule_model.dart';

final recommendationRulesProvider = FutureProvider.autoDispose<List<RecommendationRuleModel>>((ref) async {
  final repository = ref.watch(recommendationRepositoryProvider);
  return repository.getRecommendationRules();
});

final myRecommendationsProvider = FutureProvider.autoDispose<List<RecommendationModel>>((ref) async {
  final repository = ref.watch(recommendationRepositoryProvider);
  return repository.getMyRecommendations();
});

final activeRecommendationsProvider = FutureProvider.autoDispose<List<RecommendationModel>>((ref) async {
  final repository = ref.watch(recommendationRepositoryProvider);
  final all = await repository.getMyRecommendations();
  final now = DateTime.now();
  return all.where((r) =>
    !r.isDismissed && !r.isCompleted &&
    (r.validUntil == null || r.validUntil!.isAfter(now))
  ).toList();
});

final recommendationActionProvider = Provider.family<RecommendationActions, String>((ref, recommendationId) {
  final repository = ref.watch(recommendationRepositoryProvider);
  return RecommendationActions(repository, recommendationId);
});

class RecommendationActions {
  final RecommendationRepository _repository;
  final String recommendationId;

  RecommendationActions(this._repository, this.recommendationId);

  Future<void> dismiss() async {
    await _repository.dismissRecommendation(recommendationId);
  }

  Future<void> markCompleted() async {
    await _repository.markRecommendationCompleted(recommendationId);
  }
}
