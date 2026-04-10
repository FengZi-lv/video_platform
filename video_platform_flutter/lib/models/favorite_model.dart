class VideoFavoriteRecord {
  VideoFavoriteRecord({
    required this.userId,
    required this.videoId,
    required this.createDate,
  });

  final int userId;
  final int videoId;
  final DateTime createDate;
}
