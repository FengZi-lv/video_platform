import 'package:flutter/material.dart';

import '../models/report_model.dart';
import '../models/user_model.dart';
import '../models/video_model.dart';
import '../services/i_admin_service.dart';

class AdminProvider extends ChangeNotifier {
  AdminProvider(this._adminService);

  final IAdminService _adminService;

  List<VideoModel> _pendingVideos = [];
  List<ReportModel> _reports = [];
  List<UserModel> _allUsers = [];
  bool _loading = false;
  String? _error;

  List<VideoModel> get pendingVideos => _pendingVideos;
  List<ReportModel> get reports => _reports;
  List<UserModel> get allUsers => _allUsers;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadPendingVideos() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _pendingVideos = await _adminService.getPendingVideos();
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> approveVideo(int videoId) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _adminService.approveVideo(videoId);
      _pendingVideos.removeWhere((v) => v.id == videoId);
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      rethrow;
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> rejectVideo(int videoId) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _adminService.rejectVideo(videoId);
      _pendingVideos.removeWhere((v) => v.id == videoId);
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      rethrow;
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> loadReports() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _reports = await _adminService.getReports();
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> resolveReport(int reportId, bool passed) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _adminService.resolveReport(reportId, passed);
      _reports.removeWhere((r) => r.id == reportId);
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  /// All users list. Populated by the caller since IAdminService
  /// does not expose getAllUsers — the export endpoint takes a user list as input.
  Future<void> getAllUsers() async {
    _loading = false;
    notifyListeners();
  }

  /// Update the cached user list (called from UserProvider or elsewhere)
  void setAllUsers(List<UserModel> users) {
    _allUsers = users;
    notifyListeners();
  }

  Future<String?> exportUsersCsv(List<UserModel> users) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final csv = await _adminService.exportUsersCsv(users);
      _loading = false;
      notifyListeners();
      return csv;
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> reportVideo(int userId, int videoId, String reason) {
    return _adminService.reportVideo(userId, videoId, reason);
  }
}
