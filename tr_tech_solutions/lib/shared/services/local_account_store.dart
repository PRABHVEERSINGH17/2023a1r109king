import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Device-local accounts so email/password auth works even when Supabase
/// email confirmation / rate limits block cloud signup.
class LocalAccountStore {
  static const _usersKey = 'trtech_local_users_v1';
  static const _sessionKey = 'trtech_local_session_v1';

  static SharedPreferences? _prefs;
  static Map<String, Map<String, String>> _users = {};
  static String? _sessionEmail;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs?.getString(_usersKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          _users = decoded.map(
            (k, v) => MapEntry(
              k.toString().toLowerCase(),
              Map<String, String>.from(
                (v as Map).map((kk, vv) => MapEntry(kk.toString(), vv.toString())),
              ),
            ),
          );
        }
      } catch (_) {
        _users = {};
      }
    }
    _sessionEmail = _prefs?.getString(_sessionKey);
  }

  static bool get hasSession =>
      _sessionEmail != null && _sessionEmail!.trim().isNotEmpty;

  static String? get sessionEmail => _sessionEmail;

  static String? get sessionName {
    final email = _sessionEmail;
    if (email == null) return null;
    return _users[email.toLowerCase()]?['name'];
  }

  static Future<void> _persistUsers() async {
    await _prefs?.setString(_usersKey, jsonEncode(_users));
  }

  static Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final key = email.trim().toLowerCase();
    if (key.isEmpty || !key.contains('@')) {
      throw StateError('Enter a valid email address.');
    }
    if (password.length < 6) {
      throw StateError('Password must be at least 6 characters.');
    }
    if (_users.containsKey(key)) {
      throw StateError('An account with this email already exists. Please sign in.');
    }
    _users[key] = {
      'email': key,
      'password': password,
      'name': fullName.trim().isEmpty ? key.split('@').first : fullName.trim(),
    };
    await _persistUsers();
    await setSession(key);
  }

  static Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final key = email.trim().toLowerCase();
    final user = _users[key];
    if (user == null || user['password'] != password) {
      throw StateError('Invalid email or password.');
    }
    await setSession(key);
  }

  static Future<void> setSession(String email) async {
    _sessionEmail = email.trim().toLowerCase();
    await _prefs?.setString(_sessionKey, _sessionEmail!);
  }

  static Future<void> clearSession() async {
    _sessionEmail = null;
    await _prefs?.remove(_sessionKey);
  }
}
