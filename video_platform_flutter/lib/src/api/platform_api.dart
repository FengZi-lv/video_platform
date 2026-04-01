import '../models/models.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

abstract class PlatformApi {
  Future<AuthSession> login({
    required String account,
    required String password,
  });

  Future<AuthSession> register({
    required String account,
    required String password,
    required String nickname,
  });

  Future<UserProfile> getCurrentUser(String accessToken);

  Future<void> logout(String accessToken);

  Future<List<VideoItem>> fetchRecommendations({
    String? accessToken,
  });

  Future<PagedResult<VideoItem>> fetchVideos({
    required int page,
    required int pageSize,
    String keyword = '',
    String? accessToken,
  });

  Future<VideoItem> fetchVideoDetail(
    String videoId, {
    String? accessToken,
  });

  Future<List<CommentNode>> fetchComments(
    String videoId, {
    String? accessToken,
  });

  Future<void> toggleVideoLike(
    String videoId, {
    required String accessToken,
  });

  Future<void> toggleFavorite(
    String videoId, {
    required String accessToken,
  });

  Future<void> giveCoin(
    String videoId, {
    required String accessToken,
  });

  Future<void> reportVideo(
    String videoId, {
    required String accessToken,
  });

  Future<void> addComment({
    required String videoId,
    required String content,
    String? parentId,
    required String accessToken,
  });

  Future<void> toggleCommentLike(
    String commentId, {
    required String accessToken,
  });

  Future<void> deleteComment(
    String commentId, {
    required String accessToken,
  });

  Future<UserProfile> updateProfile({
    required String nickname,
    required String bio,
    required String accessToken,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String nextPassword,
    required String accessToken,
  });

  Future<void> performCheckIn(String accessToken);

  Future<void> publishVideo({
    required String title,
    required String description,
    required String category,
    required String accessToken,
  });

  Future<List<VideoItem>> fetchMyVideos(String accessToken);

  Future<List<VideoItem>> fetchHistoryVideos(String accessToken);

  Future<List<VideoItem>> fetchFavoriteVideos(String accessToken);

  Future<VideoStatsSummary> fetchMyStats(String accessToken);

  Future<AdminDashboardSummary> fetchAdminDashboard(String accessToken);

  Future<List<AuditItem>> fetchAuditItems(String accessToken);

  Future<void> updateAuditStatus({
    required String auditId,
    required AuditStatus status,
    required String accessToken,
  });

  Future<List<ReportItem>> fetchReportItems(String accessToken);

  Future<void> resolveReport({
    required String reportId,
    required String accessToken,
  });

  Future<List<UserProfile>> fetchUsers(String accessToken);

  Future<void> toggleBanUser({
    required String userId,
    required String accessToken,
  });

  Future<String> exportUsersCsv(String accessToken);
}
