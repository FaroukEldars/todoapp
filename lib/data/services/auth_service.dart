import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'https://tododepiapi.runasp.net/api';

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fullName': fullName,
        'email': email,
        'password': password,
      }),
    );

    final data = _decodeResponse(response);

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Registration failed.');
    }

    return data;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = _decodeResponse(response);

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Login failed.');
    }

    final token = data['token'];

    if (token is! String || token.isEmpty) {
      throw Exception('The API did not return a valid token.');
    }

    await _storage.write(key: 'auth_token', value: token);

    final user = data['user'];
    if (user is Map<String, dynamic>) {
      if (user['id'] != null) {
        await _storage.write(key: 'user_id', value: user['id'].toString());
      }
      if (user['fullName'] != null) {
        await _storage.write(
          key: 'user_name',
          value: user['fullName'].toString(),
        );
      }
      if (user['email'] != null) {
        await _storage.write(
          key: 'user_email',
          value: user['email'].toString(),
        );
      }
    }

    return data;
  }

  Future<String?> getToken() async {
    return _storage.read(key: 'auth_token');
  }

  Future<Map<String, String>?> getSavedUser() async {
    final token = await getToken();
    if (token == null || token.isEmpty) return null;

    // Check if token is expired
    if (isTokenExpired(token)) {
      debugPrint('AuthService: Saved token is expired. Logging out.');
      await logout();
      return null;
    }

    final id = await _storage.read(key: 'user_id');
    final name = await _storage.read(key: 'user_name');
    final email = await _storage.read(key: 'user_email');

    if (id == null || id.isEmpty) return null;

    return {'token': token, 'id': id, 'name': name ?? '', 'email': email ?? ''};
  }

  /// Checks if a JWT token has expired based on its 'exp' claim.
  bool isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return true;
      }

      final payload = parts[1].replaceAll('-', '+').replaceAll('_', '/');
      final normalized = base64.normalize(payload);
      final decodedString = utf8.decode(base64.decode(normalized));
      final payloadMap = jsonDecode(decodedString);

      if (payloadMap is! Map<String, dynamic>) {
        return true;
      }

      final exp = payloadMap['exp'];
      if (exp == null) {
        return false;
      }

      final expirySeconds = exp is int ? exp : int.tryParse(exp.toString());
      if (expirySeconds == null) {
        return true;
      }

      final expiryDate = DateTime.fromMillisecondsSinceEpoch(
        expirySeconds * 1000,
        isUtc: true,
      );

      return DateTime.now().toUtc().isAfter(expiryDate);
    } catch (e) {
      debugPrint('AuthService: Error parsing token expiry: $e');
      return true;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'user_id');
    await _storage.delete(key: 'user_name');
    await _storage.delete(key: 'user_email');
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    debugPrint('========== API DEBUG ==========');
    debugPrint('URL: ${response.request?.url}');
    debugPrint('Status: ${response.statusCode}');
    debugPrint('Content-Type: ${response.headers['content-type']}');
    debugPrint('Response: ${response.body}');
    debugPrint('===============================');

    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      throw Exception('Expected JSON object, received ${decoded.runtimeType}');
    } on FormatException {
      throw Exception(
        'Server returned non-JSON response. '
        'HTTP ${response.statusCode}: ${response.body}',
      );
    }
  }
}
