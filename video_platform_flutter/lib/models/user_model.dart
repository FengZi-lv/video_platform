class UserModel {
  UserModel({
    required this.id,
    required this.account,
    required this.password,
    required this.nickname,
    required this.status,
    required this.bio,
    required this.coins,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: _readInt(json, 'id'),
    account: _readString(json, 'account'),
    password: _readString(json, 'password'),
    nickname: _readString(json, 'nickname'),
    status: _readString(json, 'status', fallback: 'active'),
    bio: _readString(json, 'bio'),
    coins: _readInt(json, 'coins'),
  );

  factory UserModel.fromApiJson(
    Map<String, dynamic> json, {
    String accountFallback = '',
    String roleFallback = 'active',
  }) {
    return UserModel(
      id: _readInt(json, 'id'),
      account: _readString(
        json,
        'account',
        aliases: const ['username', 'email'],
        fallback: accountFallback,
      ),
      password: '',
      nickname: _readString(
        json,
        'nickname',
        aliases: const ['username', 'display_name'],
        fallback: '未知用户',
      ),
      status: _readString(
        json,
        'status',
        aliases: const ['role'],
        fallback: roleFallback,
      ),
      bio: _readString(json, 'bio'),
      coins: _readInt(json, 'earn_coins', aliases: const ['coins']),
    );
  }

  final int id;
  final String account;
  final String password;
  final String nickname;
  final String status; // 'active' | 'ban' | 'admin'
  final String bio;
  final int coins;

  UserModel copyWith({
    int? id,
    String? account,
    String? password,
    String? nickname,
    String? status,
    String? bio,
    int? coins,
  }) {
    return UserModel(
      id: id ?? this.id,
      account: account ?? this.account,
      password: password ?? this.password,
      nickname: nickname ?? this.nickname,
      status: status ?? this.status,
      bio: bio ?? this.bio,
      coins: coins ?? this.coins,
    );
  }

  Map<String, dynamic> toStorageJson() => {
    'id': id,
    'account': account,
    'password': password,
    'nickname': nickname,
    'status': status,
    'bio': bio,
    'coins': coins,
  };

  static int _readInt(
    Map<String, dynamic> json,
    String key, {
    List<String> aliases = const [],
    int fallback = 0,
  }) {
    for (final candidate in [key, ...aliases]) {
      final value = json[candidate];
      if (value is num) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return fallback;
  }

  static String _readString(
    Map<String, dynamic> json,
    String key, {
    List<String> aliases = const [],
    String fallback = '',
  }) {
    for (final candidate in [key, ...aliases]) {
      final value = json[candidate];
      if (value is String && value.trim().isNotEmpty) {
        return value;
      }
    }
    return fallback;
  }
}
