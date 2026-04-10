import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../services/i_auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService)
    : _currentUser = _authService.cachedCurrentUser {
    _authService.authStream.listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  final IAuthService _authService;
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  bool get isGuest => _currentUser == null;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.status == 'admin';
  bool get isBanned => _currentUser?.status == 'ban';
  String get token => _authService.currentToken ?? 'guest';

  Future<void> login(String account, String password) async {
    _currentUser = await _authService.login(account, password);
    notifyListeners();
  }

  Future<void> register(
    String account,
    String password,
    String nickname,
    String bio,
  ) async {
    _currentUser = await _authService.register(
      account,
      password,
      nickname,
      bio,
    );
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> deleteAccount(String password) async {
    if (_currentUser == null) return;
    await _authService.deleteAccount(_currentUser!.id, password);
    _currentUser = null;
    notifyListeners();
  }

  Future<void> restoreSession() async {
    _currentUser = await _authService.restoreSession();
    notifyListeners();
  }

  Future<void> reloadCurrentUser() async {
    _currentUser = await _authService.getCurrentUser();
    notifyListeners();
  }

  Future<UserModel?> getUserById(int id) async {
    if (_currentUser?.id == id) {
      return _currentUser;
    }
    return null;
  }
}
