import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/app_state.dart';
import '../../models/models.dart';
import '../../navigation/app_routes.dart';
import '../../theme/theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openChallenge(BuildContext context, Challenge challenge) {
    Navigator.of(context)
        .pushNamed(AppRoutes.challengeDetail, arguments: challenge.id);
  }

  List<Widget> _buildContent(
    BuildContext context,
    AppState state,
    DateTime now,
  ) {
    if (state.challengesLoading || state.socialLoading) {
      return const [
        SizedBox(
          height: 280,
          child: LoadingView(label: 'Cargando tus retos...'),
        ),
      ];
    }
    final error = state.challengesError;
    if (error != null) {
      return [
        ErrorStateView(message: error, onRetry: () => state.loadChallenges()),
      ];
    }

    final group = state.group;
    if (group != null && !group.configured) {
      final leader = state.isLeader;
      return [
        EmptyStateView(
          icon: Icons.tune_rounded,
          title: leader
              ? 'Configura los retos de tu bonche'
              : 'Tu líder está armando el plan',
          message: leader
              ? 'Elige cuántos retos al día, a qué hora y cuánto tiempo tendrá el parche para cumplirlos.'
              : 'Cuando el líder configure los horarios, aquí van a caer los retos.',
          actionLabel: leader ? 'Configurar retos' : null,
          onAction: leader
              ? () =>
                    Navigator.of(context)
                        .pushNamed(AppRoutes.boncheConfig, arguments: false)
              : null,
        ),
      ];
    }

    final focus = state.focusChallenge(now);
    final next = state.nextChallengeStart(now);
    if (focus == null) {
      return [_CookingCard(nextStart: next, now: now)];
    }

    final hasActive = state.challenges.any(
      (c) => state.statusOf(c, now) == ChallengeStatus.available,
    );
    final others = state.otherChallenges(now);
    return [
      if (!hasActive) ...[
        _CookingCard(nextStart: next, now: now),
        const SizedBox(height: 20),
      ],
      ChallengeHeroCard(
        challenge: focus,
        status: state.statusOf(focus, now),
        now: now,
        groupCompleted: state.groupCompleted(focus),
        onTap: () => _openChallenge(context, focus),
      ),
      if (others.isNotEmpty) ...[
        const SizedBox(height: 28),
        const Text('Más retos de hoy', style: AppText.heading),
        const SizedBox(height: 12),
        for (final challenge in others)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ChallengeTile(
              challenge: challenge,
              status: state.statusOf(challenge, now),
              now: now,
              onTap: () => _openChallenge(context, challenge),
            ),
          ),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    return TickBuilder(
      builder: (context, now) {
        final state = AppScope.of(context);
        final user = state.user;
        final level = state.levelInfo;
        final streakText =
            'Racha ${user.streak} ${user.streak == 1 ? 'día' : 'días'}';

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Text('Hola, ${user.firstName}', style: AppText.title),
            const SizedBox(height: 4),
            const Text(
              'Hoy hay bonche. ¿Vas pa esa?',
              style: AppText.bodyMuted,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ValueChip(
                  icon: Icons.bolt_rounded,
                  text: '${user.xp} XP',
                  color: AppColors.yellow,
                ),
                ValueChip(
                  icon: Icons.monetization_on_rounded,
                  text: '${user.coins} Barras',
                  color: AppColors.yellow,
                ),
                ValueChip(
                  icon: Icons.local_fire_department_rounded,
                  text: streakText,
                  color: AppColors.orange,
                ),
                ValueChip(
                  icon: Icons.military_tech_rounded,
                  text: 'Nivel ${level.level}',
                  color: AppColors.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 20),
            ..._buildCycleCards(context, state, now),
            ..._buildContent(context, state, now),
          ],
        );
      },
    );
  }
}

/// Pantalla de espera mientras no hay un reto activo.
class _CookingCard extends StatelessWidget {
  const _CookingCard({required this.nextStart, required this.now});

  final DateTime? nextStart;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final next = nextStart;
    final countdown = next == null
        ? null
        : 'Próximo reto en ${formatRemaining(next.difference(now))}';

    return CCCard(
      highlight: true,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: const BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              'assets/larecocha/branding/llamareto.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Relájate, un nuevo reto viene embalao'",
            textAlign: TextAlign.center,
            style: AppText.title,
          ),
          const SizedBox(height: 8),
          const Text(
            'Esto se cocina a fuego lento, como el sancocho del domingo. Ve estirando las piernas y avísale al parche.',
            textAlign: TextAlign.center,
            style: AppText.bodyMuted,
          ),
          if (countdown != null) ...[
            const SizedBox(height: 16),
            InfoPill(
              label: countdown,
              icon: Icons.timer_outlined,
              color: AppColors.yellow,
            ),
          ],
        ],
      ),
    );
  }
}

