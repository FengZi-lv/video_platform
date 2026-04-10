import 'package:flutter/material.dart';

import '../models/comment_model.dart';
import '../services/i_comment_service.dart';

class CommentProvider extends ChangeNotifier {
  CommentProvider(this._commentService);

  final ICommentService _commentService;

  final Map<int, List<CommentModel>> _commentsByVideoId = {};
  final Set<int> _likedCommentIds = {};
  bool _loading = false;
  String? _error;

  Map<int, List<CommentModel>> get commentsByVideoId => _commentsByVideoId;
  Set<int> get likedCommentIds => _likedCommentIds;
  bool get loading => _loading;
  String? get error => _error;

  /// Get top-level comments for a video (excluding deleted)
  List<CommentModel> getTopLevelComments(int videoId) {
    final comments = _commentsByVideoId[videoId] ?? [];
    return comments
        .where(
          (c) =>
              c.parentId == null && (c.status != 'del' || c.replies.isNotEmpty),
        )
        .toList();
  }

  Future<void> loadComments(int videoId) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final comments = await _commentService.getComments(videoId);
      _commentsByVideoId[videoId] = comments;
      _syncLikedCommentIds(videoId, comments);
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> addComment(
    int userId,
    int videoId,
    String context, {
    int? parentId,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _commentService.addComment(
        userId,
        videoId,
        context,
        parentId: parentId,
      );
      final comments = await _commentService.getComments(videoId);
      _commentsByVideoId[videoId] = comments;
      _syncLikedCommentIds(videoId, comments);
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> deleteComment(int commentId) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final videoId = _findVideoIdByCommentId(commentId);
      await _commentService.deleteComment(commentId);
      if (videoId != null) {
        final comments = await _commentService.getComments(videoId);
        _commentsByVideoId[videoId] = comments;
        _syncLikedCommentIds(videoId, comments);
      }
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> toggleCommentLike(int userId, int commentId) async {
    _error = null;
    try {
      final videoId = _findVideoIdByCommentId(commentId);
      if (_likedCommentIds.contains(commentId)) {
        await _commentService.unlikeComment(userId, commentId);
        _likedCommentIds.remove(commentId);
      } else {
        await _commentService.likeComment(userId, commentId);
        _likedCommentIds.add(commentId);
      }
      if (videoId != null) {
        final comments = await _commentService.getComments(videoId);
        _commentsByVideoId[videoId] = comments;
        _syncLikedCommentIds(videoId, comments);
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  int? _findVideoIdByCommentId(int commentId) {
    for (final entry in _commentsByVideoId.entries) {
      if (_containsComment(entry.value, commentId)) {
        return entry.key;
      }
    }
    return null;
  }

  bool _containsComment(List<CommentModel> comments, int commentId) {
    for (final comment in comments) {
      if (comment.id == commentId ||
          _containsComment(comment.replies, commentId)) {
        return true;
      }
    }
    return false;
  }

  void _syncLikedCommentIds(int videoId, List<CommentModel> comments) {
    final commentIds = <int>{};
    final likedIds = <int>{};

    void collect(List<CommentModel> items) {
      for (final comment in items) {
        commentIds.add(comment.id);
        if (comment.isLiked) {
          likedIds.add(comment.id);
        }
        collect(comment.replies);
      }
    }

    collect(comments);
    _likedCommentIds.removeWhere((id) => commentIds.contains(id));
    _likedCommentIds.addAll(likedIds);
  }
}
