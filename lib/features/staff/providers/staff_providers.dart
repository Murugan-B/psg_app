import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:psg_app/features/staff/data/staff_repository.dart';
import 'package:psg_app/features/staff/domain/models/class_model.dart';

final myClassesProvider = FutureProvider<List<ClassModel>>((ref) async {
  final repository = ref.watch(staffRepositoryProvider);
  return repository.getMyClasses();
});

final todayTimetableProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.watch(staffRepositoryProvider);
  return repository.getTodayTimetable();
});

final weeklyTimetableProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.watch(staffRepositoryProvider);
  return repository.getWeeklyTimetable();
});

// A notifier to hold the currently selected class for attendance
class SelectedClassNotifier extends Notifier<ClassModel?> {
  @override
  ClassModel? build() => null;
  
  void setClass(ClassModel? cls) => state = cls;
}

final selectedClassProvider = NotifierProvider<SelectedClassNotifier, ClassModel?>(() {
  return SelectedClassNotifier();
});
