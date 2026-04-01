import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../api/platform_api.dart';
import '../models/models.dart';
import '../session/session_store.dart';

class AppController extends ChangeNotifier {
  AppController({
    required PlatformApi api,
    required SessionStore sessionStore,
  })  : _api = api,
        _sessionStore = sessionStore;

  final PlatformApi _api;
  final SessionStore _sessionStore;

  AuthSession? _session;
  FrontSection _frontSection = FrontSection.home;
  AdminSection _adminSection = AdminSection.dashboard;
  String _currentPath = '/front/home';
  String _selectedVideoId = '';
  String _searchKeyword = '';
  int _searchPage = 1;
  bool _bootstrapping = true;
  bool _homeLoading = false;
  bool _detailLoading = false;
  bool _profileLoading = false;
  bool _adminLoading = false;
  bool _adminLoginPending = false;
  String? _bootstrapError;
  String? _adminAccessError;

  List<VideoItem> _recommendations = const [];
  PagedResult<VideoItem> _searchResult =
      const PagedResult(items: [], page: 1, pageSize: 4, totalItems: 0);
  VideoItem? _selectedVideo;
  List<CommentNode> _selectedVideoComments = const [];
  List<VideoItem> _myVideos = const [];
  List<VideoItem> _historyVideos = const [];
  List<VideoItem> _favoriteVideos = const [];
  VideoStatsSummary _stats = const VideoStatsSummary.empty();
  AdminDashboardSummary _adminSummary = const AdminDashboardSummary.empty();
  List<AuditItem> _auditItems = const [];
  List<ReportItem> _reportItems = const [];
  List<UserProfile> _allUsers = const [];

  bool get bootstrapping => _bootstrapping;
  bool get homeLoading => _homeLoading;
  bool get detailLoading => _detailLoading;
  bool get profileLoading => _profileLoading;
  bool get adminLoading => _adminLoading;
  bool get adminLoginPending => _adminLoginPending;
  String? get bootstrapError => _bootstrapError;
  String? get adminAccessError => _adminAccessError;
  FrontSection get frontSection => _frontSection;
  AdminSection get adminSection => _adminSection;
  String get currentPath => _currentPath;
  String get searchKeyword => _searchKeyword;
  int get searchPage => _searchPage;
  UserProfile? get currentUser => _session?.user;
  bool get isAuthenticated => _session != null;
  bool get isGuest => !isAuthenticated;
  bool get isAdmin => currentUser?.isAdmin ?? false;
  bool get isBanned => currentUser?.isBanned ?? false;
  String? get accessToken => _session?.accessToken;
  List<VideoItem> get recommendations => _recommendations;
  PagedResult<VideoItem> get searchResult => _searchResult;
  VideoItem? get selectedVideo => _selectedVideo;
  List<CommentNode> get selectedVideoComments => _selectedVideoComments;
  List<VideoItem> get myVideos => _myVideos;
  List<VideoItem> get historyVideos => _historyVideos;
  List<VideoItem> get favoriteVideos => _favoriteVideos;
  VideoStatsSummary get stats => _stats;
  AdminDashboardSummary get adminSummary => _adminSummary;
  List<AuditItem> get auditItems => _auditItems;
  List<ReportItem> get reportItems => _reportItems;
  List<UserProfile> get allUsers => _allUsers;

  Future<void> initializeFromUri(Uri uri) async {
    _applyPath(_normalizePath(uri.path));
    notifyListeners();

    try {
      final token = await _sessionStore.readAccessToken();
      if (token != null && token.isNotEmpty) {
        await _restoreSession(token);
      }
      await _loadCurrentRoute();
    } catch (error) {
      _bootstrapError = _messageFromError(error);
    } finally {
      _bootstrapping = false;
      notifyListeners();
    }
  }

  Future<void> navigate(String path, {bool updateBrowser = true}) async {
    _bootstrapError = null;
    _applyPath(_normalizePath(path));
    if (updateBrowser) {
      SystemNavigator.routeInformationUpdated(uri: Uri.parse(_currentPath));
    }
    notifyListeners();
    await _loadCurrentRoute();
  }

  Future<void> refreshHome() async {
    await _loadHome();
  }

  Future<void> updateSearchKeyword(String value) async {
    _searchKeyword = value.trim();
    _searchPage = 1;
    await navigate('/front/home');
  }

  Future<void> jumpToSearchPage(int page) async {
    _searchPage = page;
    await _loadHome();
  }

  Future<void> openVideo(String videoId) async {
    _selectedVideoId = videoId;
    await navigate('/front/video/$videoId');
  }

