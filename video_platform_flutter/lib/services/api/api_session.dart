import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/user_model.dart';

class ApiSession {
  ApiSession._(this._preferences);

  static const _tokenKey = 'api_session.token';
  static const _userKey = 'api_session.user';

  static Future<ApiSession> create() async {
    final preferences = await SharedPreferences.getInstance();
    final session = ApiSession._(preferences);
    await session.restore();
    return session;
  }

  final SharedPreferences _preferences;
  String? _token;
  UserModel? _currentUser;

  String? get token => _token;
  UserModel? get currentUser => _currentUser;

  bool get isAuthenticated => _token != null && _currentUser != null;

  Future<void> restore() async {
    _token = _preferences.getString(_tokenKey);
    final rawUser = _preferences.getString(_userKey);
    if (rawUser == null || rawUser.isEmpty) {
      _currentUser = null;
      return;
    }

    try {
      final json = jsonDecode(rawUser) as Map<String, dynamic>;
      _currentUser = UserModel.fromJson(json);
    } catch (_) {
      _currentUser = null;
      _token = null;
      await clear();
    }
  }

  Future<void> setAuthenticated({
    required String token,
    required UserModel user,
  }) async {
    _token = token;
    _currentUser = user;
    await _persist();
  }

  Future<void> updateCurrentUser(UserModel user) async {
    _currentUser = user;
    await _persist();
  }

  Future<void> clear() async {
    _token = null;
    _currentUser = null;
    await _preferences.remove(_tokenKey);
    await _preferences.remove(_userKey);
  }

  Future<void> _persist() async {
    final token = _token;
    final user = _currentUser;
    if (token == null || user == null) {
      await clear();
      return;
    }

    await _preferences.setString(_tokenKey, token);
    await _preferences.setString(_userKey, jsonEncode(user.toStorageJson()));
  }
}
