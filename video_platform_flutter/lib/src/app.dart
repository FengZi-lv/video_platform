import 'package:flutter/material.dart';

import 'controller/mock_app_controller.dart';
import 'theme/app_theme.dart';
import 'ui/app_shell.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final MockAppController controller;

  @override
  void initState() {
    super.initState();
    controller = MockAppController()..initializeFromUri(Uri.base);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return MaterialApp(
          title: '视界云播',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: AppShell(controller: controller),
        );
      },
    );
  }
}
