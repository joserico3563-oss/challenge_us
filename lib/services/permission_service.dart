import 'package:permission_handler/permission_handler.dart';

import '../models/models.dart';

/// Acceso a permisos del sistema, independiente del plugin concreto.
abstract class PermissionService {
  /// Estado actual sin mostrar ningún diálogo.
  Future<PermissionOutcome> check(AppPermission permission);

  /// Muestra el diálogo REAL de Android (si el sistema aún lo permite).
  Future<PermissionOutcome> request(AppPermission permission);

  /// Abre los ajustes de la app en el sistema.
  Future<bool> openSettings();
}

class SystemPermissionService implements PermissionService {
  const SystemPermissionService();

  Permission _toPlugin(AppPermission permission) {
    switch (permission) {
      case AppPermission.camera:
        return Permission.camera;
      case AppPermission.microphone:
        return Permission.microphone;
    }
  }

  PermissionOutcome _toOutcome(PermissionStatus status) {
    if (status.isGranted || status.isLimited) return PermissionOutcome.granted;
    if (status.isPermanentlyDenied) return PermissionOutcome.permanentlyDenied;
    if (status.isRestricted) return PermissionOutcome.restricted;
    return PermissionOutcome.denied;
  }

  @override
  Future<PermissionOutcome> check(AppPermission permission) async {
    final status = await _toPlugin(permission).status;
    return _toOutcome(status);
  }

  @override
  Future<PermissionOutcome> request(AppPermission permission) async {
    final status = await _toPlugin(permission).request();
    return _toOutcome(status);
  }

  @override
  Future<bool> openSettings() => openAppSettings();
}