import '../models/comment_model.dart';

abstract class ICommentService {
  Future<List<CommentModel>> getComments(int videoId);
  Future<void> addComment(
    int userId,
    int videoId,
    String context, {
    int? parentId,
  });
  Future<void> deleteComment(int commentId);
  Future<void> likeComment(int userId, int commentId);
  Future<void> unlikeComment(int userId, int commentId);
  Future<bool> hasLikedComment(int userId, int commentId);
  Future<CommentModel?> getComment(int commentId);
}
