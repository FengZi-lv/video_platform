import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/models.dart';
import 'platform_api.dart';

class RemotePlatformApi implements PlatformApi {
  RemotePlatformApi({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final Uri baseUrl;
  final http.Client _client;

  Uri _uri(String path, [Map<String, dynamic>? queryParameters]) {
    final query = queryParameters?.map(
      (key, value) => MapEntry(key, value?.toString() ?? ''),
    );
    return baseUrl.replace(
      path: '${baseUrl.path}$path',
      queryParameters: query,
    );
  }

  Map<String, String> _headers({String? accessToken}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (accessToken != null && accessToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $accessToken';
    }
    return headers;
  }

  Future<Map<String, dynamic>> _jsonMap(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    String? accessToken,
  }) async {
    final response = await _send(
      method,
      path,
      body: body,
      queryParameters: queryParameters,
      accessToken: accessToken,
    );
    if (response.body.isEmpty) {
      return <String, dynamic>{};
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<dynamic>> _jsonList(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    String? accessToken,
  }) async {
    final response = await _send(
      method,
      path,
      body: body,
      queryParameters: queryParameters,
      accessToken: accessToken,
    );
    if (response.body.isEmpty) {
      return const [];
    }
    return jsonDecode(response.body) as List<dynamic>;
  }

  Future<http.Response> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    String? accessToken,
  }) async {
    final uri = _uri(path, queryParameters);
    late final http.Response response;
    switch (method) {
      case 'GET':
        response = await _client.get(
          uri,
          headers: _headers(accessToken: accessToken),
        );
        break;
      case 'POST':
        response = await _client.post(
          uri,
          headers: _headers(accessToken: accessToken),
          body: body == null ? null : jsonEncode(body),
        );
        break;
      case 'PUT':
        response = await _client.put(
          uri,
          headers: _headers(accessToken: accessToken),
          body: body == null ? null : jsonEncode(body),
        );
        break;
      case 'PATCH':
        response = await _client.patch(
          uri,
          headers: _headers(accessToken: accessToken),
          body: body == null ? null : jsonEncode(body),
        );
        break;
      case 'DELETE':
        response = await _client.delete(
          uri,
          headers: _headers(accessToken: accessToken),
          body: body == null ? null : jsonEncode(body),
        );
        break;
      default:
        throw ApiException('Unsupported method: $method');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = '请求失败';
      if (response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          message = (decoded['message'] ?? decoded['error'] ?? message) as String;
        }
      }
      throw ApiException(message, statusCode: response.statusCode);
    }
    return response;
  }

  @override
  Future<AuthSession> login({
    required String account,
    required String password,
  }) async {
    final json = await _jsonMap(
      'POST',
      '/api/auth/login',
      body: {'account': account, 'password': password},
    );
    return AuthSession.fromJson(json);
  }

  @override
  Future<AuthSession> register({
    required String account,
    required String password,
    required String nickname,
  }) async {
    final json = await _jsonMap(
      'POST',
      '/api/auth/register',
      body: {
        'account': account,
        'password': password,
        'nickname': nickname,
      },
    );
    return AuthSession.fromJson(json);
  }

  @override
  Future<UserProfile> getCurrentUser(String accessToken) async {
    final json = await _jsonMap('GET', '/api/auth/me', accessToken: accessToken);
    return UserProfile.fromJson(json);
  }

  @override
  Future<void> logout(String accessToken) async {
    await _send('POST', '/api/auth/logout', accessToken: accessToken);
  }

  @override
  Future<List<VideoItem>> fetchRecommendations({String? accessToken}) async {
    final list = await _jsonList(
      'GET',
      '/api/videos',
      accessToken: accessToken,
      queryParameters: {
        'page': 1,
        'pageSize': 4,
        'recommend': true,
      },
    );
    return list
        .map((item) => VideoItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<PagedResult<VideoItem>> fetchVideos({
    required int page,
    required int pageSize,
    String keyword = '',
    String? accessToken,
  }) async {
    final json = await _jsonMap(
      'GET',
      '/api/videos',
      accessToken: accessToken,
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (keyword.trim().isNotEmpty) 'keyword': keyword.trim(),
      },
    );
    final itemsJson = (json['items'] as List<dynamic>? ?? const []);
    return PagedResult<VideoItem>(
      items: itemsJson
          .map((item) => VideoItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      page: (json['page'] ?? page) as int,
      pageSize: (json['pageSize'] ?? pageSize) as int,
      totalItems: (json['totalItems'] ?? itemsJson.length) as int,
    );
  }

  @override
  Future<VideoItem> fetchVideoDetail(
    String videoId, {
    String? accessToken,
  }) async {
    final json = await _jsonMap(
      'GET',
      '/api/videos/$videoId',
      accessToken: accessToken,
    );
    return VideoItem.fromJson(json);
  }

  @override
  Future<List<CommentNode>> fetchComments(
    String videoId, {
    String? accessToken,
  }) async {
    final list = await _jsonList(
      'GET',
      '/api/videos/$videoId/comments',
      accessToken: accessToken,
    );
    return list
        .map((item) => CommentNode.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> toggleVideoLike(
    String videoId, {
    required String accessToken,
  }) async {
    await _send(
      'POST',
      '/api/videos/$videoId/like',
      accessToken: accessToken,
    );
  }

  @override
  Future<void> toggleFavorite(
    String videoId, {
    required String accessToken,
  }) async {
    await _send(
      'POST',
      '/api/videos/$videoId/favorite',
      accessToken: accessToken,
    );
  }

  @override
  Future<void> giveCoin(
    String videoId, {
    required String accessToken,
  }) async {
    await _send(
      'POST',
      '/api/videos/$videoId/coin',
      accessToken: accessToken,
    );
  }

  @override
  Future<void> reportVideo(
    String videoId, {
    required String accessToken,
  }) async {
    await _send(
      'POST',
      '/api/videos/$videoId/report',
      accessToken: accessToken,
      body: {'reason': '用户发起举报，等待管理员处理'},
    );
  }

  @override
  Future<void> addComment({
    required String videoId,
    required String content,
    String? parentId,
    required String accessToken,
  }) async {
    final requestBody = <String, dynamic>{
      'content': content,
      ...?parentId == null ? null : {'parentId': parentId},
    };
    await _send(
      'POST',
      '/api/videos/$videoId/comments',
      accessToken: accessToken,
      body: requestBody,
    );
  }

  @override
  Future<void> toggleCommentLike(
    String commentId, {
    required String accessToken,
  }) async {
    await _send(
      'POST',
      '/api/comments/$commentId/like',
      accessToken: accessToken,
    );
  }

  @override
  Future<void> deleteComment(
    String commentId, {
    required String accessToken,
  }) async {
    await _send(
      'DELETE',
      '/api/comments/$commentId',
      accessToken: accessToken,
    );
  }

  @override
  Future<UserProfile> updateProfile({
    required String nickname,
    required String bio,
    required String accessToken,
  }) async {
    final json = await _jsonMap(
      'PUT',
      '/api/users/me/profile',
      accessToken: accessToken,
      body: {'nickname': nickname, 'bio': bio},
    );
    return UserProfile.fromJson(json);
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String nextPassword,
    required String accessToken,
  }) async {
    await _send(
      'PUT',
      '/api/users/me/password',
      accessToken: accessToken,
      body: {
        'currentPassword': currentPassword,
        'nextPassword': nextPassword,
      },
    );
  }

  @override
  Future<void> performCheckIn(String accessToken) async {
    await _send('POST', '/api/users/me/check-in', accessToken: accessToken);
  }

  @override
  Future<void> publishVideo({
    required String title,
    required String description,
    required String category,
    required String accessToken,
  }) async {
    await _send(
      'POST',
      '/api/videos',
      accessToken: accessToken,
      body: {
        'title': title,
        'description': description,
        'category': category,
      },
    );
  }

  @override
  Future<List<VideoItem>> fetchMyVideos(String accessToken) async {
    final list = await _jsonList(
      'GET',
      '/api/users/me/videos',
      accessToken: accessToken,
    );
    return list
        .map((item) => VideoItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<VideoItem>> fetchHistoryVideos(String accessToken) async {
    final list = await _jsonList(
      'GET',
      '/api/users/me/history',
      accessToken: accessToken,
    );
    return list
        .map((item) => VideoItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<VideoItem>> fetchFavoriteVideos(String accessToken) async {
    final list = await _jsonList(
      'GET',
      '/api/users/me/favorites',
      accessToken: accessToken,
    );
    return list
        .map((item) => VideoItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<VideoStatsSummary> fetchMyStats(String accessToken) async {
    final json = await _jsonMap(
      'GET',
      '/api/users/me',
      accessToken: accessToken,
    );
    return VideoStatsSummary.fromJson(json['stats'] as Map<String, dynamic>);
  }

  @override
  Future<AdminDashboardSummary> fetchAdminDashboard(String accessToken) async {
    final json = await _jsonMap(
      'GET',
      '/api/admin/dashboard',
      accessToken: accessToken,
    );
    return AdminDashboardSummary.fromJson(json);
  }

  @override
  Future<List<AuditItem>> fetchAuditItems(String accessToken) async {
    final list = await _jsonList(
      'GET',
      '/api/admin/audits',
      accessToken: accessToken,
    );
    return list
        .map((item) => AuditItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> updateAuditStatus({
    required String auditId,
    required AuditStatus status,
    required String accessToken,
  }) async {
    await _send(
      'PATCH',
      '/api/admin/audits/$auditId',
      accessToken: accessToken,
      body: {'status': auditStatusToJson(status)},
    );
  }

  @override
  Future<List<ReportItem>> fetchReportItems(String accessToken) async {
    final list = await _jsonList(
      'GET',
      '/api/admin/reports',
      accessToken: accessToken,
    );
    return list
        .map((item) => ReportItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> resolveReport({
    required String reportId,
    required String accessToken,
  }) async {
    await _send(
      'PATCH',
      '/api/admin/reports/$reportId',
      accessToken: accessToken,
      body: {'status': 'processed'},
    );
  }

  @override
  Future<List<UserProfile>> fetchUsers(String accessToken) async {
    final list = await _jsonList(
      'GET',
      '/api/admin/users',
      accessToken: accessToken,
    );
    return list
        .map((item) => UserProfile.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> toggleBanUser({
    required String userId,
    required String accessToken,
  }) async {
    await _send(
      'PATCH',
      '/api/admin/users/$userId/ban',
      accessToken: accessToken,
    );
  }

  @override
  Future<String> exportUsersCsv(String accessToken) async {
    final response = await _send(
      'GET',
      '/api/admin/users/export',
      accessToken: accessToken,
    );
    return response.body;
  }
}
