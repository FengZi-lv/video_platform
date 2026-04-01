abstract class SessionStore {
  Future<String?> readAccessToken();

  Future<void> writeAccessToken(String token);

  Future<void> clear();
}
