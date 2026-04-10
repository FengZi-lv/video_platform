class VideoLikeRecord {
  VideoLikeRecord({
    required this.userId,
    required this.videoId,
    required this.createDate,
  });

  final int userId;
  final int videoId;
  final DateTime createDate;
}

class CommentLikeRecord {
  CommentLikeRecord({required this.userId, required this.commentId});

  final int userId;
  final int commentId;
}
