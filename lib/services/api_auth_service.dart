import '../models/models.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import 'auth_service.dart';

/// Login real contra la API de Render (POST /api/auth/login?email=...).
/// El botón de Google sigue siendo simulado: la API aún no tiene endpoint para eso.
class ApiAuthService implements AuthService {
  const ApiAuthService();

  @override
  Future<UserProfile> signInWithGoogle() {
    return const MockAuthService().signInWithGoogle();
  }

  @override
  Future<UserProfile> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim();
    final UserModel user = await ApiService.login(cleanEmail);
    return UserProfile(
      id: user.id,
      displayName: user.displayName.trim().isEmpty
          ? _nameFromEmail(cleanEmail)
          : user.displayName,
      email: user.email.isEmpty ? cleanEmail : user.email,
      xp: user.xp,
      coins: user.coins,
      streak: user.streak,
      bestStreak: user.bestStreak,
      completedChallenges: user.completedChallenges,
    );
  }

  @override
  Future<void> signOut() async {}

  static String _nameFromEmail(String email) {
    final local =
        email.split('@').first.replaceAll(RegExp(r'[._\-]+'), ' ').trim();
    if (local.isEmpty) return 'Jugador';
    return local
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => word.substring(0, 1).toUpperCase() + word.substring(1))
        .join(' ');
  }
}