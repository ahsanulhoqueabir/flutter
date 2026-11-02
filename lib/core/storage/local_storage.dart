import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Typed key/value storage for small, non-sensitive values.
///
/// Add a getter/setter pair here for each new key so keys live in one place.
/// For real secrets in production, move the token to flutter_secure_storage.
class LocalStorage {
  LocalStorage(this._prefs);

  final SharedPreferences _prefs;

  static const _kThemeMode = 'theme_mode';
  static const _kAuthToken = 'auth_token';
  static const _kUser = 'user';
  static const _kOnboardingSeen = 'onboarding_seen';

  String? get themeMode => _prefs.getString(_kThemeMode);
  Future<void> setThemeMode(String value) => _prefs.setString(_kThemeMode, value);

  String? get authToken => _prefs.getString(_kAuthToken);
  Future<void> setAuthToken(String? value) =>
      value == null ? _prefs.remove(_kAuthToken) : _prefs.setString(_kAuthToken, value);

  /// Cached signed-in user, so the app opens instantly (and offline) on relaunch.
  Map<String, dynamic>? get user {
    final raw = _prefs.getString(_kUser);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } on FormatException {
      return null; // Corrupt cache: treat as signed out rather than crash.
    }
  }

  Future<void> setUser(Map<String, dynamic>? value) =>
      value == null ? _prefs.remove(_kUser) : _prefs.setString(_kUser, jsonEncode(value));

  bool get onboardingSeen => _prefs.getBool(_kOnboardingSeen) ?? false;
  Future<void> setOnboardingSeen() => _prefs.setBool(_kOnboardingSeen, true);

  /// Removes everything tied to the signed-in user. Keeps device preferences.
  Future<void> clearSession() async {
    await _prefs.remove(_kAuthToken);
    await _prefs.remove(_kUser);
  }
}
