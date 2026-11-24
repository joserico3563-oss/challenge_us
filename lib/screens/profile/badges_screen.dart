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
                  '$total insignias del bonche',
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
              for (final badge in BadgeCatalog.all) _BadgeDot(badge: badge),
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
    return Tooltip(
      message: badge.name,
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: _BadgeArtwork(badge: badge),
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
  @override
  Widget build(BuildContext context) {
    final all = BadgeCatalog.all;
    final shown = all;

    return RecochaScaffold(
      appBar: ccAppBar('Insignias'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          CCCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${all.length} insignias del bonche',
                  style: AppText.heading,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Las insignias se consiguen por hitos dentro de La Recocha. No se compran en la tienda.',
                  style: AppText.bodyMuted,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Explora las insignias y sus requisitos. El sistema de desbloqueo no está disponible.',
                  style: AppText.bodyMuted,
                ),
              ],
            ),
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
    return CCCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: _BadgeArtwork(badge: badge),
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
                  children: [Text(badge.name, style: AppText.heading)],
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

class _BadgeArtwork extends StatelessWidget {
  const _BadgeArtwork({required this.badge});

  final BadgeInfo badge;

  @override
  Widget build(BuildContext context) {
    return Image.asset(badge.assetPath, fit: BoxFit.contain);
  }
}
