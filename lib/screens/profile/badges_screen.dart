// LA_RECOCHA_ENTREGA_FINAL
import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../navigation/app_routes.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

// -----------------------------------------------------------------------------
// Insignias: resumen para el perfil y catálogo completo
// -----------------------------------------------------------------------------

/// Resumen que se muestra en el perfil.
class BadgesSummaryCard extends StatelessWidget {
  const BadgesSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final total = BadgeCatalog.all.length;
    final unlocked =
        BadgeCatalog.all.where((b) => BadgeCatalog.isUnlocked(b.id)).length;

    return CCCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events_rounded, color: AppColors.yellow),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '$unlocked de $total desbloqueadas',
                  style: AppText.heading,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final badge in BadgeCatalog.all.take(8))
                _BadgeDot(badge: badge),
            ],
          ),
          const SizedBox(height: 14),
          SecondaryButton(
            label: 'Ver catálogo de insignias',
            icon: Icons.arrow_forward_rounded,
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.badges),
          ),
        ],
      ),
    );
  }
}

class _BadgeDot extends StatelessWidget {
  const _BadgeDot({required this.badge});

  final BadgeInfo badge;

  @override
  Widget build(BuildContext context) {
    final unlocked = BadgeCatalog.isUnlocked(badge.id);
    return Tooltip(
      message: badge.name,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: unlocked ? AppColors.yellowSoft : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          badge.icon,
          size: 22,
          color: unlocked
              ? AppColors.yellow
              : AppColors.textSecondary.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

/// Catálogo completo con filtro de bloqueadas y desbloqueadas.
class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key});

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final all = BadgeCatalog.all;
    final shown = all.where((b) {
      final unlocked = BadgeCatalog.isUnlocked(b.id);
      if (_tab == 1) return !unlocked;
      if (_tab == 2) return unlocked;
      return true;
    }).toList();
    final unlockedCount = all.where((b) => BadgeCatalog.isUnlocked(b.id)).length;

    return Scaffold(
      appBar: ccAppBar('Insignias'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          CCCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$unlockedCount de ${all.length} desbloqueadas',
                  style: AppText.heading,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Las insignias se consiguen por hitos dentro de La Recocha. No se compran en la tienda.',
                  style: AppText.bodyMuted,
                ),
                const SizedBox(height: 6),
                const Text(
                  'El desbloqueo automático todavía no está activo: por ahora todas aparecen bloqueadas.',
                  style: AppText.bodyMuted,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SegmentedTabs(
            labels: const ['Todas', 'Bloqueadas', 'Desbloqueadas'],
            selected: _tab,
            onChanged: (i) => setState(() => _tab = i),
          ),
          const SizedBox(height: 16),
          if (shown.isEmpty)
            const CCCard(
              child: Text(
                'Todavía no tienes insignias desbloqueadas.',
                style: AppText.bodyMuted,
              ),
            )
          else
            for (final badge in shown)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _BadgeCard(badge: badge),
              ),
        ],
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.badge});

  final BadgeInfo badge;

  @override
  Widget build(BuildContext context) {
    final unlocked = BadgeCatalog.isUnlocked(badge.id);
    final color = unlocked ? AppColors.yellow : AppColors.textSecondary;

    return CCCard(
      highlight: unlocked,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: unlocked ? AppColors.yellowSoft : AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              badge.icon,
              size: 28,
              color: unlocked ? AppColors.yellow : color.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(badge.name, style: AppText.heading),
                    InfoPill(
                      label: unlocked ? 'Desbloqueada' : 'Bloqueada',
                      icon: unlocked ? Icons.check_rounded : Icons.lock_rounded,
                      color: unlocked ? AppColors.success : AppColors.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(badge.description, style: AppText.bodyMuted),
                const SizedBox(height: 8),
                const Text('REQUISITO', style: AppText.label),
                const SizedBox(height: 2),
                Text(badge.requirement, style: AppText.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
