import '../models/user_model.dart';

abstract class IAuthService {
  Future<UserModel> login(String account, String password);
  Future<UserModel> register(
    String account,
    String password,
    String nickname,
    String bio,
  );
  Future<void> logout();
  Future<void> deleteAccount(int userId, String password);
  Future<UserModel?> getCurrentUser();
  Future<UserModel?> restoreSession();
  Stream<UserModel?> get authStream;
  UserModel? get cachedCurrentUser;
  String? get currentToken;
}
