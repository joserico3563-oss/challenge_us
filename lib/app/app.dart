import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../navigation/app_router.dart';
import '../navigation/app_routes.dart';
import '../services/api_auth_service.dart';
import '../services/api_challenge_service.dart';
import '../services/api_group_service.dart';
import '../services/api_social_services.dart';
import '../services/services.dart';
import '../theme/theme.dart';
import 'app_scope.dart';
import 'app_state.dart';

/// Raíz de la aplicación. Aquí se "conectan" los servicios: para pasar de
/// datos mock a un backend real solo hay que cambiar las implementaciones
/// de este bloque.
class ChallengeUsApp extends StatefulWidget {
  const ChallengeUsApp({super.key});

  @override
  State<ChallengeUsApp> createState() => _ChallengeUsAppState();
}

class _ChallengeUsAppState extends State<ChallengeUsApp> {
  late final AppState _appState = AppState(
    authService: const ApiAuthService(),
    challengeService: const ApiChallengeService(),
    validationService: const MockEvidenceValidationService(),
    permissionService: const SystemPermissionService(),
    groupService: const ApiGroupService(),
    rankingService: const ApiRankingService(),
    chatService: const ApiChatService(),
    storeService: const ApiStoreService(),
  );

  bool _restoring = kIsWeb;
  bool _restoreFailed = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) _restoreSession();
  }

  Future<void> _restoreSession() async {
    setState(() {
      _restoring = true;
      _restoreFailed = false;
    });

    try {
      await _appState.restoreWebSession();
    } catch (_) {
      if (mounted) {
        setState(() => _restoreFailed = true);
      }
    } finally {
      if (mounted) {
        setState(() => _restoring = false);
      }
    }
  }

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_restoring || _restoreFailed) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: Scaffold(
          backgroundColor: const Color(0xFF101D30),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/larecocha/branding/app_icon.png',
                    width: 110,
                    height: 110,
                  ),
                  const SizedBox(height: 28),
                  if (_restoring)
                    const CircularProgressIndicator(color: Color(0xFFFFD60A))
                  else ...[
                    const Text(
                      'No pudimos conectar. Revisa tu internet.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _restoreSession,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }

    return AppScope(
      state: _appState,
      child: MaterialApp(
        title: 'La Recocha',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        initialRoute: _appState.isSignedIn
            ? (_appState.group != null ? AppRoutes.main : AppRoutes.boncheSetup)
            : AppRoutes.welcome,
        onGenerateInitialRoutes: (route) => [
          AppRouter.onGenerateRoute(RouteSettings(name: route)),
        ],
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
