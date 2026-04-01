import 'package:flutter/material.dart';
import 'package:video_platform_flutter/src/api/platform_api.dart';
import 'package:video_platform_flutter/src/models/models.dart';

class FakePlatformApi implements PlatformApi {
  FakePlatformApi() {
    _users = [
      const UserProfile(id: 'user_member', nickname: '青柚放映室', account: 'member', bio: '记录城市、影像和生活里的细小惊喜。', coins: 24, role: UserRole.member),
      const UserProfile(id: 'user_admin', nickname: '审核中心', account: 'admin', bio: '平台管理员账号', coins: 99, role: UserRole.admin),
      const UserProfile(id: 'user_banned', nickname: '受限用户', account: 'banned', bio: '该账号已被封禁', coins: 2, role: UserRole.banned),
    ];
    _videos = [
      _video('video_1', '下班后骑行 18 公里，路过灯光刚亮起的滨江', '一支带着晚风的城市骑行短片。', 'user_member', '青柚放映室', '08:12', '推荐', const Color(0xFF2C6E6F), const VideoMetrics(likes: 328, favorites: 190, coins: 65, comments: 2, views: 4821), AuditStatus.approved),
      _video('video_2', '如何把周末旅行拍得像电影感片头', '从镜头运动到剪辑节奏的轻量教程。', 'user_admin', '审核中心', '11:30', '教程', const Color(0xFF8C5E34), const VideoMetrics(likes: 611, favorites: 404, coins: 120, comments: 1, views: 7388), AuditStatus.approved, isLiked: true),
      _video('video_3', '凌晨五点的菜市场，为什么总能治愈人', '一次完整清晨记录。', 'user_member', '青柚放映室', '05:56', '纪实', const Color(0xFF5E7689), const VideoMetrics(likes: 912, favorites: 520, coins: 208, comments: 0, views: 12120), AuditStatus.approved, isFavorited: true),
      _video('video_4', '提交审核中的样片：海边晨雾延时合集', '等待审核的视频内容。', 'user_member', '青柚放映室', '03:48', '待审核', const Color(0xFF546B88), const VideoMetrics(likes: 0, favorites: 0, coins: 0, comments: 0, views: 0), AuditStatus.pending),
    ];
    _comments = {
      'video_1': [
        const CommentNode(id: 'comment_1', videoId: 'video_1', authorId: 'user_admin', authorName: '审核中心', content: '骑行段落和配乐衔接得很顺。', createdLabel: '18 分钟前', likeCount: 14, isLiked: false, replies: []),
        const CommentNode(id: 'comment_2', videoId: 'video_1', authorId: 'user_member', authorName: '青柚放映室', content: '谢谢喜欢。', createdLabel: '12 分钟前', likeCount: 7, isLiked: true, replies: []),
      ],
      'video_2': [
        const CommentNode(id: 'comment_3', videoId: 'video_2', authorId: 'user_member', authorName: '青柚放映室', content: '教程节奏很好。', createdLabel: '昨天', likeCount: 23, isLiked: true, replies: []),
      ],
    };
    _audits = [
      const AuditItem(id: 'audit_1', videoId: 'video_4', videoTitle: '提交审核中的样片：海边晨雾延时合集', uploaderName: '青柚放映室', submittedLabel: '10 分钟前', note: '检查画面内容与封面是否一致。', status: AuditStatus.pending),
    ];
    _reports = [
      const ReportItem(id: 'report_1', videoId: 'video_2', videoTitle: '如何把周末旅行拍得像电影感片头', reporterName: '青柚放映室', reason: '疑似搬运未标注来源', createdLabel: '今天 09:20', status: ReportStatus.pending),
    ];
    _history = ['video_3', 'video_2'];
    _favorites = {'video_3'};
  }

  late List<UserProfile> _users;
  late List<VideoItem> _videos;
  late Map<String, List<CommentNode>> _comments;
  late List<AuditItem> _audits;
  late List<ReportItem> _reports;
  late List<String> _history;
  late Set<String> _favorites;

