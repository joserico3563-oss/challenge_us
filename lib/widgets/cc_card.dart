import 'package:flutter/material.dart';

import '../theme/theme.dart';
import 'glass_card.dart';

class CCCard extends StatelessWidget {
  const CCCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.highlight = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      opacity: 0.32,
      blur: 10,
      radius: 20,
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: highlight
                ? AppColors.yellow.withValues(alpha: 0.75)
                : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
