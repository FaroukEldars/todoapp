import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _boxName = 'app_settings';
  static const String _themeKey = 'isDarkMode';

  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode {
    return _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final box = Hive.isBoxOpen(_boxName)
          ? Hive.box(_boxName)
          : await Hive.openBox(_boxName);
      final saved = box.get(_themeKey) as bool?;
      if (saved != null && saved != _isDarkMode) {
        _isDarkMode = saved;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();

    try {
      final box = Hive.isBoxOpen(_boxName)
          ? Hive.box(_boxName)
          : await Hive.openBox(_boxName);
      await box.put(_themeKey, _isDarkMode);
    } catch (_) {}
  }
}
