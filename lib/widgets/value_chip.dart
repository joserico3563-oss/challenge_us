import 'barras_icon.dart';

import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Chip con icono y valor (monedas, racha, nivel).
class ValueChip extends StatelessWidget {
  const ValueChip({
    super.key,
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          (icon == Icons.monetization_on_rounded
              ? const BarrasIcon(size: 18)
              : Icon(icon, size: 18, color: color)),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppText.body.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
