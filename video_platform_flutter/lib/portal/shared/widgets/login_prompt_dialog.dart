import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../routes/app_routes.dart';

class LoginPromptDialog extends StatelessWidget {
  const LoginPromptDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.lock_outline, size: 48, color: Colors.grey),
      title: const Text('需要登录'),
      content: const Text('请先登录以使用此功能'),
      actions: [
        TextButton(onPressed: () => context.pop(), child: const Text('取消')),
        ElevatedButton(
          onPressed: () {
            context.pop();
            context.go(AppRoutes.login);
          },
          child: const Text('去登录'),
        ),
      ],
    );
  }
}
