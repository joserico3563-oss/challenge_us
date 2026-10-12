import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../navigation/app_routes.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

// -----------------------------------------------------------------------------
// Perfil / Mi Muro (una sola pantalla; contenido completo en la Entrega 3)
// -----------------------------------------------------------------------------

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final app = AppScope.read(context);
    final navigator = Navigator.of(context);
    await app.signOut();
    navigator.pushNamedAndRemoveUntil(AppRoutes.welcome, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final user = state.user;
    final level = state.levelInfo;

    return Scaffold(
      appBar: ccAppBar('Perfil / Mi Muro'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Center(child: UserAvatar(initials: user.initials, radius: 44)),
          const SizedBox(height: 16),
          Center(child: Text(user.displayName, style: AppText.title)),
          const SizedBox(height: 4),
          Center(child: Text(user.email, style: AppText.bodyMuted)),
          const SizedBox(height: 24),
          CCCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Nivel ${level.level}', style: AppText.heading),
                    Text(
                      '${level.xpIntoLevel}/${level.xpForNextLevel} XP',
                      style: AppText.label,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(level.title, style: AppText.bodyMuted),
                const SizedBox(height: 12),
                CCProgressBar(value: level.progress),
                const SizedBox(height: 8),
                Text(
                  'Te faltan ${level.xpRemaining} XP para el siguiente nivel',
                  style: AppText.label,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatBox(
                  icon: Icons.monetization_on_rounded,
                  value: '${user.coins}',
                  label: 'MONEDAS',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatBox(
                  icon: Icons.local_fire_department_rounded,
                  color: AppColors.orange,
                  value: '${user.streak}',
                  label: 'RACHA',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatBox(
                  icon: Icons.check_circle_rounded,
                  color: AppColors.success,
                  value: '${user.completedChallenges}',
                  label: 'RETOS',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const CCCard(
            child: Row(
              children: [
                Icon(Icons.emoji_events_rounded, color: AppColors.yellow),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Muy pronto: tus insignias, estadísticas y logros en un solo muro.',
                    style: AppText.bodyMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SecondaryButton(
            label: 'Cerrar sesión',
            icon: Icons.logout_rounded,
            onPressed: () => _logout(context),
          ),
        ],
      ),
    );
  }
}