  static VideoItem _video(String id, String title, String description, String ownerId, String ownerName, String duration, String category, Color coverColor, VideoMetrics metrics, AuditStatus status, {bool isLiked = false, bool isFavorited = false}) => VideoItem(id: id, title: title, description: description, ownerId: ownerId, ownerName: ownerName, duration: duration, uploadLabel: '刚刚', category: category, coverColor: coverColor, metrics: metrics, isLiked: isLiked, isFavorited: isFavorited, status: status);

  UserProfile _userFromToken(String token) {
    final account = token.replaceFirst('token_', '');
    return _users.firstWhere((user) => user.account == account, orElse: () => throw ApiException('登录已失效', statusCode: 401));
  }

  String _tokenFor(UserProfile user) => 'token_${user.account}';

  @override
  Future<AuthSession> login({required String account, required String password}) async {
    final user = _users.firstWhere((item) => item.account == account, orElse: () => throw ApiException('账号或密码错误', statusCode: 401));
    if (password != 'password123') throw ApiException('账号或密码错误', statusCode: 401);
    return AuthSession(accessToken: _tokenFor(user), tokenType: 'Bearer', expiresIn: 7200, role: user.role, user: user);
  }

  @override
  Future<AuthSession> register({required String account, required String password, required String nickname}) async {
    if (account.isEmpty || password.isEmpty || nickname.isEmpty) throw ApiException('请完整填写注册信息', statusCode: 400);
    final user = UserProfile(id: 'user_${_users.length + 1}', nickname: nickname, account: account, bio: '这个人很神秘，什么都没留下。', coins: 0, role: UserRole.member);
    _users = [..._users, user];
    return AuthSession(accessToken: _tokenFor(user), tokenType: 'Bearer', expiresIn: 7200, role: user.role, user: user);
  }

  @override
  Future<UserProfile> getCurrentUser(String accessToken) async => _userFromToken(accessToken);
  @override
  Future<void> logout(String accessToken) async {}
  @override
  Future<List<VideoItem>> fetchRecommendations({String? accessToken}) async => _videos.where((item) => item.status == AuditStatus.approved).take(3).toList();

  @override
  Future<PagedResult<VideoItem>> fetchVideos({required int page, required int pageSize, String keyword = '', String? accessToken}) async {
    final source = _videos.where((item) => item.status == AuditStatus.approved).where((item) => keyword.isEmpty || item.title.contains(keyword) || item.ownerName.contains(keyword)).toList();
    final start = (page - 1) * pageSize;
    final end = (start + pageSize).clamp(0, source.length);
    return PagedResult(items: start >= source.length ? [] : source.sublist(start, end), page: page, pageSize: pageSize, totalItems: source.length);
  }

  @override
  Future<VideoItem> fetchVideoDetail(String videoId, {String? accessToken}) async {
    final user = accessToken == null ? null : _userFromToken(accessToken);
    final video = _videos.firstWhere((item) => item.id == videoId);
    return video.copyWith(isLiked: user != null && user.account == 'member' ? video.isLiked : video.isLiked, isFavorited: _favorites.contains(video.id));
  }

  @override
  Future<List<CommentNode>> fetchComments(String videoId, {String? accessToken}) async => List<CommentNode>.from(_comments[videoId] ?? const []);

  @override
  Future<void> toggleVideoLike(String videoId, {required String accessToken}) async {
    final user = _userFromToken(accessToken);
    if (user.isBanned) throw ApiException('当前账号已被封禁，暂时无法执行该操作', statusCode: 403);
    _videos = _videos.map((video) => video.id != videoId ? video : video.copyWith(isLiked: !video.isLiked, metrics: video.metrics.copyWith(likes: video.isLiked ? video.metrics.likes - 1 : video.metrics.likes + 1))).toList();
  }

  @override
  Future<void> toggleFavorite(String videoId, {required String accessToken}) async {
    final user = _userFromToken(accessToken);
    if (user.isBanned) throw ApiException('当前账号已被封禁，暂时无法执行该操作', statusCode: 403);
    if (_favorites.contains(videoId)) {
      _favorites.remove(videoId);
    } else {
      _favorites.add(videoId);
    }
    _videos = _videos.map((video) => video.id != videoId ? video : video.copyWith(isFavorited: _favorites.contains(videoId))).toList();
  }

