import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../navigation/app_routes.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import '../bonche/bonche_screen.dart';
import '../home/home_screen.dart';
import '../ranking/ranking_screen.dart';
import '../store/store_screen.dart';

// -----------------------------------------------------------------------------
// MainShell: barra superior + 4 secciones + barra inferior
// -----------------------------------------------------------------------------

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
    Navigator.of(context).pushNamed(AppRoutes.notifications);
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final user = app.user;
    final unread = app.unreadNotifications;

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
              icon: Badge(
                isLabelVisible: unread > 0,
                label: Text(unread > 99 ? '99+' : '$unread'),
                child: const Icon(Icons.notifications_none_rounded),
              ),
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