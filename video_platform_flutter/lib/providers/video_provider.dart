import 'package:flutter/material.dart';

import '../models/video_model.dart';
import '../services/i_video_service.dart';

class VideoProvider extends ChangeNotifier {
  VideoProvider(this._videoService);

  final IVideoService _videoService;

  List<VideoModel> _homeFeed = [];
  List<VideoModel> _searchResults = [];
  VideoModel? _currentVideo;
  List<VideoModel> _publishedVideos = [];
  final Set<int> _likedVideos = {};
  final Set<int> _favoritedVideos = {};
  bool _loading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;
  String _searchQuery = '';
  int _searchPage = 1;
  int _searchTotalPages = 1;
  double _uploadProgress = 0.0;

  List<VideoModel> get homeFeed => _homeFeed;
  List<VideoModel> get searchResults => _searchResults;
  VideoModel? get currentVideo => _currentVideo;
  List<VideoModel> get publishedVideos => _publishedVideos;
  bool get loading => _loading;
  String? get error => _error;
  int get currentPage => _currentPage;
  bool get hasMore => _hasMore;
  int get searchPage => _searchPage;
  int get searchTotalPages => _searchTotalPages;
  Set<int> get likedVideos => _likedVideos;
  Set<int> get favoritedVideos => _favoritedVideos;
  bool get isSearching => _searchQuery.isNotEmpty;
  double get uploadProgress => _uploadProgress;

  Future<void> toggleLike(int videoId) async {
    if (_likedVideos.contains(videoId)) {
      await _videoService.unlikeVideo(videoId);
      _likedVideos.remove(videoId);
      _updateVideoLikes(videoId, -1);
    } else {
      await _videoService.likeVideo(videoId);
      _likedVideos.add(videoId);
      _updateVideoLikes(videoId, 1);
    }
    notifyListeners();
  }

  void _updateVideoLikes(int videoId, int delta) {
    void updateList(List<VideoModel> list) {
      final idx = list.indexWhere((v) => v.id == videoId);
      if (idx != -1) {
        final old = list[idx];
        list[idx] = VideoModel(
          id: old.id,
          uploaderId: old.uploaderId,
          title: old.title,
          intro: old.intro,
          status: old.status,
          likesCount: old.likesCount + delta,
          favoritesCount: old.favoritesCount,
          coinsCount: old.coinsCount,
          videoUrl: old.videoUrl,
          thumbnailUrl: old.thumbnailUrl,
          createDate: old.createDate,
        );
      }
    }

    updateList(_homeFeed);
    updateList(_searchResults);
    updateList(_publishedVideos);
    if (_currentVideo?.id == videoId) {
      final old = _currentVideo!;
      _currentVideo = VideoModel(
        id: old.id,
        uploaderId: old.uploaderId,
        title: old.title,
        intro: old.intro,
        status: old.status,
        likesCount: old.likesCount + delta,
        favoritesCount: old.favoritesCount,
        coinsCount: old.coinsCount,
        videoUrl: old.videoUrl,
        thumbnailUrl: old.thumbnailUrl,
        createDate: old.createDate,
      );
    }
  }

  Future<void> toggleFavorite(int videoId) async {
    if (_favoritedVideos.contains(videoId)) {
      await _videoService.unfavoriteVideo(videoId);
      _favoritedVideos.remove(videoId);
      _updateVideoFavorites(videoId, -1);
    } else {
      await _videoService.favoriteVideo(videoId);
      _favoritedVideos.add(videoId);
      _updateVideoFavorites(videoId, 1);
    }
    notifyListeners();
  }

  void setFavoritedVideoIds(Iterable<int> ids) {
    _favoritedVideos
      ..clear()
      ..addAll(ids);
    notifyListeners();
  }

  void syncFavoriteState(int videoId, {required bool isFavorited}) {
    final wasFavorited = _favoritedVideos.contains(videoId);
    if (wasFavorited == isFavorited) {
      return;
    }

    if (isFavorited) {
      _favoritedVideos.add(videoId);
      _updateVideoFavorites(videoId, 1);
    } else {
      _favoritedVideos.remove(videoId);
      _updateVideoFavorites(videoId, -1);
    }
    notifyListeners();
  }

  void _updateVideoFavorites(int videoId, int delta) {
    void updateList(List<VideoModel> list) {
      final idx = list.indexWhere((v) => v.id == videoId);
      if (idx != -1) {
        list[idx] = list[idx].copyWith(
          favoritesCount: (list[idx].favoritesCount + delta).clamp(0, 1 << 31),
        );
      }
    }

    updateList(_homeFeed);
    updateList(_searchResults);
    updateList(_publishedVideos);
    if (_currentVideo?.id == videoId) {
      _currentVideo = _currentVideo!.copyWith(
        favoritesCount: (_currentVideo!.favoritesCount + delta).clamp(
          0,
          1 << 31,
        ),
      );
    }
  }

