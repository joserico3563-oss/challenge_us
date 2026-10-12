import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// AppBar estándar de las pantallas secundarias.
PreferredSizeWidget ccAppBar(String title, {List<Widget>? actions}) {
  return AppBar(
    title: Text(title),
    titleTextStyle: AppText.heading,
    backgroundColor: AppColors.background,
    surfaceTintColor: Colors.transparent,
    scrolledUnderElevation: 0,
    centerTitle: false,
    actions: actions,
  );
}

/// Decoración estándar para campos de texto.
InputDecoration ccInputDecoration({
  required String label,
  required IconData icon,
  Widget? suffix,
}) {
  OutlineInputBorder border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color),
      );

  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, size: 20),
    suffixIcon: suffix,
    filled: true,
    fillColor: AppColors.surfaceAlt,
    border: border(AppColors.border),
    enabledBorder: border(AppColors.border),
    focusedBorder: border(AppColors.yellow),
    errorBorder: border(AppColors.error),
    focusedErrorBorder: border(AppColors.error),
  );
}