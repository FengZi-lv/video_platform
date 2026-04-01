import 'package:shared_preferences/shared_preferences.dart';

import 'session_store.dart';

class SharedPreferencesSessionStore implements SessionStore {
  static const _tokenKey = 'access_token';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  @override
  Future<void> clear() async {
    final prefs = await _prefs;
    await prefs.remove(_tokenKey);
  }

  @override
  Future<String?> readAccessToken() async {
    final prefs = await _prefs;
    return prefs.getString(_tokenKey);
  }

  @override
  Future<void> writeAccessToken(String token) async {
    final prefs = await _prefs;
    await prefs.setString(_tokenKey, token);
  }
}