  Future<String> login({
    required String account,
    required String password,
    bool adminLogin = false,
  }) async {
    final trimmedAccount = account.trim();
    final trimmedPassword = password.trim();
    if (trimmedAccount.isEmpty || trimmedPassword.isEmpty) {
      return '请输入账号和密码';
    }

    if (adminLogin) {
      _adminLoginPending = true;
      notifyListeners();
    }

    try {
      final session = await _api.login(
        account: trimmedAccount,
        password: trimmedPassword,
      );
      if (adminLogin && session.role != UserRole.admin) {
        return '当前账号不是管理员';
      }
      await _saveSession(session);
      if (adminLogin) {
        await navigate('/admin/dashboard');
        return '管理员登录成功';
      }
      await navigate('/front/profile');
      return '登录成功';
    } on ApiException catch (error) {
      return error.message;
    } finally {
      _adminLoginPending = false;
      notifyListeners();
    }
  }

  Future<String> register({
    required String account,
    required String password,
    required String nickname,
  }) async {
    final trimmedAccount = account.trim();
    final trimmedPassword = password.trim();
    final trimmedNickname = nickname.trim();
    if (trimmedAccount.isEmpty || trimmedPassword.isEmpty || trimmedNickname.isEmpty) {
      return '请完整填写注册信息';
    }
    try {
      final session = await _api.register(
        account: trimmedAccount,
        password: trimmedPassword,
        nickname: trimmedNickname,
      );
      await _saveSession(session);
      await navigate('/front/profile');
      return '注册成功';
    } on ApiException catch (error) {
      return error.message;
    }
  }

  Future<String> logout() async {
    final token = accessToken;
    if (token != null) {
      try {
        await _api.logout(token);
      } catch (_) {
        // Ignore logout transport failures and clear the local session anyway.
      }
    }
    await _clearSession();
    await navigate('/front/home');
    return '已退出登录';
  }

  Future<String> updateProfile({
    required String nickname,
    required String bio,
  }) async {
    final blocked = _guardMemberAction();
    if (blocked != null) {
      return blocked;
    }
    try {
      final updated = await _api.updateProfile(
        nickname: nickname.trim(),
        bio: bio.trim(),
        accessToken: accessToken!,
      );
      _session = AuthSession(
        accessToken: _session!.accessToken,
        tokenType: _session!.tokenType,
        expiresIn: _session!.expiresIn,
        role: updated.role,
        user: updated,
      );
      await _loadProfile();
      notifyListeners();
      return '个人信息已更新';
    } on ApiException catch (error) {
      return error.message;
    }
  }

  Future<String> changePassword(String currentPassword, String nextPassword) async {
    final blocked = _guardMemberAction();
    if (blocked != null) {
      return blocked;
    }
    if (nextPassword.trim().length < 6) {
      return '新密码至少 6 位';
    }
    try {
      await _api.changePassword(
        currentPassword: currentPassword,
        nextPassword: nextPassword,
        accessToken: accessToken!,
      );
      return '密码已更新';
    } on ApiException catch (error) {
      return error.message;
    }
  }

  Future<String> performCheckIn() async {
    final blocked = _guardMemberAction();
    if (blocked != null) {
      return blocked;
    }
    try {
      await _api.performCheckIn(accessToken!);
      await _refreshUser();
      await _loadProfile();
      return '签到成功';
    } on ApiException catch (error) {
      return error.message;
    }
  }

  Future<String> publishVideo({
    required String title,
    required String description,
    required String category,
  }) async {
    final blocked = _guardMemberAction();
    if (blocked != null) {
      return blocked;
    }
    if (title.trim().isEmpty) {
      return '请填写视频标题';
    }
    try {
      await _api.publishVideo(
        title: title.trim(),
        description: description.trim(),
        category: category.trim(),
        accessToken: accessToken!,
      );
      await _loadProfile();
      return '视频已提交审核';
    } on ApiException catch (error) {
      return error.message;
    }
  }

  Future<String> toggleVideoLike(String videoId) async {
    final blocked = _guardMemberAction();
    if (blocked != null) {
      return blocked;
    }
    try {
      await _api.toggleVideoLike(videoId, accessToken: accessToken!);
      await _loadVideoDetail(videoId);
      return '点赞状态已更新';
    } on ApiException catch (error) {
      return error.message;
    }
  }

  Future<String> toggleFavorite(String videoId) async {
    final blocked = _guardMemberAction();
    if (blocked != null) {
      return blocked;
    }
    try {
      await _api.toggleFavorite(videoId, accessToken: accessToken!);
      await _loadVideoDetail(videoId);
      await _loadProfile();
      return '收藏状态已更新';
    } on ApiException catch (error) {
      return error.message;
    }
  }

