import '../models/user_model.dart';
import '../models/video_model.dart';
import 'api/api_client.dart';
import 'api/api_session.dart';
import 'api/api_exception.dart';
import 'i_user_service.dart';

class RealUserService implements IUserService {
  RealUserService(this._client, this._session);

  final ApiClient _client;
  final ApiSession _session;

  @override
  Future<UserModel> updateProfile(
    int userId, {
    String? nickname,
    String? bio,
  }) async {
    await _client.postJson(
      '/api/users/profile',
      body: {
        if (nickname != null) 'nickname': nickname,
        if (bio != null) 'bio': bio,
      },
    );

    final current = _session.currentUser;
    final updated = UserModel(
      id: userId,
      account: current?.account ?? '',
      password: '',
      nickname: nickname ?? current?.nickname ?? '',
      status: current?.status ?? 'active',
      bio: bio ?? current?.bio ?? '',
      coins: current?.coins ?? 0,
    );
    await _session.updateCurrentUser(updated);
    return updated;
  }

  @override
  Future<void> changePassword(
    int userId,
    String oldPassword,
    String newPassword,
  ) async {
    await _client.postJson(
      '/api/auth/change-password',
      body: {'oldPassword': oldPassword, 'newPassword': newPassword},
    );
  }

  @override
  Future<List<VideoModel>> getHistory(int userId) async {
    final json = await _client.getJson('/api/videos/history');
    return _parseVideoList(
      json['videos'] as List<dynamic>? ?? const <dynamic>[],
      fallbackStatus: 'pass',
    );
  }

  @override
  Future<void> recordHistory(int userId, int videoId) async {
    // Video detail endpoint records history on the server automatically.
  }

  @override
  Future<List<VideoModel>> getFavorites(int userId) async {
    final json = await _client.getJson('/api/videos/favorites');
    return _parseVideoList(
      json['videos'] as List<dynamic>? ?? const <dynamic>[],
      fallbackStatus: 'pass',
    );
  }

  @override
  Future<void> addToFavorites(int userId, int videoId) async {
    await _client.postJson('/api/videos/favorite', body: {'video_id': videoId});
  }

  @override
  Future<void> removeFromFavorites(int userId, int videoId) async {
    await _client.postJson(
      '/api/videos/unfavorite',
      body: {'video_id': videoId},
    );
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    final json = await _client.getJson('/api/admin/users');
    final users = json['users'] as List<dynamic>? ?? const <dynamic>[];
    return users
        .map((item) => _parseAdminUser((item as Map).cast<String, dynamic>()))
        .toList();
  }

  @override
  Future<void> banUser(int userId) async {
    await _client.postJson('/api/admin/users/ban', body: {'user_id': userId});
  }

  @override
  Future<void> unbanUser(int userId) async {
    throw ApiException('后端暂未提供解封接口，当前只能查看已封禁状态');
  }

  @override
  Future<UserModel> getUserById(int userId) async {
    final json = await _client.getJson('/api/users/$userId');
    final user = UserModel.fromApiJson(
      json,
      accountFallback: _session.currentUser?.account ?? '',
      roleFallback: _session.currentUser?.status ?? 'active',
    );
    if (_session.currentUser?.id == user.id) {
      await _session.updateCurrentUser(user);
    }
    return user;
  }

  @override
  Future<List<int>> getMyLikedVideos(int userId) async {
    return const <int>[];
  }

  @override
  Future<void> unlikeVideo(int userId, int videoId) async {
    await _client.postJson('/api/videos/unlike', body: {'video_id': videoId});
  }

  @override
  Future<void> likeVideo(int userId, int videoId) async {
    await _client.postJson('/api/videos/like', body: {'video_id': videoId});
  }

  List<VideoModel> _parseVideoList(
    List<dynamic> items, {
    required String fallbackStatus,
  }) {
    return items.map((item) {
      final json = (item as Map).cast<String, dynamic>();
      return VideoModel.fromListJson(json, fallbackStatus: fallbackStatus);
    }).toList();
  }

  UserModel _parseAdminUser(Map<String, dynamic> json) {
    return UserModel.fromApiJson(json, roleFallback: 'active');
  }
}
