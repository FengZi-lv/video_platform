class VideoHistoryRecord {
  VideoHistoryRecord({
    required this.userId,
    required this.videoId,
    required this.lastWatchDate,
  });

  final int userId;
  final int videoId;
  final DateTime lastWatchDate;
}
