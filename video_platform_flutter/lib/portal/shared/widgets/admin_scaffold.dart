import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../routes/app_routes.dart';
import '../../../routes/router.dart';

class AdminScaffold extends StatelessWidget {
  const AdminScaffold({super.key, required this.child});

  final Widget child;

  static const List<_AdminDestination> _destinations = [
    _AdminDestination(
      route: AppRouteRegistry.adminDashboard,
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      label: '仪表盘',
    ),
    _AdminDestination(
      route: AppRouteRegistry.adminReview,
      icon: Icons.verified_outlined,
      selectedIcon: Icons.verified,
      label: '视频审核',
    ),
    _AdminDestination(
      route: AppRouteRegistry.adminBans,
      icon: Icons.block_outlined,
      selectedIcon: Icons.block,
      label: '封禁管理',
    ),
    _AdminDestination(
      route: AppRouteRegistry.adminReports,
      icon: Icons.flag_outlined,
      selectedIcon: Icons.flag,
      label: '举报处理',
    ),
    _AdminDestination(
      route: AppRouteRegistry.adminUsers,
      icon: Icons.people_outlined,
      selectedIcon: Icons.people,
      label: '用户管理',
    ),
  ];

  int _selectedIndex(String location) {
    final selected = _destinations.indexWhere(
      (destination) => destination.route.matches(location),
    );
    return selected >= 0 ? selected : 0;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final location = GoRouterState.of(context).uri.path;
    final canGoBack = adminNavigatorKey.currentState?.canPop() ?? false;
    final selectedIndex = _selectedIndex(location);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('管理端'),
        leadingWidth: canGoBack ? 56 : 0,
        leading: canGoBack
            ? IconButton(
                icon: const Icon(Icons.arrow_back, size: 24),
                tooltip: '返回上一页',
                onPressed: () => adminNavigatorKey.currentState?.maybePop(),
              )
            : null,
        actions: [
          if (auth.isAuthenticated)
            TextButton(
              onPressed: () {
                auth.logout();
                context.go(AppRoutes.home);
              },
              child: const Text('退出'),
            ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            extended: true,
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              context.go(_destinations[index].route.path);
            },
            destinations: _destinations
                .map(
                  (destination) => NavigationRailDestination(
                    icon: Icon(destination.icon),
                    selectedIcon: Icon(destination.selectedIcon),
                    label: Text(destination.label),
                  ),
                )
                .toList(growable: false),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _AdminDestination {
  const _AdminDestination({
    required this.route,
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final AppRouteItem route;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
