import 'package:flutter/material.dart';

import 'package:challenge_us/app/app_scope.dart';
import 'package:challenge_us/navigation/app_routes.dart';
import 'package:challenge_us/screens/bonche/bonche_screen.dart';
import 'package:challenge_us/screens/home/home_screen.dart';
import 'package:challenge_us/screens/ranking/ranking_screen.dart';
import 'package:challenge_us/screens/store/store_screen.dart';
import 'package:challenge_us/theme/app_colors.dart';
import 'package:challenge_us/widgets/app_logo.dart';
import 'package:challenge_us/widgets/common_widgets.dart';
import 'package:challenge_us/widgets/state_views.dart';

/// Contenedor principal: barra superior + 4 secciones + barra inferior.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _openProfile() {
    Navigator.of(context).pushNamed(AppRoutes.profile);
  }

  void _openNotifications() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const SizedBox(
        height: 300,
        child: EmptyStateView(
          icon: Icons.notifications_none_rounded,
          title: 'Sin notificaciones',
          message:
              'Aquí verás cuando salga un reto nuevo o tu bonche te escriba.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AppScope.of(context).user;

    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) setState(() => _index = 0);
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          titleSpacing: 20,
          title: const AppLogo(size: 28),
          actions: [
            IconButton(
              tooltip: 'Notificaciones',
              onPressed: _openNotifications,
              icon: const Icon(Icons.notifications_none_rounded),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 4, right: 16),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _openProfile,
                child: UserAvatar(initials: user.initials),
              ),
            ),
          ],
        ),
        body: IndexedStack(
          index: _index,
          children: const [
            HomeScreen(),
            BoncheScreen(),
            RankingScreen(),
            StoreScreen(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Inicio',
            ),
            NavigationDestination(
              icon: Icon(Icons.groups_outlined),
              selectedIcon: Icon(Icons.groups_rounded),
              label: 'Bonche',
            ),
            NavigationDestination(
              icon: Icon(Icons.leaderboard_outlined),
              selectedIcon: Icon(Icons.leaderboard_rounded),
              label: 'Ranking',
            ),
            NavigationDestination(
              icon: Icon(Icons.storefront_outlined),
              selectedIcon: Icon(Icons.storefront_rounded),
              label: 'Tienda',
            ),
          ],
        ),
      ),
    );
  }
}