  Future<String> giveCoin(String videoId) async {
    final blocked = _guardMemberAction();
    if (blocked != null) {
      return blocked;
    }
    try {
      await _api.giveCoin(videoId, accessToken: accessToken!);
      await _refreshUser();
      await _loadVideoDetail(videoId);
      return '投币成功';
    } on ApiException catch (error) {
      return error.message;
    }
  }

  Future<String> reportVideo(String videoId) async {
    final blocked = _guardMemberAction();
    if (blocked != null) {
      return blocked;
    }
    try {
      await _api.reportVideo(videoId, accessToken: accessToken!);
      return '举报已提交';
    } on ApiException catch (error) {
      return error.message;
    }
  }

  Future<String> addComment(
    String videoId,
    String content, {
    String? parentId,
  }) async {
    final blocked = _guardMemberAction();
    if (blocked != null) {
      return blocked;
    }
    if (content.trim().isEmpty) {
      return '评论内容不能为空';
    }
    try {
      await _api.addComment(
        videoId: videoId,
        content: content.trim(),
        parentId: parentId,
        accessToken: accessToken!,
      );
      await _loadVideoDetail(videoId);
      return parentId == null ? '评论已发布' : '回复已发送';
    } on ApiException catch (error) {
      return error.message;
    }
  }

  Future<String> toggleCommentLike(String commentId) async {
    final blocked = _guardMemberAction();
    if (blocked != null) {
      return blocked;
    }
    if (_selectedVideo == null) {
      return '当前视频不存在';
    }
    try {
      await _api.toggleCommentLike(commentId, accessToken: accessToken!);
      await _loadVideoDetail(_selectedVideo!.id);
      return '评论点赞状态已更新';
    } on ApiException catch (error) {
      return error.message;
    }
  }

  Future<String> deleteComment(String commentId) async {
    final blocked = _guardMemberAction();
    if (blocked != null) {
      return blocked;
    }
    if (_selectedVideo == null) {
      return '当前视频不存在';
    }
    try {
      await _api.deleteComment(commentId, accessToken: accessToken!);
      await _loadVideoDetail(_selectedVideo!.id);
      return '评论已删除';
    } on ApiException catch (error) {
      return error.message;
    }
  }

  bool canDeleteComment(CommentNode comment, VideoItem video) {
    final user = currentUser;
    if (user == null || user.role == UserRole.guest || user.role == UserRole.banned) {
      return false;
    }
    return comment.authorId == user.id || video.ownerId == user.id || user.isAdmin;
  }

  Future<String> updateAuditStatus(String auditId, AuditStatus status) async {
    if (!isAdmin) {
      return '无管理员权限';
    }
    try {
      await _api.updateAuditStatus(
        auditId: auditId,
        status: status,
        accessToken: accessToken!,
      );
      await _loadAdmin();
      return status == AuditStatus.approved ? '视频已通过审核' : '视频已驳回';
    } on ApiException catch (error) {
      return error.message;
    }
  }

  Future<String> resolveReport(String reportId) async {
    if (!isAdmin) {
      return '无管理员权限';
    }
    try {
      await _api.resolveReport(reportId: reportId, accessToken: accessToken!);
      await _loadAdmin();
      return '举报已处理';
    } on ApiException catch (error) {
      return error.message;
    }
  }

  Future<String> toggleBanUser(String userId) async {
    if (!isAdmin) {
      return '无管理员权限';
    }
    try {
      await _api.toggleBanUser(userId: userId, accessToken: accessToken!);
      await _loadAdmin();
      return '账号状态已更新';
    } on ApiException catch (error) {
      return error.message;
    }
  }

  Future<String> exportUsersCsv() async {
    if (!isAdmin) {
      return '无管理员权限';
    }
    try {
      return await _api.exportUsersCsv(accessToken!);
    } on ApiException catch (error) {
      return error.message;
    }
  }

  String? _guardMemberAction() {
    if (isGuest) {
      return '该功能需要登录后使用';
    }
    if (isBanned) {
      return '当前账号已被封禁，暂时无法执行该操作';
    }
    return null;
  }

  Future<void> _loadCurrentRoute() async {
    if (_currentPath.startsWith('/admin')) {
      if (!isAuthenticated) {
        _adminAccessError = null;
        notifyListeners();
        return;
      }
      if (!isAdmin) {
        _adminAccessError = '当前账号没有管理员权限';
        notifyListeners();
        return;
      }
      _adminAccessError = null;
      await _loadAdmin();
      return;
    }

    _adminAccessError = null;
    if (_currentPath.startsWith('/front/video/')) {
      await _loadVideoDetail(_selectedVideoId);
      return;
    }
    if (_frontSection == FrontSection.profile) {
      await _loadProfile();
      return;
    }
    await _loadHome();
  }

