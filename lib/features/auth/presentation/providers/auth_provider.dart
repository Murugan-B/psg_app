import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vishnu_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:vishnu_mobile/features/auth/data/repositories/mock_auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return MockAuthRepository();
});

class AuthNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> login(String username, String password) async {
    state = const AsyncLoading();
    try {
      await ref.read(authRepositoryProvider).login(username, password);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    try {
      await ref.read(authRepositoryProvider).logout();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, void>(() {
  return AuthNotifier();
});
