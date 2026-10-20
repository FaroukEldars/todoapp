import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  String _name = '';
  String _email = '';
  int? _userId;
  String _quote = 'Small steps every day make a big difference.';
  String? _imagePath;
  bool _isLoggedIn = false;

  bool _isLoaded = false;

  Future<void> loadUserData() async {
    if (_isLoaded) return;

    final prefs = await SharedPreferences.getInstance();

    _name = prefs.getString('user_name') ?? _name;
    _email = prefs.getString('user_email') ?? _email;
    _userId = prefs.getInt('user_id');
    _quote = prefs.getString('user_quote') ?? _quote;
    _imagePath = prefs.getString('user_image_path');
    _isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('user_name', _name);
    await prefs.setString('user_email', _email);
    await prefs.setString('user_quote', _quote);
    await prefs.setBool('is_logged_in', _isLoggedIn);

    if (_userId != null) {
      await prefs.setInt('user_id', _userId!);
    } else {
      await prefs.remove('user_id');
    }

    if (_imagePath != null) {
      await prefs.setString('user_image_path', _imagePath!);
    } else {
      await prefs.remove('user_image_path');
    }
  }

  String get name => _name;
  String get email => _email;
  int? get userId => _userId;
  String get quote => _quote;
  String? get imagePath => _imagePath;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> setUser({
    required String name,
    required int userId,
    required String email,
    String? quote,
    String? imagePath,
  }) async {
    _name = name;
    _userId = userId;
    _email = email;
    _quote = quote ?? _quote;
    _imagePath = imagePath;
    _isLoggedIn = true;

    await _saveUserData();
    notifyListeners();
  }

  Future<void> updateName(String name) async {
    _name = name;
    await _saveUserData();
    notifyListeners();
  }

  Future<void> updateQuote(String quote) async {
    _quote = quote;
    await _saveUserData();
    notifyListeners();
  }

  Future<void> updateImage(String? imagePath) async {
    _imagePath = imagePath;
    await _saveUserData();
    notifyListeners();
  }

  Future<void> clearUser() async {
    _name = '';
    _email = '';
    _userId = null;
    _quote = 'Small steps every day make a big difference.';
    _imagePath = null;
    _isLoggedIn = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_id');
    await prefs.remove('user_quote');
    await prefs.remove('user_image_path');
    await prefs.remove('is_logged_in');

    notifyListeners();
  }
}
