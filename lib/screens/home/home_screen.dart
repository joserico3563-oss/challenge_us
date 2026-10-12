import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/app_state.dart';
import '../../models/models.dart';
import '../../navigation/app_routes.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openChallenge(BuildContext context, Challenge challenge) {
    Navigator.of(context).pushNamed(
      AppRoutes.challengeDetail,
      arguments: challenge.id,
    );
  }

  List<Widget> _buildContent(BuildContext context, AppState state, DateTime now) {
    if (state.challengesLoading) {
      return const [
        SizedBox(height: 280, child: LoadingView(label: 'Cargando tus retos...')),
      ];
    }
    final error = state.challengesError;
    if (error != null) {
      return [ErrorStateView(message: error, onRetry: () => state.loadChallenges())];
    }
    final focus = state.focusChallenge(now);
    if (focus == null) {
      return const [
        EmptyStateView(
          icon: Icons.emoji_events_rounded,
          title: 'Hoy no hay retos',
          message: 'Cuando tu bonche tenga un reto, aparecerá aquí.',
        ),
      ];
    }

    final others = state.otherChallenges(now);
    return [
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
                  icon: Icons.monetization_on_rounded,
                  text: '${user.coins} monedas',
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
            ..._buildContent(context, state, now),
          ],
        );
      },
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