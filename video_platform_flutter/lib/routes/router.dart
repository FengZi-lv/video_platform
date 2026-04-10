import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import 'app_routes.dart';

// Portal pages
import '../portal/auth/login_page.dart';
import '../portal/auth/register_page.dart';
import '../portal/guest_client/home_page.dart';
import '../portal/guest_client/video_detail_page.dart';
import '../portal/guest_client/history_page.dart';
import '../portal/guest_client/favorites_page.dart';
import '../portal/guest_client/coins_page.dart';
import '../portal/guest_client/stats_page.dart';
import '../portal/guest_client/publish_page.dart';
import '../portal/guest_client/my_videos_page.dart';
import '../portal/guest_client/profile_page.dart';
import '../portal/guest_client/user_home_page.dart';
import '../portal/shared/widgets/portal_scaffold.dart';

// Admin pages
import '../portal/admin/admin_dashboard_page.dart';
import '../portal/admin/video_review_page.dart';
import '../portal/admin/ban_user_page.dart';
import '../portal/admin/report_review_page.dart';
import '../portal/admin/users_page.dart';
import '../portal/shared/widgets/admin_scaffold.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Navigator key for the portal shell — accessible by PortalScaffold for back navigation
final GlobalKey<NavigatorState> portalNavigatorKey =
    GlobalKey<NavigatorState>();

/// Navigator key for the admin shell — accessible by AdminScaffold for back navigation
final GlobalKey<NavigatorState> adminNavigatorKey = GlobalKey<NavigatorState>();

Widget _portalShell(BuildContext context, GoRouterState state, Widget child) {
  return PortalScaffold(child: child);
}

Widget _adminShell(BuildContext context, GoRouterState state, Widget child) {
  return AdminScaffold(child: child);
}

String _currentLocation(GoRouterState state) => state.uri.path;

bool _isProtectedPortalRoute(String location) {
  return location == AppRoutes.history ||
      location == AppRoutes.favorites ||
      location == AppRoutes.coins ||
      location == AppRoutes.stats ||
      location == AppRoutes.publish ||
      location == AppRoutes.myVideos ||
      location == AppRoutes.profile;
}

GoRouter createAppRouter(AuthProvider auth) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.home,
    refreshListenable: auth,
    redirect: (context, state) {
      final authenticated = auth.isAuthenticated;
      final isAdmin = auth.isAdmin;
      final location = _currentLocation(state);
      final loggingIn =
          location == AppRoutes.login || location == AppRoutes.register;

      if (location == AppRoutes.home || loggingIn) {
        return null;
      }

      if (location.startsWith('/admin')) {
        if (!authenticated) {
          return AppRoutes.login;
        }
        if (!isAdmin) {
          return AppRoutes.home;
        }
        return null;
      }

      if (!authenticated && _isProtectedPortalRoute(location)) {
        return AppRoutes.login;
      }

      return null;
    },
    routes: [
      GoRoute(
        name: 'login',
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        name: 'register',
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      ShellRoute(
        navigatorKey: portalNavigatorKey,
        builder: _portalShell,
        routes: [
          GoRoute(
            name: 'home',
            path: AppRoutes.home,
            builder: (_, _) => const HomePage(),
          ),
          GoRoute(
            name: 'history',
            path: AppRoutes.history,
            builder: (_, _) => const HistoryPage(),
          ),
          GoRoute(
            name: 'favorites',
            path: AppRoutes.favorites,
            builder: (_, _) => const FavoritesPage(),
          ),
          GoRoute(
            name: 'coins',
            path: AppRoutes.coins,
            builder: (_, _) => const CoinsPage(),
          ),
          GoRoute(
            name: 'stats',
            path: AppRoutes.stats,
            builder: (_, _) => const StatsPage(),
          ),
          GoRoute(
            name: 'publish',
            path: AppRoutes.publish,
            builder: (_, _) => const PublishPage(),
          ),
          GoRoute(
            name: 'myVideos',
            path: AppRoutes.myVideos,
            builder: (_, _) => const MyVideosPage(),
          ),
          GoRoute(
            name: 'profile',
            path: AppRoutes.profile,
            builder: (_, _) => const ProfilePage(),
          ),
          GoRoute(
            name: 'videoDetail',
            path: AppRoutes.videoDetailPattern,
            builder: (context, state) {
              final videoId = int.tryParse(
                state.pathParameters['videoId'] ?? '',
              );
              if (videoId == null || videoId <= 0) {
                return const _InvalidRoutePage(message: '无效的视频 ID');
              }
              return VideoDetailPage(videoId: videoId);
            },
          ),
          GoRoute(
            name: 'userHome',
            path: AppRoutes.userHomePattern,
            builder: (context, state) {
              final userId = int.tryParse(state.pathParameters['userId'] ?? '');
              if (userId == null || userId <= 0) {
                return const _InvalidRoutePage(message: '无效的用户 ID');
              }
              return UserHomePage(userId: userId);
            },
          ),
        ],
      ),
      ShellRoute(
        navigatorKey: adminNavigatorKey,
        builder: _adminShell,
        routes: [
          GoRoute(
            name: 'adminDashboard',
            path: AppRoutes.adminDashboard,
            builder: (context, state) => const AdminDashboardPage(),
          ),
          GoRoute(
            name: 'adminReview',
            path: AppRoutes.adminReview,
            builder: (context, state) => const VideoReviewPage(),
          ),
          GoRoute(
            name: 'adminBans',
            path: AppRoutes.adminBans,
            builder: (context, state) => const BanUserPage(),
          ),
          GoRoute(
            name: 'adminReports',
            path: AppRoutes.adminReports,
            builder: (context, state) => const ReportReviewPage(),
          ),
          GoRoute(
            name: 'adminUsers',
            path: AppRoutes.adminUsers,
            builder: (context, state) => const UsersPage(),
          ),
        ],
      ),
    ],
  );
}

class _InvalidRoutePage extends StatelessWidget {
  const _InvalidRoutePage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(message),
          ],
        ),
      ),
    );
  }
}
