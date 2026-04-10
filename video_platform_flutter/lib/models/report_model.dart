class ReportModel {
  ReportModel({
    required this.id,
    this.userId,
    required this.videoId,
    required this.context,
    required this.status,
    required this.createDate,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) => ReportModel(
    id: json['id'] as int,
    userId: json['user_id'] as int?,
    videoId: json['video_id'] as int,
    context: json['context'] as String,
    status: json['status'] as String,
    createDate: DateTime.parse(json['create_date'] as String),
  );

  final int id;
  final int? userId;
  final int videoId;
  final String context;
  final String status; // 'reviewing' | 'pass' | 'reject'
  final DateTime createDate;
}
