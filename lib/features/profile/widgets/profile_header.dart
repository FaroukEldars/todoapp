
import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String quote;
  final Color textColor;
  final Color subTextColor;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.quote,
    required this.textColor,
    required this.subTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          name,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          quote,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: subTextColor,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
