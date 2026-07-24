import 'package:vishnu_mobile/features/auth/domain/models/profile.dart';

abstract class AuthRepository {
  Future<Profile> login(String username, String password);
  Future<void> logout();
}
