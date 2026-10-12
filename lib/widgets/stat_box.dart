import 'package:flutter/material.dart';

import '../theme/theme.dart';
import 'cc_card.dart';

/// Caja de estadística (icono, valor y etiqueta).
class StatBox extends StatelessWidget {
  const StatBox({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.color = AppColors.yellow,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CCCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: AppText.title),
          const SizedBox(height: 2),
          Text(label, style: AppText.label, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}