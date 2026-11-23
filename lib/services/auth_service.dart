import '../data/mock_data.dart';
import '../models/models.dart';

abstract class AuthService {
  Future<UserProfile> signInWithGoogle();

  Future<UserProfile> signInWithEmail({
    required String email,
    required String password,
  });

  Future<UserProfile> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  });

  Future<void> signOut();
}

class MockAuthService implements AuthService {
  const MockAuthService();

  @override
  Future<UserProfile> signInWithGoogle() async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    return MockData.userFor(
      email: 'daniel@gmail.com',
      displayName: 'Daniel Escudero',
    );
  }

  @override
  Future<UserProfile> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    return MockData.userFor(email: email.trim());
  }

  @override
  Future<UserProfile> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    return MockData.userFor(email: email.trim(), displayName: displayName.trim());
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
}