import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:psg_app/features/skills/data/skill_repository.dart';
import 'package:psg_app/features/skills/domain/models/domain_model.dart';
import 'package:psg_app/features/skills/domain/models/skill_model.dart';

final domainsProvider = FutureProvider.autoDispose<List<DomainModel>>((ref) async {
  final repository = ref.watch(skillRepositoryProvider);
  return repository.getDomains();
});

final skillsByDomainProvider = FutureProvider.family.autoDispose<List<SkillModel>, String>((ref, domainId) async {
  final repository = ref.watch(skillRepositoryProvider);
  return repository.getSkillsByDomain(domainId);
});

final skillDetailProvider = FutureProvider.family.autoDispose<SkillModel?, String>((ref, skillId) async {
  final repository = ref.watch(skillRepositoryProvider);
  return repository.getSkillDetail(skillId);
});

final allSkillsProvider = FutureProvider.autoDispose<List<SkillModel>>((ref) async {
  final repository = ref.watch(skillRepositoryProvider);
  return repository.getAllSkills();
});

final studentSkillsProvider = FutureProvider.autoDispose<List<SkillModel>>((ref) async {
  final repository = ref.watch(skillRepositoryProvider);
  return repository.getStudentSkills();
});

class _SkillSearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setSearch(String value) => state = value;
}

final skillSearchProvider = NotifierProvider<_SkillSearchNotifier, String>(
  () => _SkillSearchNotifier(),
);

final searchedSkillsProvider = FutureProvider.autoDispose<List<SkillModel>>((ref) async {
  final query = ref.watch(skillSearchProvider);
  if (query.trim().isEmpty) {
    return [];
  }
  final repository = ref.watch(skillRepositoryProvider);
  return repository.searchSkills(query);
});
