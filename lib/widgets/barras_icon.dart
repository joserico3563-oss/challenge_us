import 'package:flutter/material.dart';

class BarrasIcon extends StatelessWidget {
  const BarrasIcon({super.key, this.size = 24});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/larecocha/branding/barras.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
