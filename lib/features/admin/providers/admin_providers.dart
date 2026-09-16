import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:psg_app/features/admin/data/admin_repository.dart';

final adminStaffListProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final adminRepo = ref.watch(adminRepositoryProvider);
  return await adminRepo.getAllStaff();
});

final adminStudentListProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final adminRepo = ref.watch(adminRepositoryProvider);
  return await adminRepo.getAllStudents();
});

final adminClassesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final adminRepo = ref.watch(adminRepositoryProvider);
  return await adminRepo.getClasses();
});

final adminTimetableProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, classId) async {
  final adminRepo = ref.watch(adminRepositoryProvider);
  return await adminRepo.getTimetableForClass(classId);
});

final adminDashboardStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final adminRepo = ref.watch(adminRepositoryProvider);
  return await adminRepo.getDashboardStats();
});
