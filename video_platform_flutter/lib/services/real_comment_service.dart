import '../models/comment_model.dart';
import 'api/api_client.dart';
import 'api/api_session.dart';
import 'i_comment_service.dart';

class RealCommentService implements ICommentService {
  RealCommentService(this._client, this._session);

  final ApiClient _client;
  final ApiSession _session;

  @override
  Future<List<CommentModel>> getComments(int videoId) async {
    final json = await _client.getJson('/api/videos/$videoId');
    final comments = (json['comments'] as List<dynamic>? ?? const <dynamic>[])
        .map(
          (item) =>
              _parseComment(videoId, (item as Map).cast<String, dynamic>()),
        )
        .toList();

    // Collect unique userIds of commenters without a username
    final userIds = <int>{};
    void collectIds(List<CommentModel> items) {
      for (final c in items) {
        if (c.userId != null && c.userId! > 0 && c.username == null) {
          userIds.add(c.userId!);
        }
        collectIds(c.replies);
      }
    }

    collectIds(comments);

    // Fetch user nicknames for each unique userId
    Map<int, String> nicknames = {};
    for (final userId in userIds) {
      try {
        final userJson = await _client.getJson('/api/users/$userId');
        final nickname = _readString(
          userJson,
          'nickname',
          aliases: const ['username', 'display_name'],
        );
        if (nickname.isNotEmpty) {
          nicknames[userId] = nickname;
        }
      } catch (_) {
        // Keep fallback display name when user lookup fails.
      }
    }

    // Build tree with enriched nicknames
    return _buildTree(
      comments,
      enrich: (c) {
        final nickname = c.userId != null ? nicknames[c.userId] : null;
        return c.copyWith(username: c.username ?? nickname ?? '匿名用户');
      },
    );
  }

  CommentModel _parseComment(int videoId, Map<String, dynamic> json) {
    return CommentModel.fromApiJson(json, videoId: videoId);
  }

  @override
  Future<void> addComment(
    int userId,
    int videoId,
    String context, {
    int? parentId,
  }) async {
    await _client.postJson(
      '/api/comments',
      body: {'video_id': videoId, 'content': context, 'parent_id': parentId},
    );
  }

  @override
  Future<void> deleteComment(int commentId) async {
    await _client.deleteJson('/api/comments/$commentId');
  }

  @override
  Future<void> likeComment(int userId, int commentId) async {
    await _client.postJson(
      '/api/comments/like',
      body: {'comment_id': commentId},
    );
  }

  @override
  Future<void> unlikeComment(int userId, int commentId) async {
    await _client.postJson(
      '/api/comments/unlike',
      body: {'comment_id': commentId},
    );
  }

  @override
  Future<bool> hasLikedComment(int userId, int commentId) async {
    return false;
  }

  @override
  Future<CommentModel?> getComment(int commentId) async => null;

  List<CommentModel> _buildTree(
    List<CommentModel> comments, {
    CommentModel Function(CommentModel)? enrich,
  }) {
    // First enrich all comments
    final enriched = comments
        .map((c) => enrich != null ? enrich(c) : c)
        .toList();

    final commentsById = <int, CommentModel>{for (final c in enriched) c.id: c};
    final groupedByParent = <int?, List<CommentModel>>{};

    for (final c in enriched) {
      groupedByParent.putIfAbsent(c.parentId, () => []).add(c);
    }

    List<CommentModel> buildReplies(int parentId) {
      final children = groupedByParent[parentId] ?? const [];
      return children
          .map((c) => c.copyWith(replies: buildReplies(c.id)))
          .toList();
    }

    final roots = enriched.where((c) {
      return c.parentId == null || !commentsById.containsKey(c.parentId);
    }).toList();

    return roots.map((c) => c.copyWith(replies: buildReplies(c.id))).toList();
  }

  String _readString(
    Map<String, dynamic> json,
    String key, {
    List<String> aliases = const [],
    String fallback = '',
  }) {
    for (final candidate in [key, ...aliases]) {
      final value = json[candidate];
      if (value is String && value.trim().isNotEmpty) return value;
    }
    return fallback;
  }
}
