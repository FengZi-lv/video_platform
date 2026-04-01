import 'package:flutter/material.dart';

import 'api/platform_api.dart';
import 'api/remote_platform_api.dart';
import 'controller/app_controller.dart';
import 'session/session_store.dart';
import 'session/shared_preferences_session_store.dart';
import 'theme/app_theme.dart';
import 'ui/app_shell.dart';

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    this.api,
    this.sessionStore,
    this.initialUri,
  });

  final PlatformApi? api;
  final SessionStore? sessionStore;
  final Uri? initialUri;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppController controller;

  @override
  void initState() {
    super.initState();
    controller = AppController(
      api: widget.api ??
          RemotePlatformApi(
            baseUrl: Uri.parse(
              const String.fromEnvironment(
                'API_BASE_URL',
                defaultValue: 'http://localhost:8080',
              ),
            ),
          ),
      sessionStore: widget.sessionStore ?? SharedPreferencesSessionStore(),
    )..initializeFromUri(widget.initialUri ?? Uri.base);
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
