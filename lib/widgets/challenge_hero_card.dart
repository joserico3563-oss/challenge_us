import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/theme.dart';
import 'buttons.dart';
import 'cc_card.dart';
import 'cc_progress_bar.dart';
import 'challenge_ui.dart';
import 'info_pill.dart';

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