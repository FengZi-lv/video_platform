class CheckInRecord {
  CheckInRecord({required this.id, required this.userId, required this.date});

  final int id;
  final int userId;
  final DateTime date; // check_in table
}

class VideoCoinRecord {
  VideoCoinRecord({
    required this.id,
    this.userId,
    required this.videoId,
    required this.createDate,
    required this.count,
  });

  final int id;
  final int? userId;
  final int videoId;
  final DateTime createDate;
  final int count; // number of coins given
}
