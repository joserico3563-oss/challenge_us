import 'package:flutter/material.dart';

import '../navigation/app_router.dart';
import '../navigation/app_routes.dart';
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
    authService: const MockAuthService(),
    challengeService: const MockChallengeService(),
    validationService: const MockEvidenceValidationService(),
    permissionService: const SystemPermissionService(),
    groupService: const MockGroupService(),
    rankingService: const MockRankingService(),
    chatService: const MockChatService(),
    storeService: const MockStoreService(),
  );

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: _appState,
      child: MaterialApp(
        title: 'ChallengeUs',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        initialRoute: AppRoutes.welcome,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}