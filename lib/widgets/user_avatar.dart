import 'package:flutter/material.dart';

import '../theme/theme.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.initials, this.radius = 18});

  final String initials;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.yellow,
      child: Text(
        initials,
        style: TextStyle(
          color: AppColors.onYellow,
          fontWeight: FontWeight.w800,
          fontSize: radius * 0.8,
        ),
      ),
    );
  }
}