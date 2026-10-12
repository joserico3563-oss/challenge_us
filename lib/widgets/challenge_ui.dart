import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/theme.dart';
import '../utils/formatters.dart';

// --- Piezas visuales de los retos --------------------------------------------

extension ChallengeCategoryUi on ChallengeCategory {
  IconData get icon {
    switch (this) {
      case ChallengeCategory.observacion:
        return Icons.visibility_rounded;
      case ChallengeCategory.creatividad:
        return Icons.palette_rounded;
      case ChallengeCategory.movimiento:
        return Icons.directions_run_rounded;
      case ChallengeCategory.ingenio:
        return Icons.lightbulb_rounded;
    }
  }
}

extension ChallengeDifficultyUi on ChallengeDifficulty {
  Color get color {
    switch (this) {
      case ChallengeDifficulty.facil:
        return AppColors.success;
      case ChallengeDifficulty.medio:
        return AppColors.yellow;
      case ChallengeDifficulty.dificil:
        return AppColors.orange;
    }
  }
}

extension ChallengeStatusUi on ChallengeStatus {
  String get label {
    switch (this) {
      case ChallengeStatus.available:
        return 'Pendiente';
      case ChallengeStatus.upcoming:
        return 'Próximo';
      case ChallengeStatus.completed:
        return 'Completado';
      case ChallengeStatus.expired:
        return 'Expirado';
    }
  }

  Color get color {
    switch (this) {
      case ChallengeStatus.available:
        return AppColors.yellow;
      case ChallengeStatus.upcoming:
        return AppColors.textSecondary;
      case ChallengeStatus.completed:
        return AppColors.success;
      case ChallengeStatus.expired:
        return AppColors.error;
    }
  }

  IconData get icon {
    switch (this) {
      case ChallengeStatus.available:
        return Icons.hourglass_top_rounded;
      case ChallengeStatus.upcoming:
        return Icons.schedule_rounded;
      case ChallengeStatus.completed:
        return Icons.check_circle_rounded;
      case ChallengeStatus.expired:
        return Icons.timer_off_rounded;
    }
  }
}

String challengeTimeLabel(
  Challenge challenge,
  ChallengeStatus status,
  DateTime now,
) {
  switch (status) {
    case ChallengeStatus.available:
      return 'Quedan ${formatRemaining(challenge.timeLeft(now))}';
    case ChallengeStatus.upcoming:
      return 'Empieza en ${formatRemaining(challenge.timeUntilStart(now))}';
    case ChallengeStatus.completed:
      return 'Completado';
    case ChallengeStatus.expired:
      return 'Tiempo agotado';
  }
}