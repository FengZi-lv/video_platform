import 'package:video_platform_flutter/src/session/session_store.dart';

class FakeSessionStore implements SessionStore {
  FakeSessionStore([this._token]);

  String? _token;

  @override
  Future<void> clear() async {
    _token = null;
  }

  @override
  Future<String?> readAccessToken() async => _token;

  @override
  Future<void> writeAccessToken(String token) async {
    _token = token;
  }
}
