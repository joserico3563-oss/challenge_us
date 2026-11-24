import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Estilos de texto reutilizables.
class AppText {
  AppText._();

  static const TextStyle display = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    height: 1.15,
    color: AppColors.textPrimary,
    shadows: [
      Shadow(color: Color(0xCC000000), blurRadius: 4, offset: Offset(0, 1)),
    ],
  );
  static const TextStyle title = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    shadows: [
      Shadow(color: Color(0xCC000000), blurRadius: 4, offset: Offset(0, 1)),
    ],
  );
  static const TextStyle heading = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    shadows: [
      Shadow(color: Color(0xCC000000), blurRadius: 4, offset: Offset(0, 1)),
    ],
  );
  static const TextStyle body = TextStyle(
    fontSize: 15,
    height: 1.45,
    color: AppColors.textPrimary,
    shadows: [
      Shadow(color: Color(0xCC000000), blurRadius: 4, offset: Offset(0, 1)),
    ],
  );
  static const TextStyle bodyMuted = TextStyle(
    fontSize: 14,
    height: 1.45,
    color: AppColors.textSecondary,
    shadows: [
      Shadow(color: Color(0xCC000000), blurRadius: 4, offset: Offset(0, 1)),
    ],
  );
  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
    color: AppColors.textSecondary,
    shadows: [
      Shadow(color: Color(0xCC000000), blurRadius: 4, offset: Offset(0, 1)),
    ],
  );
}
