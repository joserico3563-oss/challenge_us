import 'permission.dart';

enum ChallengeCategory {
  observacion('Observación'),
  creatividad('Creatividad'),
  movimiento('Movimiento'),
  ingenio('Ingenio');

  const ChallengeCategory(this.label);
  final String label;
}

enum ChallengeDifficulty {
  facil('Fácil'),
  medio('Medio'),
  dificil('Difícil');

  const ChallengeDifficulty(this.label);
  final String label;
}

/// Tipo de evidencia que pide un reto (hoy solo se usa la foto).
enum EvidenceType { photo, drawing, voice }

/// Estado personal del usuario frente a un reto.
enum ChallengeStatus { available, upcoming, completed, expired }

class Challenge {
  const Challenge({
    required this.id,
    required this.title,
    required this.objective,
    required this.description,
    required this.rules,
    required this.category,
    required this.difficulty,
    required this.evidenceType,
    required this.points,
    required this.xpReward,
    required this.coinReward,
    required this.startsAt,
    required this.endsAt,
    required this.completedBy,
    required this.totalMembers,
    this.requiredPermissions = const [AppPermission.camera],
  });

  final String id;
  final String title;
  final String objective;
  final String description;
  final List<String> rules;
  final ChallengeCategory category;
  final ChallengeDifficulty difficulty;
  final EvidenceType evidenceType;

  /// Permisos que hay que tener concedidos antes de capturar la evidencia.
  final List<AppPermission> requiredPermissions;

  final int points;
  final int xpReward;
  final int coinReward;
  final DateTime startsAt;
  final DateTime endsAt;

  /// Integrantes del grupo que ya lo completaron (sin contar al usuario).
  final int completedBy;
  final int totalMembers;

  Duration timeLeft(DateTime now) => endsAt.difference(now);
  Duration timeUntilStart(DateTime now) => startsAt.difference(now);
}