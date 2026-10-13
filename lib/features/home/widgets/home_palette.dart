import 'package:flutter/material.dart';

class HomePalette {
  static const green = Color(0xFF15B86C);

  final Color background;
  final Color card;
  final Color? border;
  final Color text;
  final Color subText;
  final Color doneText;
  final Color checkBorder;
  final Color track;
  final BoxShadow? shadow;

  const HomePalette({
    required this.background,
    required this.card,
    required this.border,
    required this.text,
    required this.subText,
    required this.doneText,
    required this.checkBorder,
    required this.track,
    this.shadow,
  });

  factory HomePalette.of(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return dark ? _dark : _light;
  }

  static final _light = HomePalette(
    background: const Color(0xFFF8F9FA),
    card: Colors.white,
    border: const Color(0xFFE5E7EB),
    text: const Color(0xFF1B1B1B),
    subText: const Color(0xFF6E7177),
    doneText: const Color(0xFF9E9E9E),
    checkBorder: const Color(0xFFD1D5DB),
    track: const Color(0xFFE5E7EB),
    shadow: BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  );

  static const _dark = HomePalette(
    background: Color(0xFF181818),
    card: Color(0xFF242424),
    border: Color(0xFF2E2E2E),
    text: Colors.white,
    subText: Color(0xFF9E9E9E),
    doneText: Color(0xFF6E7177),
    checkBorder: Color(0xFF555555),
    track: Color(0xFF2E2E2E),
    shadow: null,
  );

  BoxDecoration cardDecoration(double radius) => BoxDecoration(
    color: card,
    borderRadius: BorderRadius.circular(radius),
    border: border == null ? null : Border.all(color: border!, width: 1),
    boxShadow: shadow == null ? null : [shadow!],
  );
}
