/// Permisos del sistema que ChallengeUs puede necesitar. Para añadir uno
/// nuevo basta con agregarlo aquí y en [SystemPermissionService].
enum AppPermission {
  camera(
    label: 'cámara',
    rationale:
        'ChallengeUs usa la cámara para que captures la evidencia de tus retos '
        'en el momento. No se usa la galería: cada evidencia se toma aquí mismo.',
  ),
  microphone(
    label: 'micrófono',
    rationale:
        'ChallengeUs usa el micrófono solo dentro de los retos de voz, '
        'para grabar tu doblaje.',
  );

  const AppPermission({required this.label, required this.rationale});

  final String label;
  final String rationale;
}

/// Resultado simplificado y común a cualquier permiso.
enum PermissionOutcome { granted, denied, permanentlyDenied, restricted }