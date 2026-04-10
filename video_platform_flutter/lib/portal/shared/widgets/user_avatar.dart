import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String? nickname;
  final double size;
  final int? userId;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    this.nickname,
    this.size = 32,
    this.userId,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tappable = userId != null && onTap != null;
    return InkWell(
      borderRadius: BorderRadius.circular(size / 2),
      onTap: tappable ? onTap : null,
      child: CircleAvatar(
        radius: size / 2,
        backgroundColor: tappable ? Colors.blue[200] : Colors.blue[100],
        child: Text(
          nickname?.substring(0, 1).toUpperCase() ?? 'U',
          style: TextStyle(fontSize: size * 0.4, color: Colors.blue[900]),
        ),
      ),
    );
  }
}
