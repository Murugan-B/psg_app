import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:psg_app/features/competency/data/competency_repository.dart';
import 'package:psg_app/features/competency/domain/models/competency_level_model.dart';
import 'package:psg_app/features/competency/domain/models/student_competency_model.dart';

final competencyLevelsProvider = FutureProvider.autoDispose<List<CompetencyLevelModel>>((ref) async {
  final repository = ref.watch(competencyRepositoryProvider);
  return repository.getCompetencyLevels();
});

final studentCompetenciesProvider = FutureProvider.family.autoDispose<List<StudentCompetencyModel>, String>((ref, studentId) async {
  final repository = ref.watch(competencyRepositoryProvider);
  return repository.getStudentCompetencies(studentId);
});

final myCompetenciesProvider = FutureProvider.autoDispose<List<StudentCompetencyModel>>((ref) async {
  final repository = ref.watch(competencyRepositoryProvider);
  final userId = repository.currentUserId;
  if (userId == null) return [];
  return repository.getStudentCompetencies(userId);
});

final studentCompetencyProvider = FutureProvider.family.autoDispose<StudentCompetencyModel?, (String, String)>((ref, params) async {
  final (studentId, skillId) = params;
  final repository = ref.watch(competencyRepositoryProvider);
  return repository.getStudentCompetency(studentId, skillId);
});

final classCompetenciesProvider = FutureProvider.family.autoDispose<List<StudentCompetencyModel>, String>((ref, classId) async {
  final repository = ref.watch(competencyRepositoryProvider);
  return repository.getClassCompetencies(classId);
});