  @override
  Future<void> giveCoin(String videoId, {required String accessToken}) async {
    final user = _userFromToken(accessToken);
    if (user.isBanned) throw ApiException('当前账号已被封禁，暂时无法执行该操作', statusCode: 403);
    final current = _users.firstWhere((item) => item.id == user.id);
    if (current.coins <= 0) throw ApiException('硬币不足，请先签到获取硬币', statusCode: 400);
    _users = _users.map((item) => item.id == user.id ? item.copyWith(coins: item.coins - 1) : item).toList();
    _videos = _videos.map((item) => item.id == videoId ? item.copyWith(metrics: item.metrics.copyWith(coins: item.metrics.coins + 1)) : item).toList();
  }

  @override
  Future<void> reportVideo(String videoId, {required String accessToken}) async {
    final user = _userFromToken(accessToken);
    if (user.isBanned) throw ApiException('当前账号已被封禁，暂时无法执行该操作', statusCode: 403);
    final video = _videos.firstWhere((item) => item.id == videoId);
    _reports = [ReportItem(id: 'report_${_reports.length + 1}', videoId: video.id, videoTitle: video.title, reporterName: user.nickname, reason: '用户发起举报，等待管理员处理', createdLabel: '刚刚', status: ReportStatus.pending), ..._reports];
  }

  @override
  Future<void> addComment({required String videoId, required String content, String? parentId, required String accessToken}) async {
    final user = _userFromToken(accessToken);
    if (user.isBanned) throw ApiException('当前账号已被封禁，暂时无法执行该操作', statusCode: 403);
    final item = CommentNode(id: 'comment_${DateTime.now().microsecondsSinceEpoch}', videoId: videoId, authorId: user.id, authorName: user.nickname, content: content, createdLabel: '刚刚', likeCount: 0, isLiked: false, replies: const []);
    _comments[videoId] = [item, ...(_comments[videoId] ?? const [])];
  }

  @override
  Future<void> toggleCommentLike(String commentId, {required String accessToken}) async {
    _userFromToken(accessToken);
    _comments = _comments.map((key, value) => MapEntry(key, value.map((item) => item.id == commentId ? item.copyWith(isLiked: !item.isLiked, likeCount: item.isLiked ? item.likeCount - 1 : item.likeCount + 1) : item).toList()));
  }

  @override
  Future<void> deleteComment(String commentId, {required String accessToken}) async {
    _userFromToken(accessToken);
    _comments = _comments.map((key, value) => MapEntry(key, value.where((item) => item.id != commentId).toList()));
  }

  @override
  Future<UserProfile> updateProfile({required String nickname, required String bio, required String accessToken}) async {
    final user = _userFromToken(accessToken);
    late UserProfile updated;
    _users = _users.map((item) { updated = item.id == user.id ? item.copyWith(nickname: nickname, bio: bio) : item; return item.id == user.id ? updated : item; }).toList();
    return updated;
  }

  @override
  Future<void> changePassword({required String currentPassword, required String nextPassword, required String accessToken}) async {
    _userFromToken(accessToken);
    if (nextPassword.length < 6) throw ApiException('新密码至少 6 位', statusCode: 400);
  }

  @override
  Future<void> performCheckIn(String accessToken) async {
    final user = _userFromToken(accessToken);
    _users = _users.map((item) => item.id == user.id ? item.copyWith(coins: item.coins + 5) : item).toList();
  }

  @override
  Future<void> publishVideo({required String title, required String description, required String category, required String accessToken}) async {
    final user = _userFromToken(accessToken);
    final video = _video('video_${_videos.length + 1}', title, description.isEmpty ? '新发布的视频内容' : description, user.id, user.nickname, '06:08', category.isEmpty ? '新投稿' : category, const Color(0xFF51624F), const VideoMetrics(likes: 0, favorites: 0, coins: 0, comments: 0, views: 0), AuditStatus.pending);
    _videos = [video, ..._videos];
    _audits = [AuditItem(id: 'audit_${_audits.length + 1}', videoId: video.id, videoTitle: video.title, uploaderName: user.nickname, submittedLabel: '刚刚', note: '用户提交的新视频，等待审核。', status: AuditStatus.pending), ..._audits];
  }

