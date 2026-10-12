import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Título de sección con espacio inferior.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(text, style: AppText.heading),
    );
  }
}