import 'package:flutter/material.dart';

/// Centralized application color palette and theme tokens.
/// Adapts seamlessly between Light and Dark mode.
class AppPalette {
  static const green = Color(0xFF15B86C);
  static const error = Color(0xFFEF4444);

  final bool isDark;
  final Color background;
  final Color surface;
  final Color card;
  final Color border;
  final Color text;
  final Color subText;
  final Color hint;
  final Color divider;
  final Color inputFill;
  final Color inputBorder;
  final Color icon;
  final Color arrow;
  final Color navBar;
  final Color navBarBorder;
  final Color navInactive;
  final Color doneText;
  final Color checkBorder;
  final Color track;
  final BoxShadow? shadow;

  const AppPalette({
    required this.isDark,
    required this.background,
    required this.surface,
    required this.card,
    required this.border,
    required this.text,
    required this.subText,
    required this.hint,
    required this.divider,
    required this.inputFill,
    required this.inputBorder,
    required this.icon,
    required this.arrow,
    required this.navBar,
    required this.navBarBorder,
    required this.navInactive,
    required this.doneText,
    required this.checkBorder,
    required this.track,
    this.shadow,
  });

  /// Factory constructor to get the current palette from the active BuildContext.
  factory AppPalette.of(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return dark ? _dark : _light;
  }

  static final _light = AppPalette(
    isDark: false,
    background: const Color(0xFFF8F9FA),
    surface: Colors.white,
    card: Colors.white,
    border: const Color(0xFFE5E7EB),
    text: const Color(0xFF1B1B1B),
    subText: const Color(0xFF6E7177),
    hint: const Color(0xFF8E9196),
    divider: const Color(0xFFF0F0F0),
    inputFill: Colors.white,
    inputBorder: const Color(0xFFE3E6EA),
    icon: const Color(0xFF1B1B1B),
    arrow: const Color(0xFF33373B),
    navBar: Colors.white,
    navBarBorder: const Color(0xFFEEEEEE),
    navInactive: const Color(0xFF373A3E),
    doneText: const Color(0xFF9E9E9E),
    checkBorder: const Color(0xFFD1D5DB),
    track: const Color(0xFFE5E7EB),
    shadow: BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  );

  static const _dark = AppPalette(
    isDark: true,
    background: Color(0xFF181818),
    surface: Color(0xFF242424),
    card: Color(0xFF242424),
    border: Color(0xFF2E2E2E),
    text: Colors.white,
    subText: Color(0xFFA0A0A0),
    hint: Color(0xFF6B6B6B),
    divider: Color(0xFF282828),
    inputFill: Color(0xFF262626),
    inputBorder: Color(0xFF383838),
    icon: Colors.white,
    arrow: Color(0xFFA0A0A0),
    navBar: Color(0xFF181818),
    navBarBorder: Color(0xFF282828),
    navInactive: Color(0xFF8E9196),
    doneText: Color(0xFF6E7177),
    checkBorder: Color(0xFF555555),
    track: Color(0xFF2E2E2E),
    shadow: null,
  );

  BoxDecoration cardDecoration(double radius) => BoxDecoration(
    color: card,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: border, width: 1),
    boxShadow: shadow == null ? null : [shadow!],
  );
}
