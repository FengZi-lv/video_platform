import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../models/video_model.dart';
import '../services/i_user_service.dart';

class UserProvider extends ChangeNotifier {
  UserProvider(this._userService);

  final IUserService _userService;
  UserModel? _profile;
  List<VideoModel> _history = [];
  List<VideoModel> _favoriteVideos = [];
  List<int> _likedVideoIds = [];

  UserModel? get profile => _profile;
  List<VideoModel> get history => _history;
  List<VideoModel> get favoriteVideos => _favoriteVideos;
  List<int> get favoriteIds =>
      _favoriteVideos.map((video) => video.id).toList();
  List<int> get likedVideoIds => _likedVideoIds;

  Future<void> loadProfile(int userId) async {
    try {
      _profile = await _userService.getUserById(userId);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load profile: $e');
    }
  }

  Future<void> updateProfile(
    int userId, {
    String? nickname,
    String? bio,
  }) async {
    final updated = await _userService.updateProfile(
      userId,
      nickname: nickname,
      bio: bio,
    );
    _profile = updated;
    notifyListeners();
  }

  Future<void> changePassword(
    int userId,
    String oldPassword,
    String newPassword,
  ) async {
    await _userService.changePassword(userId, oldPassword, newPassword);
  }

  Future<void> loadHistory(int userId) async {
    try {
      _history = await _userService.getHistory(userId);
    } catch (e) {
      debugPrint('Failed to load history: $e');
    }
    notifyListeners();
  }

  Future<void> addToHistory(int userId, int videoId) async {
    await _userService.recordHistory(userId, videoId);
    await loadHistory(userId);
  }

  Future<void> loadFavorites(int userId) async {
    try {
      _favoriteVideos = await _userService.getFavorites(userId);
    } catch (e) {
      debugPrint('Failed to load favorites: $e');
    }
    notifyListeners();
  }

  Future<void> addToFavorites(int userId, int videoId) async {
    await _userService.addToFavorites(userId, videoId);
    await loadFavorites(userId);
  }

  Future<void> removeFromFavorites(int userId, int videoId) async {
    await _userService.removeFromFavorites(userId, videoId);
    await loadFavorites(userId);
  }

  Future<void> loadLikedVideos(int userId) async {
    try {
      _likedVideoIds = await _userService.getMyLikedVideos(userId);
    } catch (e) {
      debugPrint('Failed to load liked videos: $e');
    }
  }

  Future<void> likeVideo(int userId, int videoId) async {
    await _userService.likeVideo(userId, videoId);
    if (!_likedVideoIds.contains(videoId)) {
      _likedVideoIds.add(videoId);
    }
    notifyListeners();
  }

  Future<void> unlikeVideo(int userId, int videoId) async {
    await _userService.unlikeVideo(userId, videoId);
    _likedVideoIds.remove(videoId);
    notifyListeners();
  }

  Future<List<UserModel>> getAllUsers() async {
    return _userService.getAllUsers();
  }

  Future<void> banUser(int userId) async {
    await _userService.banUser(userId);
  }

  Future<void> unbanUser(int userId) async {
    await _userService.unbanUser(userId);
  }

  Future<UserModel?> getUserById(int userId) async {
    try {
      return await _userService.getUserById(userId);
    } catch (e) {
      debugPrint('Failed to load user: $e');
      return null;
    }
  }
}
