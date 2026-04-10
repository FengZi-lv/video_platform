import 'dart:async';

import '../models/user_model.dart';
import 'api/api_client.dart';
import 'api/api_session.dart';
import 'api/jwt_payload.dart';
import 'i_auth_service.dart';

class RealAuthService implements IAuthService {
  RealAuthService(this._client, this._session);

  final ApiClient _client;
  final ApiSession _session;
  final StreamController<UserModel?> _authController =
      StreamController<UserModel?>.broadcast();

  @override
  Stream<UserModel?> get authStream => _authController.stream;

  @override
  UserModel? get cachedCurrentUser => _session.currentUser;

  @override
  String? get currentToken => _session.token;

  @override
  Future<UserModel> login(String account, String password) async {
    final json = await _client.postJson(
      '/api/auth/login',
      body: {'username': account, 'password': password},
    );

    final token = json['token'] as String;
    final payload = JwtPayload.fromToken(token);
    var user = UserModel(
      id: payload.userId,
      account: account,
      password: '',
      nickname: payload.nickname.isNotEmpty ? payload.nickname : account,
      status: payload.role,
      bio: '',
      coins: 0,
    );
    await _session.setAuthenticated(token: token, user: user);

    try {
      final profile = await _client.getJson('/api/users/${payload.userId}');
      user = UserModel.fromApiJson(
        profile,
        accountFallback: account,
        roleFallback: payload.role,
      );
      await _session.updateCurrentUser(user);
    } catch (_) {
      // Keep the provisional user created from the JWT payload.
    }

    _authController.add(user);
    return user;
  }

  @override
  Future<UserModel> register(
    String account,
    String password,
    String nickname,
    String bio,
  ) async {
    await _client.postJson(
      '/api/auth/register',
      body: {
        'username': account,
        'password': password,
        'nickname': nickname,
        'bio': bio,
      },
    );
    final user = await login(account, password);
    final enriched = UserModel(
      id: user.id,
      account: user.account,
      password: '',
      nickname: nickname,
      status: user.status,
      bio: bio,
      coins: user.coins,
    );
    await _session.updateCurrentUser(enriched);
    _authController.add(enriched);
    return enriched;
  }

  @override
  Future<void> logout() async {
    await _session.clear();
    _authController.add(null);
  }

  @override
  Future<void> deleteAccount(int userId, String password) async {
    await _client.postJson(
      '/api/auth/delete-account',
      body: {'password': password},
    );
    await logout();
  }

  @override
  Future<UserModel?> getCurrentUser() async => _session.currentUser;

  @override
  Future<UserModel?> restoreSession() async {
    final user = _session.currentUser;
    _authController.add(user);
    return user;
  }

  void dispose() {
    _authController.close();
  }
}
