import 'challenge.dart';

/// Evidencia capturada con la cámara de la app para un reto.
class Evidence {
  const Evidence({
    required this.id,
    required this.challengeId,
    required this.filePath,
    required this.type,
    required this.capturedAt,
  });

  final String id;
  final String challengeId;
  final String filePath;
  final EvidenceType type;
  final DateTime capturedAt;
}

/// Resultado de validar una evidencia (hoy mock; mañana IA o el grupo).
class ValidationResult {
  const ValidationResult({required this.approved, required this.message});

  final bool approved;
  final String message;
}

/// Resultado final mostrado en la pantalla de recompensa.
class RewardResult {
  const RewardResult({
    required this.approved,
    required this.message,
    required this.challengeTitle,
    this.xpGained = 0,
    this.coinsGained = 0,
    this.streak = 0,
    this.leveledUp = false,
    this.level = 1,
    this.levelTitle = '',
    this.doubleXpUsed = false,
  });

  factory RewardResult.rejected({
    required String challengeTitle,
    required String message,
  }) {
    return RewardResult(
      approved: false,
      message: message,
      challengeTitle: challengeTitle,
    );
  }

  final bool approved;
  final String message;
  final String challengeTitle;
  final int xpGained;
  final int coinsGained;
  final int streak;
  final bool leveledUp;
  final int level;
  final String levelTitle;
  final bool doubleXpUsed;
}