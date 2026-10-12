import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Logo de ChallengeUs dibujado en código (sin assets).
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 30,
    this.showWordmark = true,
    this.vertical = false,
  });

  final double size;
  final bool showWordmark;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final mark = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.yellow,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(Icons.bolt_rounded, color: AppColors.onYellow, size: size * 0.62),
    );

    if (!showWordmark) return mark;

    final wordmark = Text.rich(
      TextSpan(
        style: TextStyle(
          fontSize: vertical ? size * 0.42 : size * 0.72,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
        children: const [
          TextSpan(text: 'Challenge'),
          TextSpan(text: 'Us', style: TextStyle(color: AppColors.yellow)),
        ],
      ),
    );

    if (vertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [mark, SizedBox(height: size * 0.22), wordmark],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [mark, SizedBox(width: size * 0.3), wordmark],
    );
  }
}