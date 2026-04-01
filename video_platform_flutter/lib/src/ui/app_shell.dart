import 'package:flutter/material.dart';

import '../controller/app_controller.dart';
import '../models/models.dart';
import 'admin/admin_shell.dart';
import 'front/frontstage_shell.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.bootstrapping) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (controller.currentPath.startsWith('/admin')) {
      return AdminShell(controller: controller);
    }
    return FrontstageShell(controller: controller);
  }
}

void showFeedback(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

String userRoleLabel(UserRole role) {
  switch (role) {
    case UserRole.guest:
      return '游客';
    case UserRole.member:
      return '普通用户';
    case UserRole.banned:
      return '封禁账号';
    case UserRole.admin:
      return '管理员';
  }
}
