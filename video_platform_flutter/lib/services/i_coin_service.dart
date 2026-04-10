import '../models/coin_record_model.dart';

abstract class ICoinService {
  Future<void> checkIn(int userId);
  Future<bool> hasCheckedInToday(int userId);
  Future<List<String>> getSignInHistory(int userId);
  Future<int> getBalance(int userId);
  Future<List<VideoCoinRecord>> getCoinRecords(int videoId);
  Future<void> coinVideo(int userId, int videoId, int count);
}
