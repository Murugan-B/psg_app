import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:psg_app/core/auth/auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthStateNotifier extends ChangeNotifier {
  final AuthRepository _authRepo;

  AuthStatus _status = AuthStatus.unknown;

  AuthStatus get status => _status;

  AuthStateNotifier(this._authRepo) {
    _init();
  }

  void _init() {
    final session = _authRepo.currentSession;
    if (session != null) {
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    _authRepo.authStateChanges.listen((authState) {
      final event = authState.event;
      final session = authState.session;
      if (event == AuthChangeEvent.signedIn || session != null) {
        if (_status != AuthStatus.authenticated) {
          _status = AuthStatus.authenticated;
          notifyListeners();
        }
      } else if (event == AuthChangeEvent.signedOut || session == null) {
        if (_status != AuthStatus.unauthenticated) {
          _status = AuthStatus.unauthenticated;
          notifyListeners();
        }
      }
    });
  }
}

final authStateNotifierProvider = Provider<AuthStateNotifier>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return AuthStateNotifier(authRepo);
});

final authStatusProvider = Provider<AuthStatus>((ref) {
  return ref.watch(authStateNotifierProvider).status;
});
