import 'dart:convert';

class JwtPayload {
  JwtPayload({
    required this.userId,
    required this.nickname,
    required this.role,
  });

  factory JwtPayload.fromToken(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw const FormatException('Invalid JWT token');
    }

    final payload = parts[1];
    final normalized = base64.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));
    final json = jsonDecode(decoded) as Map<String, dynamic>;

    return JwtPayload(
      userId: (json['userId'] as num).toInt(),
      nickname: json['nickname'] as String? ?? '',
      role: json['role'] as String? ?? 'active',
    );
  }

  final int userId;
  final String nickname;
  final String role;
}
