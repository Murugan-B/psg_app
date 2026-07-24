import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vishnu_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:vishnu_mobile/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:vishnu_mobile/features/auth/domain/models/profile.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return MockAuthRepository();
});

class AuthNotifier extends AsyncNotifier<Profile?> {
  @override
  FutureOr<Profile?> build() {
    return null;
  }

  Future<void> login(String username, String password) async {
    state = const AsyncLoading();
    try {
      final profile = await ref.read(authRepositoryProvider).login(username, password);
      state = AsyncData(profile);
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

final authProvider = AsyncNotifierProvider<AuthNotifier, Profile?>(() {
  return AuthNotifier();
});
