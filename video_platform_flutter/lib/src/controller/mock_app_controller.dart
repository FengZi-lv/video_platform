import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/mock_seed.dart';
import '../models/models.dart';

class MockAppController extends ChangeNotifier {
  MockAppController()
      : _users = MockSeed.users(),
        _videos = MockSeed.videos(),
        _commentsByVideo = MockSeed.comments(),
        _auditItems = MockSeed.audits(),
        _reportItems = MockSeed.reports(),
        _historyIds = MockSeed.historyIds(),
        _favoriteIds = MockSeed.favoriteIds().toSet();

  final Random _random = Random();
  List<UserProfile> _users;
  List<VideoItem> _videos;
  Map<String, List<CommentNode>> _commentsByVideo;
  List<AuditItem> _auditItems;
  List<ReportItem> _reportItems;
  final List<String> _historyIds;
  final Set<String> _favoriteIds;

  DemoRole _role = DemoRole.guest;
  FrontSection _frontSection = FrontSection.home;
  AdminSection _adminSection = AdminSection.dashboard;
  String _currentPath = '/front/home';
  String _selectedVideoId = 'video_1';
  String _searchKeyword = '';
  int _searchPage = 1;
  int _recommendationSeed = 0;
  bool _checkedInToday = false;
  bool _adminAuthenticated = false;

  DemoRole get role => _role;
  FrontSection get frontSection => _frontSection;
  AdminSection get adminSection => _adminSection;
  String get currentPath => _currentPath;
  String get searchKeyword => _searchKeyword;
  int get searchPage => _searchPage;
  bool get checkedInToday => _checkedInToday;
  bool get isGuest => _role == DemoRole.guest;
  bool get isMember => _role == DemoRole.member;
  bool get isBanned => _role == DemoRole.banned;
  bool get isAdmin => _role == DemoRole.admin;
  bool get adminAuthenticated => _adminAuthenticated;

  UserProfile get currentUser =>
      _users.firstWhere((user) => user.isCurrentMember == true);

  List<UserProfile> get allUsers => List.unmodifiable(_users);

  List<VideoItem> get publishedVideos =>
      _videos.where((video) => video.status == AuditStatus.approved).toList();

  List<VideoItem> get recommendedVideos {
    final videos = List<VideoItem>.from(publishedVideos);
    if (videos.isEmpty) {
      return [];
    }
    final offset = _recommendationSeed % videos.length;
    return [...videos.skip(offset), ...videos.take(offset)];
  }

  PagedResult<VideoItem> get searchResult {
    final normalized = _searchKeyword.trim().toLowerCase();
    final source = normalized.isEmpty
        ? recommendedVideos
        : publishedVideos.where((video) {
            return video.title.toLowerCase().contains(normalized) ||
                video.description.toLowerCase().contains(normalized) ||
                video.ownerName.toLowerCase().contains(normalized);
          }).toList();
    const pageSize = 4;
    final total = source.length;
    final totalPages = (total / pageSize).ceil().clamp(1, 9999);
    final safePage = _searchPage.clamp(1, totalPages);
    final start = (safePage - 1) * pageSize;
    final end = min(start + pageSize, total);
    final items = start >= total ? <VideoItem>[] : source.sublist(start, end);
    return PagedResult<VideoItem>(
      items: items,
      page: safePage,
      pageSize: pageSize,
      totalItems: total,
    );
  }

  VideoItem get selectedVideo => _videos.firstWhere(
        (video) => video.id == _selectedVideoId,
        orElse: () => publishedVideos.first,
      );

  List<CommentNode> get selectedVideoComments =>
      List.unmodifiable(_commentsByVideo[_selectedVideoId] ?? const []);

  List<VideoItem> get myVideos =>
      _videos.where((video) => video.ownerId == currentUser.id).toList();

  List<VideoItem> get historyVideos => _historyIds
      .map((id) => _videos.where((video) => video.id == id))
      .where((matches) => matches.isNotEmpty)
      .map((matches) => matches.first)
      .toList();

  List<VideoItem> get favoriteVideos => _favoriteIds
      .map((id) => _videos.where((video) => video.id == id))
      .where((matches) => matches.isNotEmpty)
      .map((matches) => matches.first)
      .toList();

