import 'package:http/http.dart' as http;

import '../models/video_model.dart';
import 'api/api_client.dart';
import 'api/api_exception.dart';
import 'i_video_service.dart';

class RealVideoService implements IVideoService {
  RealVideoService(this._client);

  final ApiClient _client;

  @override
  Future<List<VideoModel>> getHomeFeed({int page = 1, int size = 10}) async {
    final json = await _client.getJson('/api/videos');
    return _parseVideoList(
      json['videos'] as List<dynamic>? ?? const <dynamic>[],
    );
  }

  @override
  Future<List<VideoModel>> getRefreshedHomeFeed({int page = 1, int size = 10}) {
    return getHomeFeed(page: page, size: size);
  }

  @override
  Future<(List<VideoModel>, int)> searchVideos(
    String query, {
    int page = 1,
    int size = 10,
  }) async {
    final json = await _client.getJson(
      '/api/videos/search',
      queryParameters: {'q': query, 'page': page},
    );
    final videos = _parseVideoList(
      json['videos'] as List<dynamic>? ?? const <dynamic>[],
    );
    final totalPages = (json['totalPages'] as num?)?.toInt() ?? 1;
    return (videos, totalPages);
  }

  @override
  Future<VideoModel> getVideoById(int id) async {
    final json = await _client.getJson('/api/videos/$id');
    return VideoModel.fromDetailJson(json);
  }

  @override
  Future<UploadMediaResult> uploadMedia({
    required UploadFileData videoFile,
    required UploadFileData thumbnailFile,
    UploadProgressCallback? onProgress,
  }) async {
    final json = await _client.postMultipart(
      '/api/videos/upload',
      files: [
        await _createMultipartFile('video', videoFile),
        await _createMultipartFile('thumbnail', thumbnailFile),
      ],
      onProgress: onProgress,
    );

    return UploadMediaResult(
      videoUrl: (json['video_url'] ?? '').toString(),
      thumbnailUrl: (json['thumbnail_url'] ?? '').toString(),
    );
  }

  @override
  Future<VideoModel> publishVideo(
    int uploaderId,
    String title,
    String intro,
    String videoUrl,
    String thumbnailUrl,
  ) async {
    await _client.postJson(
      '/api/videos/publish',
      body: {
        'title': title,
        'description': intro,
        'src': videoUrl,
        'thumbnail': thumbnailUrl,
      },
    );

    return VideoModel(
      id: 0,
      uploaderId: uploaderId,
      title: title,
      intro: intro,
      status: 'reviewing',
      likesCount: 0,
      favoritesCount: 0,
      coinsCount: 0,
      videoUrl: videoUrl,
      thumbnailUrl: thumbnailUrl,
      createDate: DateTime.now(),
    );
  }

  @override
  Future<void> deleteVideo(int id) async {
    throw UnsupportedError('后端暂未提供删除视频接口');
  }

  @override
  Future<List<VideoModel>> getPublishedVideos(int userId) async {
    final json = await _client.getJson('/api/users/$userId');
    final items = json['videos'] as List<dynamic>? ?? const <dynamic>[];
    return items.map((item) {
      final video = (item as Map).cast<String, dynamic>();
      return VideoModel.fromListJson(video, uploaderIdFallback: userId);
    }).toList();
  }

  @override
  Future<Map<String, int>> getVideoStats(int userId) async {
    final json = await _client.getJson('/api/users/$userId');
    final videos = json['videos'] as List<dynamic>? ?? const <dynamic>[];
    return {
      'total_likes': (json['likes'] as num?)?.toInt() ?? 0,
      'total_coins': (json['earn_coins'] as num?)?.toInt() ?? 0,
      'total_videos': videos.length,
    };
  }

  @override
  Future<void> likeVideo(int videoId) async {
    await _client.postJson('/api/videos/like', body: {'video_id': videoId});
  }

  @override
  Future<void> unlikeVideo(int videoId) async {
    await _client.postJson('/api/videos/unlike', body: {'video_id': videoId});
  }

  @override
  Future<void> favoriteVideo(int videoId) async {
    await _client.postJson('/api/videos/favorite', body: {'video_id': videoId});
  }

  @override
  Future<void> unfavoriteVideo(int videoId) async {
    await _client.postJson(
      '/api/videos/unfavorite',
      body: {'video_id': videoId},
    );
  }

  List<VideoModel> _parseVideoList(List<dynamic> items) {
    return items.map((item) {
      final json = (item as Map).cast<String, dynamic>();
      return VideoModel.fromListJson(json);
    }).toList();
  }

  Future<http.MultipartFile> _createMultipartFile(
    String field,
    UploadFileData file,
  ) async {
    // Web 端 fromPath 不可用，优先使用 bytes
    if (file.bytes case final bytes? when bytes.isNotEmpty) {
      return http.MultipartFile.fromBytes(field, bytes, filename: file.name);
    }
    if (file.path case final path? when path.isNotEmpty) {
      return http.MultipartFile.fromPath(field, path, filename: file.name);
    }
    throw ApiException('请选择有效的$field文件');
  }
}
