import 'package:flutter/material.dart';

import '../controller/mock_app_controller.dart';
import '../models/models.dart';
import 'admin/admin_shell.dart';
import 'front/frontstage_shell.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.controller});

  final MockAppController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.currentPath.startsWith('/admin') || controller.isAdmin) {
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

String demoRoleLabel(DemoRole role) {
  switch (role) {
    case DemoRole.guest:
      return '游客';
    case DemoRole.member:
      return '客户端';
    case DemoRole.banned:
      return '封禁账号';
    case DemoRole.admin:
      return '管理端';
  }
}
