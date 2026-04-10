import '../models/coin_record_model.dart';
import 'api/api_client.dart';
import 'api/api_session.dart';
import 'i_coin_service.dart';

class RealCoinService implements ICoinService {
  RealCoinService(this._client, this._session);

  final ApiClient _client;
  final ApiSession _session;

  @override
  Future<void> checkIn(int userId) async {
    await _client.postJson('/api/users/sign-in');
    final current = _session.currentUser;
    if (current != null) {
      await _session.updateCurrentUser(
        current.copyWith(coins: current.coins + 10),
      );
    }
  }

  @override
  Future<bool> hasCheckedInToday(int userId) async {
    final records = await getSignInHistory(userId);
    final today = DateTime.now();
    final todayKey =
        '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return records.contains(todayKey);
  }

  @override
  Future<List<String>> getSignInHistory(int userId) async {
    final json = await _client.getJson('/api/users/sign-in/history');
    final records = (json['records'] as List<dynamic>? ?? const <dynamic>[])
        .cast<String>();
    return records;
  }

  @override
  Future<int> getBalance(int userId) async {
    final json = await _client.getJson('/api/users/$userId');
    final coins = (json['earn_coins'] as num?)?.toInt() ?? 0;
    final current = _session.currentUser;
    if (current != null && current.id == userId) {
      await _session.updateCurrentUser(current.copyWith(coins: coins));
    }
    return coins;
  }

  @override
  Future<List<VideoCoinRecord>> getCoinRecords(int videoId) async {
    return const <VideoCoinRecord>[];
  }

  @override
  Future<void> coinVideo(int userId, int videoId, int count) async {
    await _client.postJson(
      '/api/videos/coin',
      body: {'video_id': videoId, 'coins': count},
    );
    final current = _session.currentUser;
    if (current != null && current.id == userId) {
      await _session.updateCurrentUser(
        current.copyWith(coins: (current.coins - count).clamp(0, 1 << 31)),
      );
    }
  }
}
