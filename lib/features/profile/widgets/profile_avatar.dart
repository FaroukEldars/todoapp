
import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final ImageProvider? image;
  final String displayName;
  final Color green;
  final Color iconColor;
  final Color backgroundColor;
  final bool isDark;
  final VoidCallback onPickImage;

  const ProfileAvatar({
    super.key,
    required this.image,
    required this.displayName,
    required this.green,
    required this.iconColor,
    required this.backgroundColor,
    required this.isDark,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 54,
            backgroundColor: green.withValues(alpha: 0.15),
            foregroundImage: image,
            child: image == null
                ? Text(
              displayName.isNotEmpty
                  ? displayName[0].toUpperCase()
                  : 'U',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: green,
              ),
            )
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: onPickImage,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: backgroundColor,
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF3A3A3C)
                        : const Color(0xFFE5E5EA),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.camera_alt_outlined,
                  size: 18,
                  color: iconColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