  VideoStatsSummary get stats {
    final mine = myVideos.where((video) => video.status == AuditStatus.approved);
    final list = mine.toList();
    return VideoStatsSummary(
      videoCount: list.length,
      totalLikes: list.fold(0, (sum, video) => sum + video.metrics.likes),
      totalFavorites:
          list.fold(0, (sum, video) => sum + video.metrics.favorites),
      totalCoins: list.fold(0, (sum, video) => sum + video.metrics.coins),
      totalViews: list.fold(0, (sum, video) => sum + video.metrics.views),
    );
  }

  List<AuditItem> get auditItems => List.unmodifiable(_auditItems);
  List<ReportItem> get reportItems => List.unmodifiable(_reportItems);

  String get adminSectionPath {
    switch (_adminSection) {
      case AdminSection.dashboard:
        return '/admin/dashboard';
      case AdminSection.reviews:
        return '/admin/reviews';
      case AdminSection.reports:
        return '/admin/reports';
      case AdminSection.users:
        return '/admin/users';
    }
  }

  VideoItem? findVideoById(String videoId) {
    for (final video in _videos) {
      if (video.id == videoId) {
        return video;
      }
    }
    return null;
  }

  void initializeFromUri(Uri uri) {
    final path = uri.path.isEmpty || uri.path == '/' ? '/front/home' : uri.path;
    navigate(path, updateBrowser: false);
  }

  void navigate(String path, {bool updateBrowser = true}) {
    if (path.startsWith('/admin')) {
      _currentPath = path == '/' ? '/admin/login' : path;
      if (_currentPath.contains('/reviews')) {
        _adminSection = AdminSection.reviews;
      } else if (_currentPath.contains('/reports')) {
        _adminSection = AdminSection.reports;
      } else if (_currentPath.contains('/users')) {
        _adminSection = AdminSection.users;
      } else {
        _adminSection = AdminSection.dashboard;
      }
    } else {
      _currentPath = path == '/' ? '/front/home' : path;
      if (path.startsWith('/front/profile')) {
        _frontSection = FrontSection.profile;
      } else {
        _frontSection = FrontSection.home;
      }
      if (path.startsWith('/front/video/')) {
        _selectedVideoId = path.split('/').last;
      }
    }

    if (updateBrowser) {
      SystemNavigator.routeInformationUpdated(uri: Uri.parse(_currentPath));
    }
    notifyListeners();
  }

  void setDemoRole(DemoRole role) {
    _role = role;
    if (role == DemoRole.admin) {
      _adminAuthenticated = false;
      navigate('/admin/login');
      return;
    }

    navigate(
      _frontSection == FrontSection.profile ? '/front/profile' : '/front/home',
    );
  }

  void setFrontSection(FrontSection section) {
    _frontSection = section;
    navigate(section == FrontSection.home ? '/front/home' : '/front/profile');
  }

  void setAdminSection(AdminSection section) {
    _adminSection = section;
    navigate(adminSectionPath);
  }

  void refreshRecommendations() {
    _recommendationSeed++;
    notifyListeners();
  }

  void updateSearchKeyword(String value) {
    _searchKeyword = value;
    _searchPage = 1;
    navigate('/front/home');
  }

  void jumpToSearchPage(int page) {
    _searchPage = page;
    notifyListeners();
  }

  void openVideo(String videoId) {
    _selectedVideoId = videoId;
    _insertHistory(videoId);
    navigate('/front/video/$videoId');
  }

  String? guardMemberAction() {
    if (isGuest) {
      return '该功能需要登录后使用';
    }
    if (isBanned) {
      return '当前账号已被封禁，暂时无法执行该操作';
    }
    return null;
  }

  String toggleVideoLike(String videoId) {
    final blocked = guardMemberAction();
    if (blocked != null) {
      return blocked;
    }
    _videos = _videos.map((video) {
      if (video.id != videoId) {
        return video;
      }
      final liked = !video.isLiked;
      return video.copyWith(
        isLiked: liked,
        metrics: video.metrics.copyWith(
          likes: liked ? video.metrics.likes + 1 : video.metrics.likes - 1,
        ),
      );
    }).toList();
    notifyListeners();
    return selectedVideo.isLiked ? '已点赞视频' : '已取消点赞';
  }

