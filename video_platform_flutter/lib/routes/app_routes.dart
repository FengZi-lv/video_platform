/// Route path constants and navigation metadata.
class AppRoutes {
  AppRoutes._();

  // Auth
  static const String login = '/login';
  static const String register = '/register';

  // Portal primary destinations
  static const String home = '/home';
  static const String history = '/history';
  static const String favorites = '/favorites';
  static const String coins = '/coins';
  static const String stats = '/stats';
  static const String publish = '/publish';
  static const String myVideos = '/my-videos';
  static const String profile = '/profile';

  // Portal detail routes
  static const String videoDetailPattern = '/video/:videoId';
  static const String userHomePattern = '/user-home/:userId';
  static String userHomeRoute(int userId) => '/user-home/$userId';

  // Admin
  static const String adminDashboard = '/admin/dashboard';
  static const String adminReview = '/admin/review';
  static const String adminBans = '/admin/bans';
  static const String adminReports = '/admin/reports';
  static const String adminUsers = '/admin/users';

  static String videoDetail(int videoId) => '/video/$videoId';
}

class AppRouteItem {
  const AppRouteItem({
    required this.name,
    required this.path,
    this.matchPrefixes = const [],
  });

  final String name;
  final String path;
  final List<String> matchPrefixes;

  bool matches(String location) {
    if (location == path || location.startsWith('$path/')) {
      return true;
    }

    return matchPrefixes.any(
      (prefix) => location == prefix || location.startsWith('$prefix/'),
    );
  }
}

class AppRouteRegistry {
  AppRouteRegistry._();

  static const AppRouteItem portalHome = AppRouteItem(
    name: 'home',
    path: AppRoutes.home,
  );
  static const AppRouteItem portalHistory = AppRouteItem(
    name: 'history',
    path: AppRoutes.history,
  );
  static const AppRouteItem portalFavorites = AppRouteItem(
    name: 'favorites',
    path: AppRoutes.favorites,
  );
  static const AppRouteItem portalCoins = AppRouteItem(
    name: 'coins',
    path: AppRoutes.coins,
  );
  static const AppRouteItem portalStats = AppRouteItem(
    name: 'stats',
    path: AppRoutes.stats,
  );
  static const AppRouteItem portalPublish = AppRouteItem(
    name: 'publish',
    path: AppRoutes.publish,
  );
  static const AppRouteItem portalMyVideos = AppRouteItem(
    name: 'myVideos',
    path: AppRoutes.myVideos,
  );
  static const AppRouteItem portalProfile = AppRouteItem(
    name: 'profile',
    path: AppRoutes.profile,
  );

  static const List<AppRouteItem> portalPrimary = [
    portalHome,
    portalHistory,
    portalFavorites,
    portalCoins,
    portalStats,
    portalPublish,
    portalMyVideos,
    portalProfile,
  ];

  static const AppRouteItem adminDashboard = AppRouteItem(
    name: 'adminDashboard',
    path: AppRoutes.adminDashboard,
  );
  static const AppRouteItem adminReview = AppRouteItem(
    name: 'adminReview',
    path: AppRoutes.adminReview,
  );
  static const AppRouteItem adminBans = AppRouteItem(
    name: 'adminBans',
    path: AppRoutes.adminBans,
  );
  static const AppRouteItem adminReports = AppRouteItem(
    name: 'adminReports',
    path: AppRoutes.adminReports,
  );
  static const AppRouteItem adminUsers = AppRouteItem(
    name: 'adminUsers',
    path: AppRoutes.adminUsers,
  );

  static const List<AppRouteItem> adminPrimary = [
    adminDashboard,
    adminReview,
    adminBans,
    adminReports,
    adminUsers,
  ];
}
