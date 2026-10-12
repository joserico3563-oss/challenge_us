import 'package:flutter/material.dart';

import 'app_state.dart';

/// Expone [AppState] a todo el árbol de widgets (sin paquetes externos).
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({
    super.key,
    required AppState state,
    required super.child,
  }) : super(notifier: state);

  /// Obtiene el estado y reconstruye el widget cuando el estado cambia.
  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'No se encontró AppScope en el árbol de widgets.');
    return scope!.notifier!;
  }

  /// Obtiene el estado sin suscribirse a sus cambios (útil en callbacks).
  static AppState read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'No se encontró AppScope en el árbol de widgets.');
    return scope!.notifier!;
  }
}