import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

class MemberProfileScreen extends StatelessWidget {
  const MemberProfileScreen({super.key, required this.member});

  final GroupMember member;

  @override
  Widget build(BuildContext context) {
    final xp = member.xp;
    final level = xp == null ? null : LevelSystem.fromXp(xp);

    return RecochaScaffold(
      appBar: ccAppBar('Perfil del bonchero'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Center(child: UserAvatar(initials: member.initials, radius: 44)),
          const SizedBox(height: 16),
          Center(
            child: Text(
              member.name,
              style: AppText.title,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          CCCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Nivel ${member.level}', style: AppText.heading),
                    if (level != null)
                      Text(
                        '${level.xpIntoLevel}/${level.xpForNextLevel} XP',
                        style: AppText.label,
                      ),
                  ],
                ),
                if (level != null) ...[
                  const SizedBox(height: 4),
                  Text(level.title, style: AppText.bodyMuted),
                  const SizedBox(height: 12),
                  CCProgressBar(value: level.progress),
                  const SizedBox(height: 8),
                  Text(
                    'Le faltan ${level.xpRemaining} XP para el siguiente nivel',
                    style: AppText.label,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatBox(
                  icon: Icons.bolt_rounded,
                  value: xp == null ? '-' : '$xp',
                  label: 'XP TOTAL',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatBox(
                  icon: Icons.local_fire_department_rounded,
                  color: AppColors.orange,
                  value: '${member.streak}',
                  label: 'RACHA',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatBox(
                  icon: Icons.check_circle_rounded,
                  color: AppColors.success,
                  value: member.completedChallenges?.toString() ?? '-',
                  label: 'RETOS',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const SectionTitle('Insignias'),
          CCCard(
            child: Column(
              children: [
                const Icon(
                  Icons.emoji_events_outlined,
                  size: 52,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 14),
                const Text(
                  'Tu vale todav\u00eda no tiene insignias.',
                  style: AppText.heading,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Aqu\u00ed aparecer\u00e1n sus insignias.',
                  style: AppText.bodyMuted,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
