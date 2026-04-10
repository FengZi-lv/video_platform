import '../models/video_model.dart';

typedef UploadProgressCallback = void Function(double progress);

class UploadFileData {
  const UploadFileData({required this.name, this.bytes, this.path});

  final String name;
  final List<int>? bytes;
  final String? path;
}

class UploadMediaResult {
  const UploadMediaResult({required this.videoUrl, required this.thumbnailUrl});

  final String videoUrl;
  final String thumbnailUrl;
}

abstract class IVideoService {
  Future<List<VideoModel>> getHomeFeed({int page = 1, int size = 10});
  Future<List<VideoModel>> getRefreshedHomeFeed({int page = 1, int size = 10});
  Future<(List<VideoModel>, int)> searchVideos(
    String query, {
    int page = 1,
    int size = 10,
  });
  Future<VideoModel> getVideoById(int id);
  Future<UploadMediaResult> uploadMedia({
    required UploadFileData videoFile,
    required UploadFileData thumbnailFile,
    UploadProgressCallback? onProgress,
  });
  Future<VideoModel> publishVideo(
    int uploaderId,
    String title,
    String intro,
    String videoUrl,
    String thumbnailUrl,
  );
  Future<void> deleteVideo(int id);
  Future<List<VideoModel>> getPublishedVideos(int userId);
  Future<Map<String, int>> getVideoStats(int userId);
  Future<void> likeVideo(int videoId);
  Future<void> unlikeVideo(int videoId);
  Future<void> favoriteVideo(int videoId);
  Future<void> unfavoriteVideo(int videoId);
}
