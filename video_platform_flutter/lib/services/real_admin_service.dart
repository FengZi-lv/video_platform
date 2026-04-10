import '../models/report_model.dart';
import '../models/user_model.dart';
import '../models/video_model.dart';
import 'api/api_client.dart';
import 'i_admin_service.dart';

class RealAdminService implements IAdminService {
  RealAdminService(this._client);

  final ApiClient _client;

  @override
  Future<List<VideoModel>> getPendingVideos() async {
    final json = await _client.getJson('/api/admin/videos/pending');
    final videos = json['videos'] as List<dynamic>? ?? const <dynamic>[];
    return videos.map((item) {
      final video = (item as Map).cast<String, dynamic>();
      return VideoModel.fromListJson(video, fallbackStatus: 'reviewing');
    }).toList();
  }

  @override
  Future<void> approveVideo(int videoId) async {
    await _reviewVideo(videoId, 'pass');
  }

  @override
  Future<void> rejectVideo(int videoId) async {
    await _reviewVideo(videoId, 'reject');
  }

  @override
  Future<List<ReportModel>> getReports() async {
    final json = await _client.getJson('/api/admin/reports');
    final reports = json['reports'] as List<dynamic>? ?? const <dynamic>[];
    return reports.map((item) {
      final report = (item as Map).cast<String, dynamic>();
      return ReportModel(
        id: (report['id'] as num).toInt(),
        userId: null,
        videoId: (report['video_id'] as num?)?.toInt() ?? 0,
        context: report['reason'] as String? ?? '',
        status: _mapReportStatus(report['status'] as String? ?? 'reviewing'),
        createDate: DateTime.now(),
      );
    }).toList();
  }

  @override
  Future<void> resolveReport(int reportId, bool passed) async {
    await _client.postJson(
      '/api/admin/reports/handle',
      body: {'report_id': reportId, 'action': passed ? 'pass' : 'reject'},
    );
  }

  @override
  Future<String> exportUsersCsv(List<UserModel> users) async {
    final lines = <String>[
      'id,nickname,status,coins,bio',
      ...users.map(
        (user) => [
          user.id,
          _escape(user.nickname),
          user.status,
          user.coins,
          _escape(user.bio),
        ].join(','),
      ),
    ];
    return lines.join('\n');
  }

  @override
  Future<void> reportVideo(int userId, int videoId, String reason) async {
    await _client.postJson(
      '/api/videos/report',
      body: {'video_id': videoId, 'reason': reason},
    );
  }

  Future<void> _reviewVideo(int videoId, String action) async {
    await _client.postJson(
      '/api/admin/videos/review',
      body: {'video_id': videoId, 'action': action},
    );
  }

  String _mapReportStatus(String status) {
    return switch (status) {
      'pending' => 'reviewing',
      'approve' => 'pass',
      _ => status,
    };
  }

  String _escape(String value) => '"${value.replaceAll('"', '""')}"';
}
