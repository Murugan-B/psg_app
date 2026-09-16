import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return AuthRepository(supabase);
});

class AuthRepository {
  final SupabaseClient _supabase;

  AuthRepository(this._supabase);

  User? get currentUser => _supabase.auth.currentUser;

  String? get currentUserId => _supabase.auth.currentUser?.id;

  Session? get currentSession => _supabase.auth.currentSession;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? employeeId,
    String? rollNumber,
    String? phone,
    String? departmentId,
    String? designation,
    String? department,
    String? batch,
    String? currentYear,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'role': role,
        if (employeeId != null) 'employee_id': employeeId,
        if (rollNumber != null) 'roll_number': rollNumber,
        if (phone != null) 'phone': phone,
        if (departmentId != null) 'department_id': departmentId,
        if (designation != null) 'designation': designation,
        if (department != null) 'department': department,
        if (batch != null) 'batch': batch,
        if (currentYear != null) 'current_year': currentYear,
      },
    );

    return response;
  }

  Future<bool> signInWithGoogle() async {
    return await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: const String.fromEnvironment(
        'SUPABASE_REDIRECT_URL',
        defaultValue: 'io.supabase.vishnu_mobile/auth/callback',
      ),
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
