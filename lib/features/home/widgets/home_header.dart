import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/theme_provider.dart';
import '../../../providers/user_provider.dart';
import 'home_palette.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';

    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final p = HomePalette.of(context);
    final user = context.watch<UserProvider>();

    final name = user.name.trim();
    final quote = user.quote.trim();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _Avatar(name: name, imagePath: user.imagePath),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name.isEmpty ? _greeting() : '${_greeting()}, $name',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.4,
                  color: p.text,
                ),
              ),

              if (quote.isNotEmpty) ...[
                const SizedBox(height: 5),

                Text(
                  quote,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    fontWeight: FontWeight.w400,
                    color: p.subText,
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(width: 10),

        const _ThemeToggle(),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  final String? imagePath;

  const _Avatar({required this.name, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final path = imagePath?.trim();

    ImageProvider? image;

    if (!kIsWeb && path != null && path.isNotEmpty) {
      image = FileImage(File(path));
    }

    return Container(
      width: 48,
      height: 48,
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: HomePalette.green.withValues(alpha: 0.65),
          width: 1.5,
        ),
      ),
      child: CircleAvatar(
        backgroundColor: HomePalette.green.withValues(alpha: 0.12),
        foregroundImage: image,
        onForegroundImageError: image == null ? null : (_, _) {},
        child: Text(
          name.isEmpty ? '?' : name[0].toUpperCase(),
          style: const TextStyle(
            color: HomePalette.green,
            fontWeight: FontWeight.w700,
            fontSize: 19,
          ),
        ),
      ),
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle();

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final p = HomePalette.of(context);

    return Material(
      color: p.card,
      shape: CircleBorder(
        side: BorderSide(color: p.border ?? p.checkBorder, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          context.read<ThemeProvider>().toggleTheme();
        },
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            size: 21,
            color: HomePalette.green,
          ),
        ),
      ),
    );
  }
}
