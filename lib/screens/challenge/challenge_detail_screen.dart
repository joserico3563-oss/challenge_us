import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../models/models.dart';
import '../../navigation/app_routes.dart';
import '../../theme/theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/widgets.dart';

class ChallengeDetailScreen extends StatelessWidget {
  const ChallengeDetailScreen({super.key, required this.challengeId});

  final String challengeId;

  @override
  Widget build(BuildContext context) {
    return TickBuilder(
      builder: (context, now) {
        final state = AppScope.of(context);
        final challenge = state.challengeById(challengeId);

        if (challenge == null) {
          return Scaffold(
            appBar: ccAppBar('Reto'),
            body: ErrorStateView(
              message: 'No encontramos este reto.',
              retryLabel: 'Volver',
              onRetry: () => Navigator.of(context).maybePop(),
            ),
          );
        }

        final status = state.statusOf(challenge, now);
        final canCapture = status == ChallengeStatus.available;
        final buttonLabel = switch (status) {
          ChallengeStatus.available => 'Capturar evidencia',
          ChallengeStatus.upcoming => 'Aún no empieza',
          ChallengeStatus.completed => 'Reto completado',
          ChallengeStatus.expired => 'Tiempo agotado',
        };

        return Scaffold(
          appBar: ccAppBar('Detalle del reto'),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  InfoPill(
                    label: challenge.category.label,
                    icon: challenge.category.icon,
                    color: AppColors.yellow,
                  ),
                  InfoPill(
                    label: challenge.difficulty.label,
                    color: challenge.difficulty.color,
                  ),
                  InfoPill(label: status.label, icon: status.icon, color: status.color),
                ],
              ),
              const SizedBox(height: 14),
              Text(challenge.title, style: AppText.display),
              const SizedBox(height: 20),
              CCCard(
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined, color: AppColors.yellow),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('TIEMPO', style: AppText.label),
                          const SizedBox(height: 2),
                          Text(
                            challengeTimeLabel(challenge, status, now),
                            style: AppText.heading,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Ventana: ${formatClock(challenge.startsAt)} - ${formatClock(challenge.endsAt)}',
                            style: AppText.bodyMuted,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _InfoTile(
                      icon: Icons.stars_rounded,
                      label: 'PUNTUACIÓN',
                      value: '${challenge.points} pts',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoTile(
                      icon: Icons.card_giftcard_rounded,
                      label: 'RECOMPENSA',
                      value: '+${challenge.xpReward} XP\n+${challenge.coinReward} monedas',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Objetivo', style: AppText.heading),
              const SizedBox(height: 8),
              Text(challenge.objective, style: AppText.body),
              const SizedBox(height: 20),
              const Text('Descripción', style: AppText.heading),
              const SizedBox(height: 8),
              Text(challenge.description, style: AppText.bodyMuted),
              const SizedBox(height: 20),
              const Text('Reglas', style: AppText.heading),
              const SizedBox(height: 10),
              CCCard(
                child: Column(
                  children: [
                    for (var i = 0; i < challenge.rules.length; i++)
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: i == challenge.rules.length - 1 ? 0 : 12,
                        ),
                        child: _RuleRow(number: i + 1, text: challenge.rules[i]),
                      ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: PrimaryButton(
                label: buttonLabel,
                icon: canCapture ? Icons.camera_alt_rounded : null,
                onPressed: canCapture
                    ? () => Navigator.of(context).pushNamed(
                          AppRoutes.evidenceCapture,
                          arguments: challenge.id,
                        )
                    : null,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return CCCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.yellow, size: 22),
          const SizedBox(height: 10),
          Text(label, style: AppText.label),
          const SizedBox(height: 4),
          Text(value, style: AppText.heading),
        ],
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  const _RuleRow({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.yellowSoft,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$number',
            style: AppText.label.copyWith(color: AppColors.yellow),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: AppText.body)),
      ],
    );
  }
}