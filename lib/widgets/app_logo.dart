import 'package:flutter/material.dart';

import '../theme/theme.dart';

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
    final mark = Image.asset(
      'assets/larecocha/branding/larechocha.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );

    if (!showWordmark) return mark;

    final wordmark = Text.rich(
      TextSpan(
        style: TextStyle(
          fontFamily: 'LilitaOne',
          fontSize: vertical ? size * 0.42 : size * 0.72,
          color: AppColors.textPrimary,
          shadows: const [
            Shadow(color: Colors.black87, blurRadius: 5, offset: Offset(0, 2)),
          ],
        ),
        children: const [
          TextSpan(text: 'La '),
          TextSpan(
            text: 'Recocha',
            style: TextStyle(color: AppColors.yellow),
          ),
        ],
      ),
    );

    if (vertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          mark,
          SizedBox(height: size * 0.22),
          wordmark,
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        SizedBox(width: size * 0.3),
        wordmark,
      ],
    );
  }
}
