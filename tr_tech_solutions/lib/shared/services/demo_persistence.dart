import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Persists Demo Mode session + workspace so clients survive browser/app refresh.
class DemoPersistence {
  static const _modeKey = 'trtech_demo_mode_v1';
  static const _workspaceKey = 'trtech_demo_workspace_v1';

  static SharedPreferences? _prefs;
  static bool _demoMode = false;
  static Map<String, dynamic>? _workspace;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _demoMode = _prefs?.getBool(_modeKey) ?? false;
    final raw = _prefs?.getString(_workspaceKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          _workspace = decoded;
        } else if (decoded is Map) {
          _workspace = Map<String, dynamic>.from(decoded);
        }
      } catch (_) {
        _workspace = null;
      }
    }
  }

  static bool get isDemoMode => _demoMode;

  static Map<String, dynamic>? get workspace => _workspace;

  static Future<void> setDemoMode(bool value) async {
    _demoMode = value;
    await _prefs?.setBool(_modeKey, value);
  }

  static Future<void> saveWorkspace(Map<String, dynamic> snapshot) async {
    _workspace = snapshot;
    await _prefs?.setString(_workspaceKey, jsonEncode(snapshot));
  }

  static Future<void> clearWorkspace() async {
    _workspace = null;
    await _prefs?.remove(_workspaceKey);
  }
}
