import 'package:flutter/material.dart';

import '../models/models.dart';
import '../screens/bonche/bonche_screen.dart';
import '../screens/challenge/challenge_detail_screen.dart';
import '../screens/evidence/evidence_capture_screen.dart';
import '../screens/evidence/reward_screen.dart';
import '../screens/main/main_shell.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/welcome/welcome_screen.dart';
import '../widgets/widgets.dart';
import 'app_routes.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final name = settings.name;
    final args = settings.arguments;

    if (name == AppRoutes.welcome) {
      return _page(settings, const WelcomeScreen());
    }
    if (name == AppRoutes.main) {
      return _page(settings, const MainShell());
    }
    if (name == AppRoutes.profile) {
      return _page(settings, const ProfileScreen());
    }
    if (name == AppRoutes.challengeDetail && args is String) {
      return _page(settings, ChallengeDetailScreen(challengeId: args));
    }
    if (name == AppRoutes.evidenceCapture && args is String) {
      return _page(settings, EvidenceCaptureScreen(challengeId: args));
    }
    if (name == AppRoutes.reward && args is RewardResult) {
      return _page(settings, RewardScreen(result: args));
    }
    return _page(settings, const _RouteErrorScreen());
  }

  static Route<dynamic> _page(RouteSettings settings, Widget child) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => child,
    );
  }
}

class _RouteErrorScreen extends StatelessWidget {
  const _RouteErrorScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ccAppBar('Ups'),
      body: ErrorStateView(
        message: 'No encontramos esta pantalla.',
        retryLabel: 'Volver',
        onRetry: () => Navigator.of(context).maybePop(),
      ),
    );
  }
}