  Future<void> _loadHome() async {
    _homeLoading = true;
    notifyListeners();
    try {
      _recommendations =
          await _api.fetchRecommendations(accessToken: accessToken);
      _searchResult = await _api.fetchVideos(
        page: _searchPage,
        pageSize: 4,
        keyword: _searchKeyword,
        accessToken: accessToken,
      );
      _bootstrapError = null;
    } catch (error) {
      _bootstrapError = _messageFromError(error);
      _recommendations = const [];
      _searchResult =
          const PagedResult(items: [], page: 1, pageSize: 4, totalItems: 0);
    } finally {
      _homeLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadVideoDetail(String videoId) async {
    if (videoId.isEmpty) {
      return;
    }
    _detailLoading = true;
    notifyListeners();
    try {
      _selectedVideo = await _api.fetchVideoDetail(
        videoId,
        accessToken: accessToken,
      );
      _selectedVideoComments = await _api.fetchComments(
        videoId,
        accessToken: accessToken,
      );
      _bootstrapError = null;
    } catch (error) {
      _bootstrapError = _messageFromError(error);
      _selectedVideo = null;
      _selectedVideoComments = const [];
    } finally {
      _detailLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadProfile() async {
    if (!isAuthenticated) {
      _profileLoading = false;
      notifyListeners();
      return;
    }

    _profileLoading = true;
    notifyListeners();
    try {
      await _refreshUser();
      final token = accessToken!;
      _myVideos = await _api.fetchMyVideos(token);
      _historyVideos = await _api.fetchHistoryVideos(token);
      _favoriteVideos = await _api.fetchFavoriteVideos(token);
      _stats = await _api.fetchMyStats(token);
      _bootstrapError = null;
    } catch (error) {
      _bootstrapError = _messageFromError(error);
      _myVideos = const [];
      _historyVideos = const [];
      _favoriteVideos = const [];
      _stats = const VideoStatsSummary.empty();
    } finally {
      _profileLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadAdmin() async {
    _adminLoading = true;
    notifyListeners();
    try {
      final token = accessToken!;
      _adminSummary = await _api.fetchAdminDashboard(token);
      _auditItems = await _api.fetchAuditItems(token);
      _reportItems = await _api.fetchReportItems(token);
      _allUsers = await _api.fetchUsers(token);
      _bootstrapError = null;
    } catch (error) {
      _bootstrapError = _messageFromError(error);
      _adminSummary = const AdminDashboardSummary.empty();
      _auditItems = const [];
      _reportItems = const [];
      _allUsers = const [];
    } finally {
      _adminLoading = false;
      notifyListeners();
    }
  }

  Future<void> _restoreSession(String token) async {
    try {
      final user = await _api.getCurrentUser(token);
      _session = AuthSession(
        accessToken: token,
        tokenType: 'Bearer',
        expiresIn: 7200,
        role: user.role,
        user: user,
      );
    } on ApiException {
      await _clearSession();
    }
  }

  Future<void> _refreshUser() async {
    final token = accessToken;
    if (token == null) {
      return;
    }
    final user = await _api.getCurrentUser(token);
    _session = AuthSession(
      accessToken: token,
      tokenType: _session?.tokenType ?? 'Bearer',
      expiresIn: _session?.expiresIn ?? 7200,
      role: user.role,
      user: user,
    );
  }

  Future<void> _saveSession(AuthSession session) async {
    _session = session;
    await _sessionStore.writeAccessToken(session.accessToken);
    notifyListeners();
  }

  Future<void> _clearSession() async {
    _session = null;
    _myVideos = const [];
    _historyVideos = const [];
    _favoriteVideos = const [];
    _stats = const VideoStatsSummary.empty();
    _adminSummary = const AdminDashboardSummary.empty();
    _auditItems = const [];
    _reportItems = const [];
    _allUsers = const [];
    await _sessionStore.clear();
    notifyListeners();
  }

  void _applyPath(String path) {
    _currentPath = path;
    if (path.startsWith('/admin')) {
      if (path.contains('/reviews')) {
        _adminSection = AdminSection.reviews;
      } else if (path.contains('/reports')) {
        _adminSection = AdminSection.reports;
      } else if (path.contains('/users')) {
        _adminSection = AdminSection.users;
      } else {
        _adminSection = AdminSection.dashboard;
      }
      return;
    }

    if (path.startsWith('/front/profile')) {
      _frontSection = FrontSection.profile;
    } else {
      _frontSection = FrontSection.home;
    }
    if (path.startsWith('/front/video/')) {
      _selectedVideoId = path.split('/').last;
    }
  }

  String _normalizePath(String path) {
    if (path.isEmpty || path == '/') {
      return '/front/home';
    }
    return path;
  }

  String _messageFromError(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    return '请求失败，请稍后重试';
  }
}
