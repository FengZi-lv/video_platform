import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/coin_provider.dart';
import '../../../routes/app_routes.dart';
import '../../../routes/router.dart';
import 'search_bar_widget.dart';

class PortalScaffold extends StatelessWidget {
  const PortalScaffold({super.key, required this.child});

  final Widget child;

  static const List<_PortalDestination> _destinations = [
    _PortalDestination(
      route: AppRouteRegistry.portalHome,
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: '首页',
      guestVisible: true,
    ),
    _PortalDestination(
      route: AppRouteRegistry.portalHistory,
      icon: Icons.history_outlined,
      selectedIcon: Icons.history,
      label: '历史',
    ),
    _PortalDestination(
      route: AppRouteRegistry.portalFavorites,
      icon: Icons.favorite_border,
      selectedIcon: Icons.favorite,
      label: '收藏',
    ),
    _PortalDestination(
      route: AppRouteRegistry.portalCoins,
      icon: Icons.monetization_on_outlined,
      selectedIcon: Icons.monetization_on,
      label: '硬币',
    ),
    _PortalDestination(
      route: AppRouteRegistry.portalStats,
      icon: Icons.bar_chart_outlined,
      selectedIcon: Icons.bar_chart,
      label: '统计',
    ),
    _PortalDestination(
      route: AppRouteRegistry.portalPublish,
      icon: Icons.upload_outlined,
      selectedIcon: Icons.upload,
      label: '发布',
    ),
    _PortalDestination(
      route: AppRouteRegistry.portalMyVideos,
      icon: Icons.play_circle_outline,
      selectedIcon: Icons.play_circle,
      label: '我的视频',
    ),
    _PortalDestination(
      route: AppRouteRegistry.portalProfile,
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      label: '个人中心',
    ),
  ];

  List<_PortalDestination> _visibleDestinations(bool isGuest) {
    return _destinations
        .where((destination) => destination.guestVisible || !isGuest)
        .toList(growable: false);
  }

  int _selectedIndex(String location, List<_PortalDestination> destinations) {
    final selected = destinations.indexWhere(
      (destination) => destination.route.matches(location),
    );
    return selected >= 0 ? selected : 0;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isGuest = auth.isGuest;
    final location = GoRouterState.of(context).uri.path;
    final destinations = _visibleDestinations(isGuest);
    final selectedIndex = _selectedIndex(location, destinations);
    final canGoBack = portalNavigatorKey.currentState?.canPop() ?? false;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(
          children: [
            const Text('视频平台'),
            const SizedBox(width: 16),
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: const SearchBarWidget(),
              ),
            ),
          ],
        ),
        leadingWidth: canGoBack ? 56 : 0,
        leading: canGoBack
            ? IconButton(
                icon: const Icon(Icons.arrow_back, size: 24),
                tooltip: '返回上一页',
                onPressed: () => portalNavigatorKey.currentState?.maybePop(),
              )
            : null,
        actions: [
          const SizedBox(width: 8),
          if (auth.currentUser?.status == 'admin')
            IconButton(
              tooltip: '管理端',
              icon: const Icon(Icons.admin_panel_settings_outlined),
              onPressed: () => context.go(AppRoutes.adminDashboard),
            ),
          if (isGuest)
            FilledButton.tonal(
              onPressed: () => context.go(AppRoutes.login),
              child: const Text('登录'),
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Consumer<CoinProvider>(
                  builder: (context, coin, _) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.orange[800]?.withValues(alpha: 0.3)
                            : Colors.orange[50],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.monetization_on,
                            size: 16,
                            color: Colors.orange[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${coin.balance}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.orange[700],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(width: 4),
                PopupMenuButton<String>(
                  tooltip: '用户菜单',
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  icon: CircleAvatar(
                    child: Text(
                      auth.currentUser?.nickname
                              .substring(0, 1)
                              .toUpperCase() ??
                          'U',
                    ),
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case 'profile':
                        context.go(
                          AppRoutes.userHomeRoute(auth.currentUser!.id),
                        );
                        break;
                      case 'logout':
                        auth.logout();
                        context.go(AppRoutes.home);
                        break;
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'profile', child: Text('个人中心')),
                    PopupMenuItem(value: 'logout', child: Text('退出登录')),
                  ],
                ),
              ],
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final extended = constraints.maxWidth > 800 && !isGuest;
          return Row(
            children: [
              NavigationRail(
                extended: extended,
                selectedIndex: selectedIndex,
                onDestinationSelected: (index) {
                  context.go(destinations[index].route.path);
                },
                destinations: destinations
                    .map(
                      (destination) => NavigationRailDestination(
                        icon: Icon(destination.icon),
                        selectedIcon: Icon(destination.selectedIcon),
                        label: Text(
                          destination.route.path == AppRoutes.profile
                              ? (auth.currentUser?.nickname ??
                                    destination.label)
                              : destination.label,
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(child: child),
            ],
          );
        },
      ),
    );
  }
}

class _PortalDestination {
  const _PortalDestination({
    required this.route,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.guestVisible = false,
  });

  final AppRouteItem route;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool guestVisible;
}
