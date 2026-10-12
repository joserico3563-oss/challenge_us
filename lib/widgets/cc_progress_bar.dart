import 'package:flutter/material.dart';

import '../theme/theme.dart';

class CCProgressBar extends StatelessWidget {
  const CCProgressBar({
    super.key,
    required this.value,
    this.color = AppColors.yellow,
    this.height = 8,
  });

  final double value;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final safeValue = value < 0 ? 0.0 : (value > 1 ? 1.0 : value);
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: safeValue,
        minHeight: height,
        backgroundColor: AppColors.surfaceAlt,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}