  @override
  Future<List<VideoItem>> fetchMyVideos(String accessToken) async {
    final user = _userFromToken(accessToken);
    return _videos.where((video) => video.ownerId == user.id).toList();
  }

  @override
  Future<List<VideoItem>> fetchHistoryVideos(String accessToken) async {
    _userFromToken(accessToken);
    return _history.map((id) => _videos.firstWhere((video) => video.id == id)).toList();
  }

  @override
  Future<List<VideoItem>> fetchFavoriteVideos(String accessToken) async {
    _userFromToken(accessToken);
    return _favorites.map((id) => _videos.firstWhere((video) => video.id == id)).toList();
  }

  @override
  Future<VideoStatsSummary> fetchMyStats(String accessToken) async {
    final user = _userFromToken(accessToken);
    final mine = _videos.where((video) => video.ownerId == user.id && video.status == AuditStatus.approved).toList();
    return VideoStatsSummary(videoCount: mine.length, totalLikes: mine.fold(0, (sum, item) => sum + item.metrics.likes), totalFavorites: mine.fold(0, (sum, item) => sum + item.metrics.favorites), totalCoins: mine.fold(0, (sum, item) => sum + item.metrics.coins), totalViews: mine.fold(0, (sum, item) => sum + item.metrics.views));
  }

  @override
  Future<AdminDashboardSummary> fetchAdminDashboard(String accessToken) async {
    final user = _userFromToken(accessToken);
    if (!user.isAdmin) throw ApiException('无管理员权限', statusCode: 403);
    return AdminDashboardSummary(pendingAudits: _audits.where((item) => item.status == AuditStatus.pending).length, pendingReports: _reports.where((item) => item.status == ReportStatus.pending).length, bannedUsers: _users.where((item) => item.isBanned).length, totalUsers: _users.length);
  }

  @override
  Future<List<AuditItem>> fetchAuditItems(String accessToken) async {
    final user = _userFromToken(accessToken);
    if (!user.isAdmin) throw ApiException('无管理员权限', statusCode: 403);
    return _audits;
  }

  @override
  Future<void> updateAuditStatus({required String auditId, required AuditStatus status, required String accessToken}) async {
    final user = _userFromToken(accessToken);
    if (!user.isAdmin) throw ApiException('无管理员权限', statusCode: 403);
    _audits = _audits.map((item) => item.id == auditId ? item.copyWith(status: status) : item).toList();
    final audit = _audits.firstWhere((item) => item.id == auditId);
    _videos = _videos.map((item) => item.id == audit.videoId ? item.copyWith(status: status) : item).toList();
  }

  @override
  Future<List<ReportItem>> fetchReportItems(String accessToken) async {
    final user = _userFromToken(accessToken);
    if (!user.isAdmin) throw ApiException('无管理员权限', statusCode: 403);
    return _reports;
  }

  @override
  Future<void> resolveReport({required String reportId, required String accessToken}) async {
    final user = _userFromToken(accessToken);
    if (!user.isAdmin) throw ApiException('无管理员权限', statusCode: 403);
    _reports = _reports.map((item) => item.id == reportId ? item.copyWith(status: ReportStatus.processed) : item).toList();
  }

  @override
  Future<List<UserProfile>> fetchUsers(String accessToken) async {
    final user = _userFromToken(accessToken);
    if (!user.isAdmin) throw ApiException('无管理员权限', statusCode: 403);
    return _users;
  }

  @override
  Future<void> toggleBanUser({required String userId, required String accessToken}) async {
    final user = _userFromToken(accessToken);
    if (!user.isAdmin) throw ApiException('无管理员权限', statusCode: 403);
    _users = _users.map((item) {
      if (item.id != userId) return item;
      final nextRole = item.isBanned ? UserRole.member : UserRole.banned;
      return item.copyWith(role: nextRole);
    }).toList();
  }

  @override
  Future<String> exportUsersCsv(String accessToken) async {
    final user = _userFromToken(accessToken);
    if (!user.isAdmin) throw ApiException('无管理员权限', statusCode: 403);
    final header = '昵称,账号,硬币数,角色';
    final rows = _users.map((item) => '${item.nickname},${item.account},${item.coins},${userRoleToJson(item.role)}').join('\n');
    return '$header\n$rows';
  }
}