  Future<void> loadHomeFeed() async {
    _loading = true;
    _error = null;
    _currentPage = 1;
    notifyListeners();
    try {
      _homeFeed = await _videoService.getHomeFeed(page: _currentPage);
      _hasMore = false;
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> refreshHomeFeed() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _homeFeed = await _videoService.getRefreshedHomeFeed();
      _currentPage = 1;
      _hasMore = false;
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (!_hasMore || _loading) return;
    _currentPage++;
    try {
      final newVideos = await _videoService.getHomeFeed(page: _currentPage);
      _homeFeed.addAll(newVideos);
      _hasMore = newVideos.length >= 10;
    } catch (e) {
      _error = e.toString();
      _currentPage--;
    }
    notifyListeners();
  }

  Future<void> searchVideos(String query, {int page = 1}) async {
    _loading = true;
    _error = null;
    if (query.isNotEmpty) _searchQuery = query.trim();
    _searchPage = page;
    notifyListeners();
    try {
      final (results, totalPages) = await _videoService.searchVideos(
        _searchQuery,
        page: _searchPage,
      );
      _searchResults = results;
      _searchTotalPages = totalPages;
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> getVideoById(int id) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _currentVideo = await _videoService.getVideoById(id);
      if (_currentVideo!.isLiked) {
        _likedVideos.add(id);
      } else {
        _likedVideos.remove(id);
      }
      if (_currentVideo!.isFavorited) {
        _favoritedVideos.add(id);
      } else {
        _favoritedVideos.remove(id);
      }
      final existing = [
        ..._homeFeed,
        ..._searchResults,
        ..._publishedVideos,
      ].where((item) => item.id == id).firstOrNull;
      if (existing != null) {
        _currentVideo = _currentVideo!.copyWith(
          uploaderId: _currentVideo!.uploaderId ?? existing.uploaderId,
          title: existing.title.isNotEmpty
              ? existing.title
              : _currentVideo!.title,
          intro: _currentVideo!.intro.isNotEmpty
              ? _currentVideo!.intro
              : existing.intro,
          status: existing.status,
          likesCount: _currentVideo!.likesCount > 0
              ? _currentVideo!.likesCount
              : existing.likesCount,
          favoritesCount: _currentVideo!.favoritesCount > 0
              ? _currentVideo!.favoritesCount
              : existing.favoritesCount,
          coinsCount: _currentVideo!.coinsCount > 0
              ? _currentVideo!.coinsCount
              : existing.coinsCount,
          thumbnailUrl: _currentVideo!.thumbnailUrl.isNotEmpty
              ? _currentVideo!.thumbnailUrl
              : existing.thumbnailUrl,
          createDate: existing.createDate,
        );
      }
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> publishVideo(
    int uploaderId,
    String title,
    String intro,
    String videoUrl,
    String thumbnailUrl,
  ) async {
    await _videoService.publishVideo(
      uploaderId,
      title,
      intro,
      videoUrl,
      thumbnailUrl,
    );
  }

  Future<UploadMediaResult> uploadFiles({
    required UploadFileData videoFile,
    required UploadFileData thumbnailFile,
    UploadProgressCallback? onProgress,
  }) async {
    _uploadProgress = 0.0;
    notifyListeners();
    return _videoService.uploadMedia(
      videoFile: videoFile,
      thumbnailFile: thumbnailFile,
      onProgress: (progress) {
        _uploadProgress = progress;
        notifyListeners();
        onProgress?.call(progress);
      },
    );
  }

  Future<void> uploadAndPublishVideo(
    int uploaderId,
    String title,
    String intro,
    UploadFileData videoFile,
    UploadFileData thumbnailFile,
  ) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final uploaded = await uploadFiles(
        videoFile: videoFile,
        thumbnailFile: thumbnailFile,
      );
      await publishVideo(
        uploaderId,
        title,
        intro,
        uploaded.videoUrl,
        uploaded.thumbnailUrl,
      );
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _loading = false;
      _uploadProgress = 0.0;
      notifyListeners();
    }
  }

  Future<void> deleteVideo(int id, int userId) async {
    await _videoService.deleteVideo(id);
    _homeFeed.removeWhere((v) => v.id == id);
    _publishedVideos.removeWhere((v) => v.id == id);
    if (_currentVideo?.id == id) _currentVideo = null;
    notifyListeners();
  }

  Future<void> loadPublishedVideos(int userId) async {
    _loading = true;
    notifyListeners();
    try {
      _publishedVideos = await _videoService.getPublishedVideos(userId);
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<Map<String, int>> getVideoStats(int userId) async {
    return _videoService.getVideoStats(userId);
  }

  void clearSearch() {
    _searchQuery = '';
    _searchResults.clear();
    notifyListeners();
  }
}
