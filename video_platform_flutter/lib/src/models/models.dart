import 'package:flutter/material.dart';

enum UserRole { guest, member, banned, admin }

enum FrontSection { home, profile }

enum AdminSection { dashboard, reviews, reports, users }

enum AuditStatus { pending, approved, rejected }

enum ReportStatus { pending, processed }

UserRole userRoleFromJson(String? value) {
  switch (value) {
    case 'admin':
      return UserRole.admin;
    case 'banned':
      return UserRole.banned;
    case 'member':
      return UserRole.member;
    default:
      return UserRole.guest;
  }
}

String userRoleToJson(UserRole role) {
  switch (role) {
    case UserRole.admin:
      return 'admin';
    case UserRole.banned:
      return 'banned';
    case UserRole.member:
      return 'member';
    case UserRole.guest:
      return 'guest';
  }
}

AuditStatus auditStatusFromJson(String? value) {
  switch (value) {
    case 'approved':
      return AuditStatus.approved;
    case 'rejected':
      return AuditStatus.rejected;
    default:
      return AuditStatus.pending;
  }
}

String auditStatusToJson(AuditStatus status) {
  switch (status) {
    case AuditStatus.approved:
      return 'approved';
    case AuditStatus.rejected:
      return 'rejected';
    case AuditStatus.pending:
      return 'pending';
  }
}

ReportStatus reportStatusFromJson(String? value) {
  switch (value) {
    case 'processed':
      return ReportStatus.processed;
    default:
      return ReportStatus.pending;
  }
}

String reportStatusToJson(ReportStatus status) {
  switch (status) {
    case ReportStatus.processed:
      return 'processed';
    case ReportStatus.pending:
      return 'pending';
  }
}

Color colorFromHex(String? value) {
  final cleaned = (value ?? '').replaceAll('#', '');
  if (cleaned.length == 6) {
    return Color(int.parse('FF$cleaned', radix: 16));
  }
  if (cleaned.length == 8) {
    return Color(int.parse(cleaned, radix: 16));
  }
  return const Color(0xFF0D6E6E);
}

String colorToHex(Color color) =>
    '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';

class UserProfile {
  const UserProfile({
    required this.id,
    required this.nickname,
    required this.account,
    required this.bio,
    required this.coins,
    required this.role,
  });

  final String id;
  final String nickname;
  final String account;
  final String bio;
  final int coins;
  final UserRole role;

  bool get isAdmin => role == UserRole.admin;
  bool get isBanned => role == UserRole.banned;
  bool get isAuthenticated => role != UserRole.guest;

  UserProfile copyWith({
    String? nickname,
    String? account,
    String? bio,
    int? coins,
    UserRole? role,
  }) {
    return UserProfile(
      id: id,
      nickname: nickname ?? this.nickname,
      account: account ?? this.account,
      bio: bio ?? this.bio,
      coins: coins ?? this.coins,
      role: role ?? this.role,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      nickname: json['nickname'] as String,
      account: json['account'] as String,
      bio: (json['bio'] ?? '') as String,
      coins: (json['coins'] ?? 0) as int,
      role: userRoleFromJson(json['role'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'account': account,
      'bio': bio,
      'coins': coins,
      'role': userRoleToJson(role),
    };
  }
}

class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.role,
    required this.user,
  });

  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final UserRole role;
  final UserProfile user;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      accessToken: json['accessToken'] as String,
      tokenType: (json['tokenType'] ?? 'Bearer') as String,
      expiresIn: (json['expiresIn'] ?? 7200) as int,
      role: userRoleFromJson(json['role'] as String?),
      user: UserProfile.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'tokenType': tokenType,
      'expiresIn': expiresIn,
      'role': userRoleToJson(role),
      'user': user.toJson(),
    };
  }
}

class VideoMetrics {
  const VideoMetrics({
    required this.likes,
    required this.favorites,
    required this.coins,
    required this.comments,
    required this.views,
  });

  final int likes;
  final int favorites;
  final int coins;
  final int comments;
  final int views;

  VideoMetrics copyWith({
    int? likes,
    int? favorites,
    int? coins,
    int? comments,
    int? views,
  }) {
    return VideoMetrics(
      likes: likes ?? this.likes,
      favorites: favorites ?? this.favorites,
      coins: coins ?? this.coins,
      comments: comments ?? this.comments,
      views: views ?? this.views,
    );
  }

