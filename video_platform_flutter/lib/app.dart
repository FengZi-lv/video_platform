import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'providers/admin_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/coin_provider.dart';
import 'providers/comment_provider.dart';
import 'providers/user_provider.dart';
import 'providers/video_provider.dart';
import 'routes/router.dart';
import 'services/api/api_client.dart';
import 'services/api/api_config.dart';
import 'services/api/api_logger.dart';
import 'services/api/api_session.dart';
import 'services/real_admin_service.dart';
import 'services/real_auth_service.dart';
import 'services/real_coin_service.dart';
import 'services/real_comment_service.dart';
import 'services/real_user_service.dart';
import 'services/real_video_service.dart';

final GlobalKey<ScaffoldMessengerState> globalScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final ApiSession _session;
  late final ApiClient _client;
  late final RealAuthService _authService;
  late final AuthProvider _authProvider;
  late final RealVideoService _videoService;
  late final RealUserService _userService;
  late final RealCoinService _coinService;
  late final RealCommentService _commentService;
  late final RealAdminService _adminService;
  late final GoRouter _router;
  late final Future<void> _bootstrapFuture;
  var _bootstrapCompleted = false;

  @override
  void initState() {
    super.initState();
    _bootstrapFuture = _bootstrap();
  }

  Future<void> _bootstrap() async {
    _session = await ApiSession.create();
    _client = ApiClient(
      baseUrl: ApiConfig.baseUrl,
      tokenProvider: () => _session.token,
      logger: ApiLogger(),
    );
    _authService = RealAuthService(_client, _session);
    _authProvider = AuthProvider(_authService);
    _videoService = RealVideoService(_client);
    _userService = RealUserService(_client, _session);
    _coinService = RealCoinService(_client, _session);
    _commentService = RealCommentService(_client, _session);
    _adminService = RealAdminService(_client);
    _router = createAppRouter(_authProvider);
    await _authProvider.restoreSession();
    _bootstrapCompleted = true;
  }

  @override
  void dispose() {
    if (_bootstrapCompleted) {
      _authProvider.dispose();
      _authService.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _bootstrapFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return MaterialApp(
            scaffoldMessengerKey: globalScaffoldMessengerKey,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            debugShowCheckedModeBanner: false,
            home: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        return MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: _authProvider),
            ChangeNotifierProvider(create: (_) => VideoProvider(_videoService)),
            ChangeNotifierProvider(create: (_) => UserProvider(_userService)),
            ChangeNotifierProvider(create: (_) => CoinProvider(_coinService)),
            ChangeNotifierProvider(
              create: (_) => CommentProvider(_commentService),
            ),
            ChangeNotifierProvider(create: (_) => AdminProvider(_adminService)),
          ],
          child: MaterialApp.router(
            scaffoldMessengerKey: globalScaffoldMessengerKey,
            title: 'Video Platform',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            routerConfig: _router,
            debugShowCheckedModeBanner: false,
          ),
        );
      },
    );
  }
}