class _ChallengeTile extends StatelessWidget {
  const _ChallengeTile({
    required this.challenge,
    required this.status,
    required this.now,
    required this.onTap,
  });

  final Challenge challenge;
  final ChallengeStatus status;
  final DateTime now;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CCCard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.yellowSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(challenge.category.icon, color: AppColors.yellow),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.title,
                  style: AppText.heading,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  challengeTimeLabel(challenge, status, now),
                  style: AppText.bodyMuted,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InfoPill(label: status.label, icon: status.icon, color: status.color),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Ciclo de evidencias: avisos de calificacion y resultados
// -----------------------------------------------------------------------------

List<Widget> _buildCycleCards(
  BuildContext context,
  AppState state,
  DateTime now,
) {
  final cards = <Widget>[];
  for (final notice in state.rewardNotices) {
    cards.add(
      _RewardNoticeCard(
        notice: notice,
        onDismiss: () => state.dismissReward(notice),
      ),
    );
    cards.add(const SizedBox(height: 12));
  }
  final pending = state.pendingVotes;
  if (pending.isEmpty) {
    cards.add(
      _EmptyVotesCard(
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.vote),
      ),
    );
    cards.add(const SizedBox(height: 12));
  } else {
    DateTime? earliest;
    for (final item in pending) {
      final end = item.votingEndsAt;
      if (end != null && (earliest == null || end.isBefore(earliest))) {
        earliest = end;
      }
    }
    cards.add(
      _PendingVotesCard(
        count: pending.length,
        endsAt: earliest,
        now: now,
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.vote),
      ),
    );
    cards.add(const SizedBox(height: 12));
  }
  return cards;
}

class _PendingVotesCard extends StatelessWidget {
  const _PendingVotesCard({
    required this.count,
    required this.endsAt,
    required this.now,
    required this.onTap,
  });

  final int count;
  final DateTime? endsAt;
  final DateTime now;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final end = endsAt;
    final remaining = end?.difference(now);
    final timeText = remaining == null
        ? null
        : (remaining.isNegative
              ? 'Cerrando la votación...'
              : 'Cierra en ${formatRemaining(remaining)}');

    return CCCard(
      highlight: true,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.how_to_vote_rounded, color: AppColors.yellow),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  count == 1
                      ? 'Tienes 1 evidencia por calificar'
                      : 'Tienes $count evidencias por calificar',
                  style: AppText.heading,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Si no calificas todas, pierdes las recompensas del reto.',
            style: AppText.bodyMuted,
          ),
          if (timeText != null) ...[
            const SizedBox(height: 10),
            InfoPill(
              label: timeText,
              icon: Icons.timer_outlined,
              color: AppColors.yellow,
            ),
          ],
          const SizedBox(height: 14),
          PrimaryButton(
            label: 'Calificar ahora',
            icon: Icons.arrow_forward_rounded,
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}

class _RewardNoticeCard extends StatelessWidget {
  const _RewardNoticeCard({required this.notice, required this.onDismiss});

  final RewardNotice notice;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final paid = notice.paid;
    final color = paid ? AppColors.success : AppColors.textSecondary;

    return CCCard(
      highlight: paid,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                paid ? Icons.emoji_events_rounded : Icons.info_outline_rounded,
                color: color,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  notice.challengeTitle,
                  style: AppText.heading,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            notice.message.isEmpty
                ? 'Ya está el resultado de este reto.'
                : notice.message,
            style: AppText.bodyMuted,
          ),
          if (paid) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                InfoPill(
                  label: '+${notice.xp} XP',
                  icon: Icons.bolt_rounded,
                  color: AppColors.yellow,
                ),
                InfoPill(
                  label: '+${notice.coins} Barras',
                  icon: Icons.monetization_on_rounded,
                  color: AppColors.yellow,
                ),
              ],
            ),
          ],
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onDismiss,
              child: const Text('Entendido'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyVotesCard extends StatelessWidget {
  const _EmptyVotesCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CCCard(
      onTap: onTap,
      child: const Row(
        children: [
          Icon(Icons.how_to_vote_rounded, color: AppColors.yellow),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Por el momento no hay ninguna evidencia o ya las calificaste todas.',
              style: AppText.bodyMuted,
            ),
          ),
        ],
      ),
    );
  }
}
