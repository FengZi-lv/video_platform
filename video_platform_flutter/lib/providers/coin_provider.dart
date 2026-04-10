import 'package:flutter/material.dart';

import '../models/coin_record_model.dart';
import '../services/i_coin_service.dart';

class CoinProvider extends ChangeNotifier {
  CoinProvider(this._coinService);

  final ICoinService _coinService;

  bool _hasCheckedInToday = false;
  int _balance = 0;
  List<VideoCoinRecord> _records = [];
  List<String> _signInHistory = [];
  bool _loading = false;
  String? _error;

  bool get hasCheckedInToday => _hasCheckedInToday;
  int get balance => _balance;
  List<VideoCoinRecord> get records => _records;
  List<String> get signInHistory => _signInHistory;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> _checkInStatus(int userId) async {
    try {
      _signInHistory = await _coinService.getSignInHistory(userId);
      final today = DateTime.now();
      final todayKey =
          '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      _hasCheckedInToday = _signInHistory.contains(todayKey);
    } catch (e) {
      debugPrint('Failed to check check-in status: $e');
    }
  }

  Future<void> _loadBalance(int userId) async {
    try {
      _balance = await _coinService.getBalance(userId);
    } catch (e) {
      debugPrint('Failed to load balance: $e');
    }
  }

  Future<void> checkIn(int userId) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _coinService.checkIn(userId);
      await _checkInStatus(userId);
      await _loadBalance(userId);
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> getBalance(int userId) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _loadBalance(userId);
      await _checkInStatus(userId);
      _records = [];
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> getCoinRecords(int videoId) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _records = await _coinService.getCoinRecords(videoId);
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> coinVideo(int userId, int videoId, int count) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _coinService.coinVideo(userId, videoId, count);
      await _loadBalance(userId);
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }
}
