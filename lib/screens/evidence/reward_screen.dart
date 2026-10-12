import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../navigation/app_routes.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

// -----------------------------------------------------------------------------
// Recompensa
// -----------------------------------------------------------------------------

class RewardScreen extends StatelessWidget {
  const RewardScreen({super.key, required this.result});

  final RewardResult result;

  void _goHome(BuildContext context) {
    Navigator.of(context).popUntil(ModalRoute.withName(AppRoutes.main));
  }

  @override
  Widget build(BuildContext context) {
    final streakText =
        '${result.streak} ${result.streak == 1 ? 'día' : 'días'}';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, popResult) {
        if (!didPop) _goHome(context);
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) =>
                          Transform.scale(scale: value, child: child),
                      child: Container(
                        width: 104,
                        height: 104,
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.16),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle_rounded,
                          size: 64,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('¡Reto completado!', style: AppText.display),
                    const SizedBox(height: 8),
                    Text(
                      result.challengeTitle,
                      textAlign: TextAlign.center,
                      style: AppText.bodyMuted,
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: StatBox(
                            icon: Icons.bolt_rounded,
                            value: '+${result.xpGained}',
                            label: 'XP',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatBox(
                            icon: Icons.monetization_on_rounded,
                            value: '+${result.coinsGained}',
                            label: 'MONEDAS',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatBox(
                            icon: Icons.local_fire_department_rounded,
                            color: AppColors.orange,
                            value: streakText,
                            label: 'RACHA',
                          ),
                        ),
                      ],
                    ),
                    if (result.doubleXpUsed) ...[
                      const SizedBox(height: 16),
                      const CCCard(
                        child: Row(
                          children: [
                            Icon(Icons.bolt_rounded, color: AppColors.yellow, size: 28),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Doble XP aplicado: tu ventaja de la tienda duplicó el XP de este reto.',
                                style: AppText.bodyMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (result.leveledUp) ...[
                      const SizedBox(height: 16),
                      CCCard(
                        highlight: true,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.military_tech_rounded,
                              color: AppColors.yellow,
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '¡Subiste al nivel ${result.level}!',
                                    style: AppText.heading,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(result.levelTitle, style: AppText.bodyMuted),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: PrimaryButton(
              label: 'Volver al inicio',
              icon: Icons.home_rounded,
              onPressed: () => _goHome(context),
            ),
          ),
        ),
      ),
    );
  }
}