import '../models/models.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import 'auth_service.dart';

/// Login y registro reales contra la API de Render
/// (POST /api/auth/login y POST /api/auth/register, con cuerpo JSON).
/// El JWT que devuelve la API queda guardado en [ApiService] y se adjunta
/// automáticamente a todas las peticiones privadas.
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
    final session = await ApiService.login(
      email: cleanEmail,
      password: password,
    );
    return _toProfile(session.user, cleanEmail);
  }

  @override
  Future<UserProfile> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final cleanEmail = email.trim();
    final name = displayName.trim();
    final session = await ApiService.register(
      email: cleanEmail,
      password: password,
      displayName: name,
    );
    return _toProfile(session.user, cleanEmail, fallbackName: name);
  }

  /// Convierte el usuario de la API al perfil que usa la app.
  static UserProfile _toProfile(
    UserModel user,
    String email, {
    String fallbackName = '',
  }) {
    final apiName = user.displayName.trim();
    final name = apiName.isNotEmpty
        ? apiName
        : (fallbackName.isNotEmpty ? fallbackName : _nameFromEmail(email));
    return UserProfile(
      id: user.id,
      displayName: name,
      email: user.email.isEmpty ? email : user.email,
      xp: user.xp,
      coins: user.coins,
      streak: user.streak,
      bestStreak: user.bestStreak,
      completedChallenges: user.completedChallenges,
    );
  }

  @override
  Future<void> signOut() async {
    await ApiService.logout();
  }

  Future<UserProfile?> restoreSession() async {
    final user = await ApiService.restoreWebSession();
    if (user == null) return null;
    return _toProfile(user, user.email);
  }

  static String _nameFromEmail(String email) {
    final local = email
        .split('@')
        .first
        .replaceAll(RegExp(r'[._\-]+'), ' ')
        .trim();
    if (local.isEmpty) return 'Jugador';
    return local
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => word.substring(0, 1).toUpperCase() + word.substring(1))
        .join(' ');
  }
}
