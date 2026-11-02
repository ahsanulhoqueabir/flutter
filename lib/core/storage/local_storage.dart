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

  String? get themeMode => _prefs.getString(_kThemeMode);
  Future<void> setThemeMode(String value) => _prefs.setString(_kThemeMode, value);

  String? get authToken => _prefs.getString(_kAuthToken);
  Future<void> setAuthToken(String? value) =>
      value == null ? _prefs.remove(_kAuthToken) : _prefs.setString(_kAuthToken, value);
}