  String toggleFavorite(String videoId) {
    final blocked = guardMemberAction();
    if (blocked != null) {
      return blocked;
    }
    _videos = _videos.map((video) {
      if (video.id != videoId) {
        return video;
      }
      final favorited = !video.isFavorited;
      if (favorited) {
        _favoriteIds.add(videoId);
      } else {
        _favoriteIds.remove(videoId);
      }
      return video.copyWith(
        isFavorited: favorited,
        metrics: video.metrics.copyWith(
          favorites:
              favorited ? video.metrics.favorites + 1 : video.metrics.favorites - 1,
        ),
      );
    }).toList();
    notifyListeners();
    return _favoriteIds.contains(videoId) ? '已收藏视频' : '已取消收藏';
  }

  String giveCoin(String videoId) {
    final blocked = guardMemberAction();
    if (blocked != null) {
      return blocked;
    }
    if (currentUser.coins <= 0) {
      return '硬币不足，请先签到获取硬币';
    }
    _users = _users.map((user) {
      if (user.id != currentUser.id) {
        return user;
      }
      return user.copyWith(coins: user.coins - 1);
    }).toList();
    _videos = _videos.map((video) {
      if (video.id != videoId) {
        return video;
      }
      return video.copyWith(
        metrics: video.metrics.copyWith(coins: video.metrics.coins + 1),
      );
    }).toList();
    notifyListeners();
    return '投币成功';
  }

  String downloadVideo(String videoId) {
    final blocked = guardMemberAction();
    if (blocked != null) {
      return blocked;
    }
    return '已开始 mock 下载：$videoId';
  }

  String reportVideo(String videoId) {
    final blocked = guardMemberAction();
    if (blocked != null) {
      return blocked;
    }
    final video = _videos.firstWhere((item) => item.id == videoId);
    _reportItems = [
      ReportItem(
        id: 'report_${_reportItems.length + 1}',
        videoId: video.id,
        videoTitle: video.title,
        reporterName: currentUser.nickname,
        reason: '用户发起举报，等待管理员处理',
        createdLabel: '刚刚',
        status: ReportStatus.pending,
      ),
      ..._reportItems,
    ];
    notifyListeners();
    return '举报已提交';
  }

  String addComment(String videoId, String content, {String? parentId}) {
    final blocked = guardMemberAction();
    if (blocked != null) {
      return blocked;
    }
    final trimmed = content.trim();
    if (trimmed.isEmpty) {
      return '评论内容不能为空';
    }

    final newComment = CommentNode(
      id: 'comment_${DateTime.now().microsecondsSinceEpoch}',
      videoId: videoId,
      authorId: currentUser.id,
      authorName: currentUser.nickname,
      content: trimmed,
      createdLabel: '刚刚',
      likeCount: 0,
      isLiked: false,
      replies: const [],
    );

    final comments = List<CommentNode>.from(_commentsByVideo[videoId] ?? const []);
    final updated = parentId == null
        ? [newComment, ...comments]
        : comments.map((node) => _insertReply(node, parentId, newComment)).toList();
    _commentsByVideo = {..._commentsByVideo, videoId: updated};
    _bumpVideoCommentCount(videoId, 1);
    notifyListeners();
    return parentId == null ? '评论已发布' : '回复已发送';
  }

  String toggleCommentLike(String videoId, String commentId) {
    final blocked = guardMemberAction();
    if (blocked != null) {
      return blocked;
    }
    final list = _commentsByVideo[videoId] ?? const [];
    _commentsByVideo = {
      ..._commentsByVideo,
      videoId: list.map((node) => _toggleCommentLike(node, commentId)).toList(),
    };
    notifyListeners();
    return '评论点赞状态已更新';
  }

