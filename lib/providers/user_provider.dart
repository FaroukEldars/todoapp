import 'package:flutter/foundation.dart';

class UserProvider extends ChangeNotifier {
  String _name = '';
  String _email = '';
  int? _userId;
  String _quote = 'Small steps every day make a big difference.';
  String? _imagePath;
  bool _isLoggedIn = false;

  String get name => _name;
  String get email => _email;
  int? get userId => _userId;
  String get quote => _quote;
  String? get imagePath => _imagePath;
  bool get isLoggedIn => _isLoggedIn;

  void setUser({
    required String name,
    required int userId,
    required String email,
    String? quote,
    String? imagePath,
  }) {
    _name = name;
    _userId = userId;
    _email = email;
    _quote = quote ?? _quote;
    _imagePath = imagePath;
    _isLoggedIn = true;

    notifyListeners();
  }

  void updateName(String name) {
    _name = name;
    notifyListeners();
  }

  void updateQuote(String quote) {
    _quote = quote;
    notifyListeners();
  }

  void updateImage(String? imagePath) {
    _imagePath = imagePath;
    notifyListeners();
  }

  void clearUser() {
    _name = '';
    _email = '';
    _userId = null;
    _quote = 'Small steps every day make a big difference.';
    _imagePath = null;
    _isLoggedIn = false;

    notifyListeners();
  }
}
