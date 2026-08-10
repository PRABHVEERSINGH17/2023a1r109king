import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Persists Demo Mode session + workspace so clients survive browser/app refresh.
class DemoPersistence {
  static const _modeKey = 'trtech_demo_mode_v1';
  static const _workspaceKey = 'trtech_demo_workspace_v1';
  static const _preferLiveKey = 'trtech_prefer_live_v1';

  static SharedPreferences? _prefs;
  static bool _demoMode = false;
  static bool _preferLive = false;
  static Map<String, dynamic>? _workspace;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _preferLive = _prefs?.getBool(_preferLiveKey) ?? false;
    // If user chose Go Online, never auto-restore Demo Mode on refresh.
    _demoMode = _preferLive ? false : (_prefs?.getBool(_modeKey) ?? false);
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

  /// True when the user explicitly chose live/online mode.
  static bool get preferLive => _preferLive;

  static Map<String, dynamic>? get workspace => _workspace;

  static Future<void> setDemoMode(bool value) async {
    _demoMode = value;
    await _prefs?.setBool(_modeKey, value);
  }

  static Future<void> setPreferLive(bool value) async {
    _preferLive = value;
    await _prefs?.setBool(_preferLiveKey, value);
    if (value) {
      _demoMode = false;
      await _prefs?.setBool(_modeKey, false);
    }
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
