import 'barras_icon.dart';

import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Etiqueta pequeña con color (categoría, dificultad, estado...).
class InfoPill extends StatelessWidget {
  const InfoPill({
    super.key,
    required this.label,
    this.icon,
    this.color = AppColors.textSecondary,
  });

  final String label;
  final IconData? icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF101D30).withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            (icon == Icons.monetization_on_rounded
                ? const BarrasIcon(size: 14)
                : Icon(icon, size: 14, color: color)),
            const SizedBox(width: 4),
          ],
          Text(label, style: AppText.label.copyWith(color: color)),
        ],
      ),
    );
  }
}
