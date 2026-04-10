import '../services/api/api_config.dart';

class VideoModel {
  VideoModel({
    required this.id,
    required this.uploaderId,
    required this.title,
    required this.intro,
    required this.status,
    required this.likesCount,
    required this.favoritesCount,
    required this.coinsCount,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.createDate,
    this.isLiked = false,
    this.isFavorited = false,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) => VideoModel(
    id: _readInt(json, 'id'),
    uploaderId: _readNullableInt(json, 'uploader_id'),
    title: _readString(json, 'title'),
    intro: _readString(json, 'intro'),
    status: _readString(json, 'status', fallback: 'pass'),
    likesCount: _readInt(json, 'likes_count'),
    favoritesCount: _readInt(json, 'favorites_count'),
    coinsCount: _readInt(json, 'coins_count'),
    videoUrl: _buildMediaUrl(_readString(json, 'video_url'), 'play'),
    thumbnailUrl: _buildMediaUrl(
      _readString(json, 'thumbnail_url'),
      'thumbnail',
    ),
    createDate: _readDateTime(json, 'create_date'),
  );

  factory VideoModel.fromListJson(
    Map<String, dynamic> json, {
    int? uploaderIdFallback,
    String fallbackStatus = 'pass',
  }) {
    return VideoModel(
      id: _readInt(json, 'id'),
      uploaderId: _readNullableInt(
        json,
        'uploader_id',
        aliases: const ['user_id', 'uploaderId'],
        fallback: uploaderIdFallback,
      ),
      title: _readString(json, 'title', fallback: '未命名视频'),
      intro: _readString(json, 'description', aliases: const ['intro']),
      status: _readString(json, 'status', fallback: fallbackStatus),
      likesCount: _readInt(json, 'likes', aliases: const ['likes_count']),
      favoritesCount: _readInt(
        json,
        'favorites',
        aliases: const ['favorites_count'],
      ),
      coinsCount: _readInt(
        json,
        'earn_coins',
        aliases: const ['coins', 'coins_count'],
      ),
      videoUrl: _buildMediaUrl(_readString(json, 'src'), 'play'),
      thumbnailUrl: _buildMediaUrl(_readString(json, 'thumbnail'), 'thumbnail'),
      createDate: _readDateTime(
        json,
        'create_date',
        aliases: const ['createdAt', 'createDate'],
      ),
    );
  }

  factory VideoModel.fromDetailJson(Map<String, dynamic> json) {
    return VideoModel(
      id: _readInt(json, 'id'),
      uploaderId: _readNullableInt(
        json,
        'uploader_id',
        aliases: const ['user_id', 'uploaderId'],
      ),
      title: _readString(json, 'title', fallback: '视频详情'),
      intro: _readString(json, 'description', aliases: const ['intro']),
      status: _readString(json, 'status', fallback: 'pass'),
      likesCount: _readInt(json, 'likes', aliases: const ['likes_count']),
      favoritesCount: _readInt(
        json,
        'favorites',
        aliases: const ['favorites_count'],
      ),
      coinsCount: _readInt(
        json,
        'earn_coins',
        aliases: const ['coins', 'coins_count'],
      ),
      videoUrl: _buildMediaUrl(
        _readString(json, 'src', aliases: const ['video_url']),
        'play',
      ),
      thumbnailUrl: _buildMediaUrl(_readString(json, 'thumbnail'), 'thumbnail'),
      createDate: _readDateTime(
        json,
        'create_date',
        aliases: const ['createdAt', 'createDate'],
      ),
      isLiked: _readBool(json, 'is_liked', aliases: const ['isLiked']),
      isFavorited: _readBool(
        json,
        'is_favorited',
        aliases: const ['isFavorited'],
      ),
    );
  }

  final int id;
  final int? uploaderId;
  final String title;
  final String intro;
  final String status; // 'reviewing' | 'reject' | 'pass'
  final int likesCount;
  final int favoritesCount;
  final int coinsCount;
  final String videoUrl;
  final String thumbnailUrl;
  final DateTime createDate;
  final bool isLiked;
  final bool isFavorited;

  VideoModel copyWith({
    int? id,
    Object? uploaderId = _sentinel,
    String? title,
    String? intro,
    String? status,
    int? likesCount,
    int? favoritesCount,
    int? coinsCount,
    String? videoUrl,
    String? thumbnailUrl,
    DateTime? createDate,
    bool? isLiked,
    bool? isFavorited,
  }) {
    return VideoModel(
      id: id ?? this.id,
      uploaderId: identical(uploaderId, _sentinel)
          ? this.uploaderId
          : uploaderId as int?,
      title: title ?? this.title,
      intro: intro ?? this.intro,
      status: status ?? this.status,
      likesCount: likesCount ?? this.likesCount,
      favoritesCount: favoritesCount ?? this.favoritesCount,
      coinsCount: coinsCount ?? this.coinsCount,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      createDate: createDate ?? this.createDate,
      isLiked: isLiked ?? this.isLiked,
      isFavorited: isFavorited ?? this.isFavorited,
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

  static String _buildMediaUrl(String filename, String endpoint) {
    if (filename.isEmpty) return '';
    if (filename.startsWith('http://') || filename.startsWith('https://')) {
      return filename;
    }

    // Remove upload path prefixes (e.g. /uploads/) to pass backend security checks
    String safeFilename = filename;
    if (safeFilename.contains('/')) {
      safeFilename = safeFilename.split('/').last;
    }
    if (safeFilename.contains('\\')) {
      safeFilename = safeFilename.split('\\').last;
    }

    return '${ApiConfig.baseUrl}/api/video/$endpoint?name=${Uri.encodeComponent(safeFilename)}';
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