  factory VideoMetrics.fromJson(Map<String, dynamic> json) {
    return VideoMetrics(
      likes: (json['likes'] ?? 0) as int,
      favorites: (json['favorites'] ?? 0) as int,
      coins: (json['coins'] ?? 0) as int,
      comments: (json['comments'] ?? 0) as int,
      views: (json['views'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'likes': likes,
      'favorites': favorites,
      'coins': coins,
      'comments': comments,
      'views': views,
    };
  }
}

class VideoItem {
  const VideoItem({
    required this.id,
    required this.title,
    required this.description,
    required this.ownerId,
    required this.ownerName,
    required this.duration,
    required this.uploadLabel,
    required this.category,
    required this.coverColor,
    required this.metrics,
    required this.isLiked,
    required this.isFavorited,
    required this.status,
  });

  final String id;
  final String title;
  final String description;
  final String ownerId;
  final String ownerName;
  final String duration;
  final String uploadLabel;
  final String category;
  final Color coverColor;
  final VideoMetrics metrics;
  final bool isLiked;
  final bool isFavorited;
  final AuditStatus status;

  VideoItem copyWith({
    String? title,
    String? description,
    String? ownerId,
    String? ownerName,
    String? duration,
    String? uploadLabel,
    String? category,
    Color? coverColor,
    VideoMetrics? metrics,
    bool? isLiked,
    bool? isFavorited,
    AuditStatus? status,
  }) {
    return VideoItem(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      duration: duration ?? this.duration,
      uploadLabel: uploadLabel ?? this.uploadLabel,
      category: category ?? this.category,
      coverColor: coverColor ?? this.coverColor,
      metrics: metrics ?? this.metrics,
      isLiked: isLiked ?? this.isLiked,
      isFavorited: isFavorited ?? this.isFavorited,
      status: status ?? this.status,
    );
  }

  factory VideoItem.fromJson(Map<String, dynamic> json) {
    return VideoItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: (json['description'] ?? '') as String,
      ownerId: json['ownerId'] as String,
      ownerName: json['ownerName'] as String,
      duration: json['duration'] as String,
      uploadLabel: json['uploadLabel'] as String,
      category: json['category'] as String,
      coverColor: colorFromHex(json['coverColor'] as String?),
      metrics: VideoMetrics.fromJson(json['metrics'] as Map<String, dynamic>),
      isLiked: (json['isLiked'] ?? false) as bool,
      isFavorited: (json['isFavorited'] ?? false) as bool,
      status: auditStatusFromJson(json['status'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'duration': duration,
      'uploadLabel': uploadLabel,
      'category': category,
      'coverColor': colorToHex(coverColor),
      'metrics': metrics.toJson(),
      'isLiked': isLiked,
      'isFavorited': isFavorited,
      'status': auditStatusToJson(status),
    };
  }
}

class CommentNode {
  const CommentNode({
    required this.id,
    required this.videoId,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.createdLabel,
    required this.likeCount,
    required this.isLiked,
    required this.replies,
  });

  final String id;
  final String videoId;
  final String authorId;
  final String authorName;
  final String content;
  final String createdLabel;
  final int likeCount;
  final bool isLiked;
  final List<CommentNode> replies;

  CommentNode copyWith({
    String? content,
    String? createdLabel,
    int? likeCount,
    bool? isLiked,
    List<CommentNode>? replies,
  }) {
    return CommentNode(
      id: id,
      videoId: videoId,
      authorId: authorId,
      authorName: authorName,
      content: content ?? this.content,
      createdLabel: createdLabel ?? this.createdLabel,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      replies: replies ?? this.replies,
    );
  }

  factory CommentNode.fromJson(Map<String, dynamic> json) {
    final repliesJson = (json['replies'] as List<dynamic>? ?? const []);
    return CommentNode(
      id: json['id'] as String,
      videoId: json['videoId'] as String,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      content: json['content'] as String,
      createdLabel: json['createdLabel'] as String,
      likeCount: (json['likeCount'] ?? 0) as int,
      isLiked: (json['isLiked'] ?? false) as bool,
      replies: repliesJson
          .map((item) => CommentNode.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'videoId': videoId,
      'authorId': authorId,
      'authorName': authorName,
      'content': content,
      'createdLabel': createdLabel,
      'likeCount': likeCount,
      'isLiked': isLiked,
      'replies': replies.map((reply) => reply.toJson()).toList(),
    };
  }
}

class ReportItem {
  const ReportItem({
    required this.id,
    required this.videoId,
    required this.videoTitle,
    required this.reporterName,
    required this.reason,
    required this.createdLabel,
    required this.status,
  });

  final String id;
  final String videoId;
  final String videoTitle;
  final String reporterName;
  final String reason;
  final String createdLabel;
  final ReportStatus status;

  ReportItem copyWith({ReportStatus? status}) {
    return ReportItem(
      id: id,
      videoId: videoId,
      videoTitle: videoTitle,
      reporterName: reporterName,
      reason: reason,
      createdLabel: createdLabel,
      status: status ?? this.status,
    );
  }

  factory ReportItem.fromJson(Map<String, dynamic> json) {
    return ReportItem(
      id: json['id'] as String,
      videoId: json['videoId'] as String,
      videoTitle: json['videoTitle'] as String,
      reporterName: json['reporterName'] as String,
      reason: json['reason'] as String,
      createdLabel: json['createdLabel'] as String,
      status: reportStatusFromJson(json['status'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'videoId': videoId,
      'videoTitle': videoTitle,
      'reporterName': reporterName,
      'reason': reason,
      'createdLabel': createdLabel,
      'status': reportStatusToJson(status),
    };
  }
}

class AuditItem {
  const AuditItem({
    required this.id,
    required this.videoId,
    required this.videoTitle,
    required this.uploaderName,
    required this.submittedLabel,
    required this.note,
    required this.status,
  });

  final String id;
  final String videoId;
  final String videoTitle;
  final String uploaderName;
  final String submittedLabel;
  final String note;
  final AuditStatus status;

  AuditItem copyWith({AuditStatus? status}) {
    return AuditItem(
      id: id,
      videoId: videoId,
      videoTitle: videoTitle,
      uploaderName: uploaderName,
      submittedLabel: submittedLabel,
      note: note,
      status: status ?? this.status,
    );
  }

  factory AuditItem.fromJson(Map<String, dynamic> json) {
    return AuditItem(
      id: json['id'] as String,
      videoId: json['videoId'] as String,
      videoTitle: json['videoTitle'] as String,
      uploaderName: json['uploaderName'] as String,
      submittedLabel: json['submittedLabel'] as String,
      note: json['note'] as String,
      status: auditStatusFromJson(json['status'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'videoId': videoId,
      'videoTitle': videoTitle,
      'uploaderName': uploaderName,
      'submittedLabel': submittedLabel,
      'note': note,
      'status': auditStatusToJson(status),
    };
  }
}

class VideoStatsSummary {
  const VideoStatsSummary({
    required this.videoCount,
    required this.totalLikes,
    required this.totalFavorites,
    required this.totalCoins,
    required this.totalViews,
  });

  final int videoCount;
  final int totalLikes;
  final int totalFavorites;
  final int totalCoins;
  final int totalViews;

  const VideoStatsSummary.empty()
      : videoCount = 0,
        totalLikes = 0,
        totalFavorites = 0,
        totalCoins = 0,
        totalViews = 0;

  factory VideoStatsSummary.fromJson(Map<String, dynamic> json) {
    return VideoStatsSummary(
      videoCount: (json['videoCount'] ?? 0) as int,
      totalLikes: (json['totalLikes'] ?? 0) as int,
      totalFavorites: (json['totalFavorites'] ?? 0) as int,
      totalCoins: (json['totalCoins'] ?? 0) as int,
      totalViews: (json['totalViews'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'videoCount': videoCount,
      'totalLikes': totalLikes,
      'totalFavorites': totalFavorites,
      'totalCoins': totalCoins,
      'totalViews': totalViews,
    };
  }
}

class AdminDashboardSummary {
  const AdminDashboardSummary({
    required this.pendingAudits,
    required this.pendingReports,
    required this.bannedUsers,
    required this.totalUsers,
  });

  final int pendingAudits;
  final int pendingReports;
  final int bannedUsers;
  final int totalUsers;

  const AdminDashboardSummary.empty()
      : pendingAudits = 0,
        pendingReports = 0,
        bannedUsers = 0,
        totalUsers = 0;

  factory AdminDashboardSummary.fromJson(Map<String, dynamic> json) {
    return AdminDashboardSummary(
      pendingAudits: (json['pendingAudits'] ?? 0) as int,
      pendingReports: (json['pendingReports'] ?? 0) as int,
      bannedUsers: (json['bannedUsers'] ?? 0) as int,
      totalUsers: (json['totalUsers'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pendingAudits': pendingAudits,
      'pendingReports': pendingReports,
      'bannedUsers': bannedUsers,
      'totalUsers': totalUsers,
    };
  }
}

class PagedResult<T> {
  const PagedResult({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalItems,
  });

  final List<T> items;
  final int page;
  final int pageSize;
  final int totalItems;

  int get totalPages => (totalItems / pageSize).ceil().clamp(1, 9999);
  bool get hasPrevious => page > 1;
  bool get hasNext => page < totalPages;
}
