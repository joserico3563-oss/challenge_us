import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../navigation/app_routes.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import '../../widgets/glass_card.dart';
import '../bonche/bonche_screen.dart';
import '../home/home_screen.dart';
import '../ranking/ranking_screen.dart';
import '../store/store_screen.dart';

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

  Widget _navItem(int index, String label, String asset) {
    final selected = _index == index;

    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => setState(() => _index = index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            margin: const EdgeInsets.all(3),
            padding: const EdgeInsets.symmetric(vertical: 7),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.yellow.withValues(alpha: 0.20)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected
                    ? AppColors.yellow.withValues(alpha: 0.75)
                    : Colors.transparent,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedScale(
                  scale: selected ? 1.08 : 0.95,
                  duration: const Duration(milliseconds: 200),
                  child: Image.asset(
                    'assets/larecocha/navigation/$asset.png',
                    width: 34,
                    height: 34,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: selected ? AppColors.yellow : Colors.white,
                    shadows: const [
                      Shadow(color: Colors.black87, blurRadius: 5),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/larecocha/backgrounds/background.png',
            fit: BoxFit.cover,
          ),

          const ColoredBox(color: Color(0x40000000)),

          Scaffold(
            backgroundColor: Colors.transparent,
            extendBodyBehindAppBar: true,
            extendBody: true,

            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              toolbarHeight: 70,
              titleSpacing: 16,

              flexibleSpace: const GlassCard(
                opacity: 0.32,
                blur: 10,
                radius: 0,
                padding: EdgeInsets.zero,
                child: SizedBox.expand(),
              ),

              title: Row(
                children: [
                  Image.asset(
                    'assets/larecocha/branding/larechocha.png',
                    width: 48,
                    height: 48,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 8),
                  const Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text.rich(
                        TextSpan(
                          style: TextStyle(
                            fontFamily: 'LilitaOne',
                            fontSize: 27,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black87,
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          children: [
                            TextSpan(text: 'La '),
                            TextSpan(
                              text: 'Recocha',
                              style: TextStyle(color: AppColors.yellow),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              actions: [
                IconButton(
                  tooltip: 'Notificaciones',
                  onPressed: _openNotifications,
                  icon: Badge(
                    isLabelVisible: unread > 0,
                    label: Text(unread > 99 ? '99+' : '$unread'),
                    child: Image.asset(
                      'assets/larecocha/navigation/notificaciones.png',
                      width: 30,
                      height: 30,
                      fit: BoxFit.contain,
                    ),
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

            body: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(top: 70, bottom: 96),
                child: IndexedStack(
                  index: _index,
                  children: const [
                    HomeScreen(),
                    BoncheScreen(),
                    RankingScreen(),
                    StoreScreen(),
                  ],
                ),
              ),
            ),

            bottomNavigationBar: SafeArea(
              minimum: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: GlassCard(
                opacity: 0.32,
                blur: 10,
                radius: 26,
                padding: const EdgeInsets.all(5),
                child: Row(
                  children: [
                    _navItem(0, 'Inicio', 'inicio'),
                    _navItem(1, 'Bonche', 'bonche'),
                    _navItem(2, 'Ranking', 'ranking'),
                    _navItem(3, 'Tienda', 'tienda'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
