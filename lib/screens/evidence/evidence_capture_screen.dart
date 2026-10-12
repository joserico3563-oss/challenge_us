import 'dart:async' show unawaited;
import 'dart:io' show File;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../models/models.dart';
import '../../navigation/app_routes.dart';
import '../../services/services.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

// -----------------------------------------------------------------------------
// Captura de evidencia (cámara real + permisos reales de Android)
// -----------------------------------------------------------------------------

/// Fases del flujo de captura. Se decide según el estado REAL del permiso.
enum _Phase {
  checking,
  rationale,
  requesting,
  denied,
  blocked,
  restricted,
  startingCamera,
  ready,
  capturing,
  review,
  submitting,
  noCamera,
  error,
}

class EvidenceCaptureScreen extends StatefulWidget {
  const EvidenceCaptureScreen({super.key, required this.challengeId});

  final String challengeId;

  @override
  State<EvidenceCaptureScreen> createState() => _EvidenceCaptureScreenState();
}

class _EvidenceCaptureScreenState extends State<EvidenceCaptureScreen>
    with WidgetsBindingObserver {
  _Phase _phase = _Phase.checking;
  Challenge? _challenge;
  PermissionService? _permissions;
  AppPermission _currentPermission = AppPermission.camera;

  CameraController? _controller;
  CameraLensDirection _lens = CameraLensDirection.back;
  bool _canSwitchCamera = false;

  String? _photoPath;
  String _errorMessage = '';
  bool _errorRetryable = true;

  int _cameraGeneration = 0;
  bool _waitingForSettings = false;
  bool _restartOnResume = false;
  bool _confirmed = false;

  // ------------------------------------------------------------- ciclo de vida

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraGeneration++;
    final controller = _controller;
    _controller = null;
    if (controller != null) unawaited(controller.dispose());
    if (!_confirmed) _discardPhoto();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (_waitingForSettings) {
          _waitingForSettings = false;
          _recheckAfterSettings();
        } else if (_restartOnResume) {
          _restartOnResume = false;
          _checkPermissions();
        }
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _onBackground();
    }
  }

  /// Libera la cámara cuando la app deja de estar en primer plano.
  void _onBackground() {
    final holdsCamera = _controller != null &&
        (_phase == _Phase.ready ||
            _phase == _Phase.capturing ||
            _phase == _Phase.startingCamera);
    if (!holdsCamera) return;
    _restartOnResume = true;
    _cameraGeneration++;
    _setPhase(_Phase.startingCamera);
    unawaited(_disposeController());
  }

  // ------------------------------------------------------------------ arranque

  void _bootstrap() {
    if (!mounted) return;
    final app = AppScope.read(context);
    _permissions = app.permissionService;

    final challenge = app.challengeById(widget.challengeId);
    if (challenge == null) {
      _fail('No encontramos este reto.', retryable: false);
      return;
    }
    if (app.statusOf(challenge) != ChallengeStatus.available) {
      _fail('Este reto ya no está disponible para capturar evidencia.',
          retryable: false);
      return;
    }
    _challenge = challenge;
    _checkPermissions();
  }

  void _setPhase(_Phase phase) {
    if (!mounted) return;
    setState(() => _phase = phase);
  }

  void _fail(String message, {bool retryable = true}) {
    _errorMessage = message;
    _errorRetryable = retryable;
    _setPhase(_Phase.error);
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _close() {
    Navigator.of(context).maybePop();
  }

  // ------------------------------------------------------------------ permisos

  /// Revisa, en orden, los permisos que exige el reto. Si todos están
  /// concedidos abre la cámara; si no, decide la fase según el estado real.
  Future<void> _checkPermissions() async {
    final challenge = _challenge;
    final permissions = _permissions;
    if (challenge == null || permissions == null) return;

    _setPhase(_Phase.checking);
    for (final permission in challenge.requiredPermissions) {
      final outcome = await permissions.check(permission);
      if (!mounted) return;
      if (outcome != PermissionOutcome.granted) {
        _currentPermission = permission;
        _applyOutcome(outcome, afterRequest: false);
        return;
      }
    }
    await _startCamera();
  }

  void _applyOutcome(PermissionOutcome outcome, {required bool afterRequest}) {
    switch (outcome) {
      case PermissionOutcome.granted:
        _checkPermissions();
      case PermissionOutcome.denied:
        _setPhase(afterRequest ? _Phase.denied : _Phase.rationale);
      case PermissionOutcome.permanentlyDenied:
        _setPhase(_Phase.blocked);
      case PermissionOutcome.restricted:
        _setPhase(_Phase.restricted);
    }
  }

  /// Lanza el diálogo REAL de permisos de Android.
  Future<void> _requestPermission() async {
    final permissions = _permissions;
    if (permissions == null) return;
    _setPhase(_Phase.requesting);
    final outcome = await permissions.request(_currentPermission);
    if (!mounted) return;
    _applyOutcome(outcome, afterRequest: true);
  }

  Future<void> _openSettings() async {
    final permissions = _permissions;
    if (permissions == null) return;
    _waitingForSettings = true;
    final opened = await permissions.openSettings();
    if (!opened) {
      _waitingForSettings = false;
      _showMessage('No pudimos abrir Ajustes. Ábrelos manualmente desde tu teléfono.');
    }
  }

  /// Al volver de Ajustes se vuelve a comprobar el permiso. Si sigue sin
  /// concederse se intenta solicitarlo (cubre la opción "Preguntar siempre").
  Future<void> _recheckAfterSettings() async {
    final permissions = _permissions;
    if (permissions == null) return;
    _setPhase(_Phase.checking);
    var outcome = await permissions.check(_currentPermission);
    if (!mounted) return;
    if (outcome != PermissionOutcome.granted) {
      outcome = await permissions.request(_currentPermission);
      if (!mounted) return;
    }
    _applyOutcome(outcome, afterRequest: true);
  }

  // -------------------------------------------------------------------- cámara

  bool _isCurrent(int generation) => mounted && generation == _cameraGeneration;

  Future<void> _disposeController() async {
    final controller = _controller;
    _controller = null;
    if (controller == null) return;
    try {
      await controller.dispose();
    } catch (_) {
      // La cámara ya estaba liberada.
    }
  }

  Future<void> _releaseCamera() async {
    _cameraGeneration++;
    await _disposeController();
  }

  Future<void> _startCamera() async {
    final generation = ++_cameraGeneration;
    _setPhase(_Phase.startingCamera);
    await _disposeController();

    try {
      final cameras = await availableCameras();
      if (!_isCurrent(generation)) return;
      if (cameras.isEmpty) {
        _setPhase(_Phase.noCamera);
        return;
      }

      _canSwitchCamera = cameras.map((c) => c.lensDirection).toSet().length > 1;
      final description = cameras.firstWhere(
        (c) => c.lensDirection == _lens,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        description,
        ResolutionPreset.high,
        enableAudio: false,
      );
      _controller = controller;
      await controller.initialize();

      if (!_isCurrent(generation)) {
        if (identical(_controller, controller)) _controller = null;
        try {
          await controller.dispose();
        } catch (_) {}
        return;
      }
      _setPhase(_Phase.ready);
    } on CameraException catch (e) {
      if (!_isCurrent(generation)) return;
      await _disposeController();
      if (!mounted) return;
      switch (e.code) {
        case 'CameraAccessDenied':
        case 'CameraAccessDeniedWithoutPrompt':
          _currentPermission = AppPermission.camera;
          _setPhase(_Phase.denied);
        case 'CameraAccessRestricted':
          _currentPermission = AppPermission.camera;
          _setPhase(_Phase.restricted);
        default:
          _fail(
            'No pudimos iniciar la cámara. Cierra otras apps que la estén '
            'usando e inténtalo de nuevo.',
          );
      }
    } catch (_) {
      if (!_isCurrent(generation)) return;
      await _disposeController();
      _fail('Ocurrió un problema al abrir la cámara. Inténtalo de nuevo.');
    }
  }

  Future<void> _switchCamera() async {
    _lens = _lens == CameraLensDirection.back
        ? CameraLensDirection.front
        : CameraLensDirection.back;
    await _startCamera();
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (_phase != _Phase.ready ||
        controller == null ||
        !controller.value.isInitialized ||
        controller.value.isTakingPicture) {
      return;
    }
    _setPhase(_Phase.capturing);
    try {
      final file = await controller.takePicture();
      if (!mounted) return;
      if (_phase != _Phase.capturing) {
        // La app pasó a segundo plano durante la captura: se descarta.
        unawaited(_deleteQuietly(file.path));
        return;
      }
      _photoPath = file.path;
      await _releaseCamera();
      _setPhase(_Phase.review);
    } on CameraException catch (_) {
      if (!mounted || _phase != _Phase.capturing) return;
      await _releaseCamera();
      _fail('No pudimos tomar la foto. Inténtalo de nuevo.');
    }
  }

  // ------------------------------------------------------ revisión / confirmar

  void _retake() {
    _discardPhoto();
    _checkPermissions();
  }

  Future<void> _confirm() async {
    final challenge = _challenge;
    final path = _photoPath;
    if (challenge == null || path == null || _phase != _Phase.review) return;

    final app = AppScope.read(context);
    _setPhase(_Phase.submitting);
    try {
      // Comprueba que la foto realmente exista antes de enviarla.
      final exists = await File(path).exists();
      if (!mounted) return;
      if (!exists) {
        _showMessage('No encontramos la foto. Toma otra, por favor.');
        _retake();
        return;
      }

      final evidence = Evidence(
        id: 'ev-${DateTime.now().microsecondsSinceEpoch}',
        challengeId: challenge.id,
        filePath: path,
        type: challenge.evidenceType,
        capturedAt: DateTime.now(),
      );
      final result = await app.completeChallenge(challenge, evidence);
      if (!mounted) return;
      if (result.approved) {
        _confirmed = true;
        Navigator.of(context).pushReplacementNamed(
          AppRoutes.reward,
          arguments: result,
        );
      } else {
        _setPhase(_Phase.review);
        _showMessage(result.message);
      }
    } catch (error, stackTrace) {
      debugPrint('Error al confirmar la evidencia: $error\n$stackTrace');
      if (!mounted) return;
      _setPhase(_Phase.review);
      _showMessage('No pudimos validar tu evidencia. Inténtalo de nuevo.');
    }
  }

  void _discardPhoto() {
    final path = _photoPath;
    _photoPath = null;
    if (path != null) unawaited(_deleteQuietly(path));
  }

  Future<void> _deleteQuietly(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (_) {
      // Archivo temporal: si no se puede borrar, no pasa nada.
    }
  }

  // ------------------------------------------------------------------ interfaz

  IconData get _permissionIcon => _currentPermission == AppPermission.camera
      ? Icons.camera_alt_rounded
      : Icons.mic_rounded;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _phase != _Phase.submitting,
      child: Scaffold(
        appBar: ccAppBar('Capturar evidencia'),
        body: SafeArea(child: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    final label = _currentPermission.label;
    switch (_phase) {
      case _Phase.checking:
        return const LoadingView(label: 'Comprobando permisos...');
      case _Phase.requesting:
        return const LoadingView(label: 'Esperando tu respuesta...');
      case _Phase.startingCamera:
        return const LoadingView(label: 'Abriendo cámara...');
      case _Phase.rationale:
        return _StatusPanel(
          icon: _permissionIcon,
          title: 'Permiso de $label',
          message: _currentPermission.rationale,
          primaryLabel: 'Continuar',
          onPrimary: _requestPermission,
          secondaryLabel: 'Ahora no',
          onSecondary: _close,
        );
      case _Phase.denied:
        return _StatusPanel(
          icon: Icons.no_photography_rounded,
          iconColor: AppColors.orange,
          title: 'Permiso rechazado',
          message: 'Rechazaste el permiso de $label. Sin él no podemos capturar '
              'la evidencia de este reto. Puedes intentarlo de nuevo cuando quieras.',
          primaryLabel: 'Intentar de nuevo',
          onPrimary: _requestPermission,
          secondaryLabel: 'Volver',
          onSecondary: _close,
        );
      case _Phase.blocked:
        return _StatusPanel(
          icon: Icons.lock_rounded,
          iconColor: AppColors.error,
          title: 'Permiso bloqueado',
          message: 'Android ya no mostrará la solicitud del permiso de $label. '
              'Ábrelo en Ajustes > Permisos y actívalo; al volver continuamos '
              'automáticamente.',
          primaryLabel: 'Abrir ajustes',
          onPrimary: _openSettings,
          secondaryLabel: 'Volver',
          onSecondary: _close,
        );
      case _Phase.restricted:
        return _StatusPanel(
          icon: Icons.lock_rounded,
          iconColor: AppColors.error,
          title: 'Acceso restringido',
          message: 'El permiso de $label está restringido en este dispositivo '
              'y no podemos solicitarlo.',
          primaryLabel: 'Volver',
          onPrimary: _close,
        );
      case _Phase.noCamera:
        return _StatusPanel(
          icon: Icons.no_photography_rounded,
          iconColor: AppColors.orange,
          title: 'No encontramos cámara',
          message: 'No hay una cámara disponible en este dispositivo.',
          primaryLabel: 'Reintentar',
          onPrimary: _checkPermissions,
          secondaryLabel: 'Volver',
          onSecondary: _close,
        );
      case _Phase.error:
        return _StatusPanel(
          icon: Icons.error_outline_rounded,
          iconColor: AppColors.error,
          title: 'Algo no salió bien',
          message: _errorMessage,
          primaryLabel: _errorRetryable ? 'Reintentar' : 'Volver',
          onPrimary: _errorRetryable ? _checkPermissions : _close,
          secondaryLabel: _errorRetryable ? 'Volver' : null,
          onSecondary: _errorRetryable ? _close : null,
        );
      case _Phase.ready:
      case _Phase.capturing:
        return _buildCamera();
      case _Phase.review:
      case _Phase.submitting:
        return _buildReview();
    }
  }

  Widget _buildCamera() {
    final challenge = _challenge;
    final controller = _controller;
    if (challenge == null) return const LoadingView();

    final cameraReady = controller != null && controller.value.isInitialized;
    final capturing = _phase == _Phase.capturing;

    return Column(
      children: [
        _ChallengeHint(text: challenge.objective),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: ColoredBox(
                color: Colors.black,
                child: Center(
                  child: cameraReady
                      ? CameraPreview(controller)
                      : const CircularProgressIndicator(),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 56,
                child: _canSwitchCamera
                    ? IconButton(
                        tooltip: 'Cambiar cámara',
                        onPressed: capturing ? null : _switchCamera,
                        iconSize: 28,
                        icon: const Icon(Icons.cameraswitch_rounded),
                      )
                    : null,
              ),
              Semantics(
                button: true,
                label: 'Tomar foto',
                child: GestureDetector(
                  onTap: capturing ? null : _capture,
                  child: Container(
                    width: 76,
                    height: 76,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: capturing
                            ? AppColors.textSecondary
                            : AppColors.yellow,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 56),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReview() {
    final path = _photoPath;
    final submitting = _phase == _Phase.submitting;

    return Column(
      children: [
        const _ChallengeHint(text: 'Revisa tu evidencia: ¿se ve claro el reto?'),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: ColoredBox(
                color: Colors.black,
                child: path == null
                    ? const SizedBox.shrink()
                    : Image.file(
                        File(path),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) => const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: AppColors.textSecondary,
                            size: 48,
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            children: [
              PrimaryButton(
                label: 'Confirmar evidencia',
                icon: Icons.check_circle_rounded,
                loading: submitting,
                onPressed: _confirm,
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                label: 'Repetir',
                icon: Icons.refresh_rounded,
                onPressed: submitting ? null : _retake,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChallengeHint extends StatelessWidget {
  const _ChallengeHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: CCCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Icon(Icons.flag_rounded, color: AppColors.yellow, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: AppText.body,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Panel genérico para los estados de permiso y error.
class _StatusPanel extends StatelessWidget {
  const _StatusPanel({
    required this.icon,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.iconColor = AppColors.yellow,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 38, color: iconColor),
              ),
              const SizedBox(height: 22),
              Text(title, textAlign: TextAlign.center, style: AppText.title),
              const SizedBox(height: 10),
              Text(message, textAlign: TextAlign.center, style: AppText.bodyMuted),
              const SizedBox(height: 28),
              PrimaryButton(label: primaryLabel, onPressed: onPrimary),
              if (secondaryLabel != null && onSecondary != null) ...[
                const SizedBox(height: 12),
                SecondaryButton(label: secondaryLabel!, onPressed: onSecondary),
              ],
            ],
          ),
        ),
      ),
    );
  }
}