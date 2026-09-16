import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:psg_app/features/resources/data/resource_repository.dart';
import 'package:psg_app/features/resources/domain/models/learning_resource_model.dart';
import 'package:psg_app/features/resources/domain/models/resource_type_model.dart';
import 'package:psg_app/features/resources/domain/models/student_resource_view_model.dart';

final resourceTypesProvider = FutureProvider.autoDispose<List<ResourceTypeModel>>((ref) async {
  final repository = ref.watch(resourceRepositoryProvider);
  return repository.getResourceTypes();
});

final allResourcesProvider = FutureProvider.autoDispose<List<LearningResourceModel>>((ref) async {
  final repository = ref.watch(resourceRepositoryProvider);
  return repository.getAllResources();
});

final resourcesBySkillProvider = FutureProvider.family.autoDispose<List<LearningResourceModel>, String>((ref, skillId) async {
  final repository = ref.watch(resourceRepositoryProvider);
  return repository.getResourcesBySkill(skillId);
});

final resourcesByDomainProvider = FutureProvider.family.autoDispose<List<LearningResourceModel>, String>((ref, domainId) async {
  final repository = ref.watch(resourceRepositoryProvider);
  return repository.getResourcesByDomain(domainId);
});

final resourceDetailProvider = FutureProvider.family.autoDispose<LearningResourceModel?, String>((ref, resourceId) async {
  final repository = ref.watch(resourceRepositoryProvider);
  return repository.getResourceDetail(resourceId);
});

final resourceViewProvider = FutureProvider.family.autoDispose<StudentResourceViewModel?, (String, String)>((ref, params) async {
  final (resourceId, studentId) = params;
  final repository = ref.watch(resourceRepositoryProvider);
  return repository.getResourceView(resourceId, studentId);
});

final userResourcesProvider = FutureProvider.autoDispose<List<LearningResourceModel>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];
  final repository = ref.watch(resourceRepositoryProvider);
  final all = await repository.getAllResources();
  final result = <LearningResourceModel>[];
  for (final resource in all) {
    final view = await repository.getResourceView(resource.id, userId);
    resource.studentProgress = view?.completionPercentage;
    resource.studentCompleted = view?.completed;
    result.add(resource);
  }
  return result;
});

final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(resourceRepositoryProvider).currentUserId;
});
