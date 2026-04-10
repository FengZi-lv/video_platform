import '../models/user_model.dart';
import '../models/video_model.dart';

abstract class IUserService {
  Future<UserModel> updateProfile(int userId, {String? nickname, String? bio});
  Future<void> changePassword(
    int userId,
    String oldPassword,
    String newPassword,
  );
  Future<List<VideoModel>> getHistory(int userId);
  Future<void> recordHistory(int userId, int videoId);
  Future<List<VideoModel>> getFavorites(int userId);
  Future<void> addToFavorites(int userId, int videoId);
  Future<void> removeFromFavorites(int userId, int videoId);
  Future<List<UserModel>> getAllUsers();
  Future<void> banUser(int userId);
  Future<void> unbanUser(int userId);
  Future<UserModel> getUserById(int userId);
  Future<List<int>> getMyLikedVideos(int userId);
  Future<void> unlikeVideo(int userId, int videoId);
  Future<void> likeVideo(int userId, int videoId);
}
