import 'package:vishnu_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:vishnu_mobile/features/auth/domain/models/profile.dart';

class MockAuthRepository implements AuthRepository {
  @override
  Future<Profile> login(String username, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    if (username.isEmpty || password.isEmpty) {
      throw Exception('Missing Fields: Please enter both username and password.');
    }

    if (password != 'password123') {
      throw Exception('Invalid login credentials');
    }

    // Role simulation based on username for easy testing
    if (username.toLowerCase() == 'admin') {
      return const Profile(id: '1', role: 'admin');
    } else if (username.toLowerCase() == 'pending') {
      return const Profile(id: '2', role: 'staff', isApproved: false);
    } else {
      return const Profile(id: '3', role: 'staff');
    }
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
