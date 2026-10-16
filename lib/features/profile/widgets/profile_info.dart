
import 'package:flutter/material.dart';

class ProfileInfo extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color textColor;
  final Color subTextColor;

  const ProfileInfo({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.textColor,
    required this.subTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: subTextColor, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: subTextColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