  String deleteComment(String videoId, String commentId) {
    final blocked = guardMemberAction();
    if (blocked != null) {
      return blocked;
    }
    final video = _videos.firstWhere((item) => item.id == videoId);
    final list = _commentsByVideo[videoId] ?? const [];
    final before = _countComments(list);
    final updated = list
        .where((node) => _canKeepComment(node, commentId, video))
        .map((node) => _removeComment(node, commentId, video))
        .whereType<CommentNode>()
        .toList();
    final after = _countComments(updated);
    _commentsByVideo = {..._commentsByVideo, videoId: updated};
    _bumpVideoCommentCount(videoId, after - before);
    notifyListeners();
    return '评论已删除';
  }

  bool canDeleteComment(CommentNode comment, VideoItem video) {
    if (!isMember) {
      return false;
    }
    return comment.authorId == currentUser.id || video.ownerId == currentUser.id;
  }

  String loginMember() {
    if (currentUser.isBanned) {
      _role = DemoRole.banned;
      navigate('/front/profile');
      return '该账号已被封禁';
    }
    _role = DemoRole.member;
    navigate('/front/profile');
    return '登录成功';
  }

  String registerMember() {
    _role = DemoRole.member;
    navigate('/front/profile');
    return '注册成功，已自动登录';
  }

  String logout() {
    _role = DemoRole.guest;
    navigate('/front/home');
    return '已退出登录';
  }

  String deleteAccount() {
    _role = DemoRole.guest;
    _users = _users.map((user) {
      if (user.id != currentUser.id) {
        return user;
      }
      return user.copyWith(
        nickname: '已注销用户',
        account: 'deleted_user',
        bio: '账号已注销',
        coins: 0,
      );
    }).toList();
    navigate('/front/home');
    return '账号已注销（mock）';
  }

  String updateProfile({required String nickname, required String bio}) {
    final blocked = guardMemberAction();
    if (blocked != null) {
      return blocked;
    }
    _users = _users.map((user) {
      if (user.id != currentUser.id) {
        return user;
      }
      return user.copyWith(nickname: nickname.trim(), bio: bio.trim());
    }).toList();
    notifyListeners();
    return '个人信息已更新';
  }

  String changePassword(String currentPassword, String nextPassword) {
    final blocked = guardMemberAction();
    if (blocked != null) {
      return blocked;
    }
    if (nextPassword.trim().length < 6) {
      return '新密码至少 6 位';
    }
    return '密码已更新（mock）';
  }

