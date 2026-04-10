class CommentModel {
  CommentModel({
    required this.id,
    this.userId,
    required this.videoId,
    required this.status,
    required this.createDate,
    this.parentId,
    required this.context,
    this.replies = const [],
    this.username,
    this.likes = 0,
    this.isLiked = false,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
    id: _readInt(json, 'id'),
    userId: _readNullableInt(json, 'user_id'),
    videoId: _readInt(json, 'video_id'),
    status: _readString(json, 'status', fallback: 'none'),
    createDate: _readDateTime(json, 'create_date'),
    parentId: _readNullableInt(json, 'parent_id'),
    context: _readString(json, 'context'),
    username: json['username'] as String?,
  );

  factory CommentModel.fromApiJson(
    Map<String, dynamic> json, {
    required int videoId,
    String fallbackUsername = '',
  }) {
    final parentId = _readNullableInt(
      json,
      'parent_id',
      aliases: const ['parentId'],
    );
    final username = _readString(
      json,
      'username',
      aliases: const ['nickname', 'user_nickname', 'authorName'],
      fallback: fallbackUsername,
    );

    return CommentModel(
      id: _readInt(json, 'id'),
      userId: _readNullableInt(json, 'user_id', aliases: const ['userId']),
      videoId: _readInt(
        json,
        'video_id',
        aliases: const ['videoId'],
        fallback: videoId,
      ),
      status: _readString(json, 'status', fallback: 'none'),
      createDate: _readDateTime(
        json,
        'create_date',
        aliases: const ['createdAt', 'createDate'],
      ),
      parentId: parentId == null || parentId == 0 ? null : parentId,
      context: _readString(json, 'content', aliases: const ['context']),
      username: username.isEmpty ? null : username,
      likes: _readInt(json, 'likes'),
      isLiked: _readBool(json, 'is_liked', aliases: const ['isLiked']),
    );
  }

  final int id;
  final int? userId; // null = deleted user
  final int videoId;
  final String status; // 'del' | 'none'
  final DateTime createDate;
  final int? parentId;
  final String context;
  final List<CommentModel> replies;
  final String? username; // display name from join, null if deleted
  final int likes;
  final bool isLiked;

  CommentModel copyWith({
    int? id,
    Object? userId = _sentinel,
    int? videoId,
    String? status,
    DateTime? createDate,
    Object? parentId = _sentinel,
    String? context,
    List<CommentModel>? replies,
    Object? username = _sentinel,
    int? likes,
    bool? isLiked,
  }) {
    return CommentModel(
      id: id ?? this.id,
      userId: identical(userId, _sentinel) ? this.userId : userId as int?,
      videoId: videoId ?? this.videoId,
      status: status ?? this.status,
      createDate: createDate ?? this.createDate,
      parentId: identical(parentId, _sentinel)
          ? this.parentId
          : parentId as int?,
      context: context ?? this.context,
      replies: replies ?? this.replies,
      username: identical(username, _sentinel)
          ? this.username
          : username as String?,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  static const Object _sentinel = Object();

  static int _readInt(
    Map<String, dynamic> json,
    String key, {
    List<String> aliases = const [],
    int fallback = 0,
  }) {
    return _readNullableInt(json, key, aliases: aliases, fallback: fallback) ??
        fallback;
  }

  static int? _readNullableInt(
    Map<String, dynamic> json,
    String key, {
    List<String> aliases = const [],
    int? fallback,
  }) {
    for (final candidate in [key, ...aliases]) {
      final value = json[candidate];
      if (value is num) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return fallback;
  }

  static String _readString(
    Map<String, dynamic> json,
    String key, {
    List<String> aliases = const [],
    String fallback = '',
  }) {
    for (final candidate in [key, ...aliases]) {
      final value = json[candidate];
      if (value is String && value.trim().isNotEmpty) {
        return value;
      }
    }
    return fallback;
  }

  static DateTime _readDateTime(
    Map<String, dynamic> json,
    String key, {
    List<String> aliases = const [],
  }) {
    for (final candidate in [key, ...aliases]) {
      final value = json[candidate];
      if (value is String && value.trim().isNotEmpty) {
        final parsed = DateTime.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return DateTime.now();
  }

  static bool _readBool(
    Map<String, dynamic> json,
    String key, {
    List<String> aliases = const [],
    bool fallback = false,
  }) {
    for (final candidate in [key, ...aliases]) {
      final value = json[candidate];
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) {
        final normalized = value.trim().toLowerCase();
        if (normalized == 'true' || normalized == '1') return true;
        if (normalized == 'false' || normalized == '0') return false;
      }
    }
    return fallback;
  }
}
