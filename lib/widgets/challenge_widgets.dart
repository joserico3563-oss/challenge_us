import 'package:flutter/material.dart';

import 'package:challenge_us/models/challenge.dart';
import 'package:challenge_us/theme/app_colors.dart';
import 'package:challenge_us/theme/app_theme.dart';
import 'package:challenge_us/widgets/common_widgets.dart';

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

String formatRemaining(Duration duration) {
  final totalMinutes = (duration.inSeconds + 59) ~/ 60;
  if (totalMinutes <= 0) return 'menos de 1 min';
  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;
  if (hours > 0) return minutes == 0 ? '$hours h' : '$hours h $minutes min';
  return '$minutes min';
}

String formatClock(DateTime time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String challengeTimeLabel(Challenge challenge, ChallengeStatus status, DateTime now) {
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

/// Tarjeta protagonista del reto en la pantalla de Inicio.
class ChallengeHeroCard extends StatelessWidget {
  const ChallengeHeroCard({
    super.key,
    required this.challenge,
    required this.status,
    required this.now,
    required this.groupCompleted,
    required this.onTap,
  });

  final Challenge challenge;
  final ChallengeStatus status;
  final DateTime now;
  final int groupCompleted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final active = status == ChallengeStatus.available;
    final progress =
        challenge.totalMembers == 0 ? 0.0 : groupCompleted / challenge.totalMembers;

    return CCCard(
      highlight: active,
      padding: const EdgeInsets.all(20),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.yellowSoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(challenge.category.icon, color: AppColors.yellow, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    InfoPill(label: challenge.category.label, color: AppColors.yellow),
                    InfoPill(
                      label: challenge.difficulty.label,
                      color: challenge.difficulty.color,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(challenge.title, style: AppText.display),
          const SizedBox(height: 8),
          Text(
            challenge.objective,
            style: AppText.bodyMuted,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              InfoPill(
                label: challengeTimeLabel(challenge, status, now),
                icon: Icons.timer_outlined,
                color: active ? AppColors.yellow : AppColors.textSecondary,
              ),
              InfoPill(label: status.label, icon: status.icon, color: status.color),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Progreso del bonche', style: AppText.label),
              Text(
                '$groupCompleted/${challenge.totalMembers}',
                style: AppText.label.copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          CCProgressBar(value: progress),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Ver reto',
            icon: Icons.arrow_forward_rounded,
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}