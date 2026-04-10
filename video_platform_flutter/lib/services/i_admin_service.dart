import '../models/report_model.dart';
import '../models/user_model.dart';
import '../models/video_model.dart';

abstract class IAdminService {
  Future<List<VideoModel>> getPendingVideos();
  Future<void> approveVideo(int videoId);
  Future<void> rejectVideo(int videoId);
  Future<List<ReportModel>> getReports();
  Future<void> resolveReport(int reportId, bool passed);
  Future<String> exportUsersCsv(List<UserModel> users);
  Future<void> reportVideo(int userId, int videoId, String reason);
}