  String publishVideo({
    required String title,
    required String description,
    required String category,
  }) {
    final blocked = guardMemberAction();
    if (blocked != null) {
      return blocked;
    }
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      return '请填写视频标题';
    }
    final newVideo = VideoItem(
      id: 'video_${_videos.length + 1}',
      title: trimmedTitle,
      description:
          description.trim().isEmpty ? '新发布的 mock 视频' : description.trim(),
      ownerId: currentUser.id,
      ownerName: currentUser.nickname,
      duration: '06:0${_random.nextInt(9)}',
      uploadLabel: '刚刚',
      category: category.trim().isEmpty ? '新投稿' : category.trim(),
      coverColor: Colors.primaries[_videos.length % Colors.primaries.length],
      metrics: const VideoMetrics(
        likes: 0,
        favorites: 0,
        coins: 0,
        comments: 0,
        views: 0,
      ),
      isLiked: false,
      isFavorited: false,
      status: AuditStatus.pending,
    );
    _videos = [newVideo, ..._videos];
    _auditItems = [
      AuditItem(
        id: 'audit_${_auditItems.length + 1}',
        videoId: newVideo.id,
        videoTitle: newVideo.title,
        uploaderName: currentUser.nickname,
        submittedLabel: '刚刚',
        note: '用户提交的新视频，等待审核。',
        status: AuditStatus.pending,
      ),
      ..._auditItems,
    ];
    notifyListeners();
    return '视频已提交审核';
  }

  String performCheckIn() {
    final blocked = guardMemberAction();
    if (blocked != null) {
      return blocked;
    }
    if (_checkedInToday) {
      return '今天已经签到过了';
    }
    _checkedInToday = true;
    _users = _users.map((user) {
      if (user.id != currentUser.id) {
        return user;
      }
      return user.copyWith(coins: user.coins + 5);
    }).toList();
    notifyListeners();
    return '签到成功，获得 5 枚硬币';
  }

  String adminLogin() {
    _adminAuthenticated = true;
    _role = DemoRole.admin;
    _adminSection = AdminSection.dashboard;
    navigate(adminSectionPath);
    return '管理员登录成功';
  }

  String adminLogout() {
    _adminAuthenticated = false;
    _role = DemoRole.guest;
    navigate('/front/home');
    return '已退出管理端';
  }

  String updateAuditStatus(String auditId, AuditStatus status) {
    _auditItems = _auditItems.map((item) {
      if (item.id != auditId) {
        return item;
      }
      return item.copyWith(status: status);
    }).toList();

    final audit = _auditItems.firstWhere((item) => item.id == auditId);
    _videos = _videos.map((video) {
      if (video.id != audit.videoId) {
        return video;
      }
      return video.copyWith(status: status);
    }).toList();
    notifyListeners();
    return status == AuditStatus.approved ? '视频已通过审核' : '视频已驳回';
  }

  String resolveReport(String reportId) {
    _reportItems = _reportItems.map((item) {
      if (item.id != reportId) {
        return item;
      }
      return item.copyWith(status: ReportStatus.processed);
    }).toList();
    notifyListeners();
    return '举报已处理';
  }

  String toggleBanUser(String userId) {
    _users = _users.map((user) {
      if (user.id != userId) {
        return user;
      }
      return user.copyWith(isBanned: !user.isBanned);
    }).toList();

    if (currentUser.id == userId && _role == DemoRole.member && currentUser.isBanned) {
      _role = DemoRole.banned;
    } else if (currentUser.id == userId &&
        _role == DemoRole.banned &&
        !currentUser.isBanned) {
      _role = DemoRole.member;
    }
    notifyListeners();
    return currentUser.id == userId && currentUser.isBanned
        ? '账号已封禁'
        : '账号状态已更新';
  }

  String exportUsersCsv() {
    final header = '昵称,账号,硬币数,封禁状态';
    final rows = _users
        .map(
          (user) =>
              '${user.nickname},${user.account},${user.coins},${user.isBanned ? '已封禁' : '正常'}',
        )
        .join('\n');
    return '$header\n$rows';
  }

  void _insertHistory(String videoId) {
    _historyIds.remove(videoId);
    _historyIds.insert(0, videoId);
  }

  CommentNode _insertReply(
    CommentNode node,
    String parentId,
    CommentNode reply,
  ) {
    if (node.id == parentId) {
      return node.copyWith(replies: [...node.replies, reply]);
    }
    return node.copyWith(
      replies:
          node.replies.map((child) => _insertReply(child, parentId, reply)).toList(),
    );
  }

  CommentNode _toggleCommentLike(CommentNode node, String commentId) {
    if (node.id == commentId) {
      final liked = !node.isLiked;
      return node.copyWith(
        isLiked: liked,
        likeCount: liked ? node.likeCount + 1 : node.likeCount - 1,
      );
    }
    return node.copyWith(
      replies: node.replies
          .map((child) => _toggleCommentLike(child, commentId))
          .toList(),
    );
  }

  bool _canKeepComment(CommentNode node, String commentId, VideoItem video) {
    if (node.id != commentId) {
      return true;
    }
    return !canDeleteComment(node, video);
  }

  CommentNode? _removeComment(CommentNode node, String commentId, VideoItem video) {
    if (node.id == commentId && canDeleteComment(node, video)) {
      return null;
    }
    return node.copyWith(
      replies: node.replies
          .map((child) => _removeComment(child, commentId, video))
          .whereType<CommentNode>()
          .toList(),
    );
  }

  int _countComments(List<CommentNode> list) {
    return list.fold(0, (sum, node) => sum + 1 + _countComments(node.replies));
  }

  void _bumpVideoCommentCount(String videoId, int delta) {
    _videos = _videos.map((video) {
      if (video.id != videoId) {
        return video;
      }
      return video.copyWith(
        metrics: video.metrics.copyWith(
          comments: max(0, video.metrics.comments + delta),
        ),
      );
    }).toList();
  }
}
