import 'package:flutter/material.dart';

import '../../controller/app_controller.dart';
import '../../models/models.dart';
import '../app_shell.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key, required this.controller});
  final AppController controller;
  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  final _account = TextEditingController();
  final _password = TextEditingController();
  AppController get controller => widget.controller;

  @override
  void dispose() {
    _account.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.isAuthenticated) {
      return _AdminLoginPage(
        controller: controller,
        accountController: _account,
        passwordController: _password,
      );
    }
    if (!controller.isAdmin) {
      return Scaffold(
        body: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(controller.adminAccessError ?? '当前账号没有管理员权限'),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: () => controller.navigate('/front/profile'),
                  child: const Text('返回个人页'),
                ),
              ]),
            ),
          ),
        ),
      );
    }
    if (controller.adminLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('管理端控制台'),
        actions: [
          FilledButton.tonalIcon(
            key: const Key('admin-export-button'),
            onPressed: () async {
              final csv = await controller.exportUsersCsv();
              if (!context.mounted) return;
              showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('导出所有用户信息表格'),
                  content: SizedBox(width: 520, child: SingleChildScrollView(child: SelectableText(csv))),
                  actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('关闭'))],
                ),
              );
            },
            icon: const Icon(Icons.table_view_rounded),
            label: const Text('导出用户表格'),
          ),
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: FilledButton.tonalIcon(
              onPressed: () async {
                final msg = await controller.logout();
                if (context.mounted) showFeedback(context, msg);
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('退出管理端'),
            ),
          ),
        ],
      ),
      body: Row(children: [
        NavigationRail(
          selectedIndex: controller.adminSection.index,
          onDestinationSelected: (index) => controller.navigate(['/admin/dashboard', '/admin/reviews', '/admin/reports', '/admin/users'][index]),
          destinations: const [
            NavigationRailDestination(icon: Icon(Icons.space_dashboard_outlined), label: Text('总览')),
            NavigationRailDestination(icon: Icon(Icons.verified_outlined), label: Text('视频审核')),
            NavigationRailDestination(icon: Icon(Icons.flag_outlined), label: Text('举报处理')),
            NavigationRailDestination(icon: Icon(Icons.people_outline), label: Text('用户管理')),
          ],
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1320),
                child: switch (controller.adminSection) {
                  AdminSection.dashboard => _Dashboard(controller: controller),
                  AdminSection.reviews => _AuditSection(controller: controller),
                  AdminSection.reports => _ReportSection(controller: controller),
                  AdminSection.users => _UserSection(controller: controller),
                },
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _AdminLoginPage extends StatelessWidget {
  const _AdminLoginPage({
    required this.controller,
    required this.accountController,
    required this.passwordController,
  });
  final AppController controller;
  final TextEditingController accountController;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('管理员登录', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  const Text('通过 JWT 登录接口校验管理员身份后进入管理台。'),
                  const SizedBox(height: 18),
                  TextField(controller: accountController, decoration: const InputDecoration(labelText: '管理员账号')),
                  const SizedBox(height: 12),
                  TextField(controller: passwordController, decoration: const InputDecoration(labelText: '密码'), obscureText: true),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    key: const Key('admin-login-button'),
                    onPressed: controller.adminLoginPending
                        ? null
                        : () async {
                            final msg = await controller.login(
                              account: accountController.text,
                              password: passwordController.text,
                              adminLogin: true,
                            );
                            if (context.mounted) showFeedback(context, msg);
                          },
                    icon: const Icon(Icons.admin_panel_settings_rounded),
                    label: Text(controller.adminLoginPending ? '登录中...' : '进入管理台'),
                  ),
                ]),
              ),
            ),
          ),
        ),
      );
}

class _Dashboard extends StatelessWidget {
  const _Dashboard({required this.controller});
  final AppController controller;
  @override
  Widget build(BuildContext context) => Wrap(spacing: 16, runSpacing: 16, children: [
        _Metric(label: '待审核视频', value: '${controller.adminSummary.pendingAudits}'),
        _Metric(label: '待处理举报', value: '${controller.adminSummary.pendingReports}'),
        _Metric(label: '已封禁账号', value: '${controller.adminSummary.bannedUsers}'),
        _Metric(label: '用户总数', value: '${controller.adminSummary.totalUsers}'),
      ]);
}

class _AuditSection extends StatelessWidget {
  const _AuditSection({required this.controller});
  final AppController controller;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('审核视频'),
        const SizedBox(height: 12),
        ...controller.auditItems.map((item) => _ActionTile(
              key: Key('audit-tile-${item.id}'),
              title: item.videoTitle,
              subtitle: '${item.uploaderName} · ${item.submittedLabel}\n${item.note}',
              badge: _auditStatusLabel(item.status),
              primaryLabel: '通过',
              secondaryLabel: '驳回',
              onPrimary: item.status == AuditStatus.approved
                  ? null
                  : () async {
                      final msg = await controller.updateAuditStatus(
                        item.id,
                        AuditStatus.approved,
                      );
                      if (context.mounted) showFeedback(context, msg);
                    },
              onSecondary: item.status == AuditStatus.rejected
                  ? null
                  : () async {
                      final msg = await controller.updateAuditStatus(
                        item.id,
                        AuditStatus.rejected,
                      );
                      if (context.mounted) showFeedback(context, msg);
                    },
            )),
      ]);
}

class _ReportSection extends StatelessWidget {
  const _ReportSection({required this.controller});
  final AppController controller;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('处理举报'),
        const SizedBox(height: 12),
        ...controller.reportItems.map((item) => _ActionTile(
              key: Key('report-tile-${item.id}'),
              title: item.videoTitle,
              subtitle: '${item.reporterName} · ${item.createdLabel}\n举报原因：${item.reason}',
              badge: _reportStatusLabel(item.status),
              primaryLabel: item.status == ReportStatus.processed ? '已处理' : '标记已处理',
              onPrimary: item.status == ReportStatus.processed
                  ? null
                  : () async {
                      final msg = await controller.resolveReport(item.id);
                      if (context.mounted) showFeedback(context, msg);
                    },
            )),
      ]);
}

class _UserSection extends StatelessWidget {
  const _UserSection({required this.controller});
  final AppController controller;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('用户管理'),
        const SizedBox(height: 12),
        ...controller.allUsers.map((user) => _ActionTile(
              key: Key('user-tile-${user.id}'),
              title: user.nickname,
              subtitle: '账号 ${user.account}\n硬币 ${user.coins} · ${user.bio}',
              badge: user.isBanned ? '已封禁' : '正常',
              primaryLabel: user.isBanned ? '解除封禁' : '封禁账号',
              onPrimary: () async {
                final msg = await controller.toggleBanUser(user.id);
                if (context.mounted) showFeedback(context, msg);
              },
            )),
      ]);
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => SizedBox(width: 240, child: Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label), const SizedBox(height: 10), Text(value, style: Theme.of(context).textTheme.headlineMedium)]))));
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.primaryLabel,
    this.secondaryLabel,
    this.onPrimary,
    this.onSecondary,
  });
  final String title;
  final String subtitle;
  final String badge;
  final String primaryLabel;
  final String? secondaryLabel;
  final Future<void> Function()? onPrimary;
  final Future<void> Function()? onSecondary;
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(border: Border.all(color: Theme.of(context).colorScheme.outlineVariant), borderRadius: BorderRadius.circular(20)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wrap(spacing: 12, children: [Text(title), Chip(label: Text(badge))]),
          const SizedBox(height: 10),
          Text(subtitle),
          const SizedBox(height: 14),
          Wrap(spacing: 12, children: [
            FilledButton.tonal(onPressed: onPrimary == null ? null : () => onPrimary!.call(), child: Text(primaryLabel)),
            if (secondaryLabel != null) OutlinedButton(onPressed: onSecondary == null ? null : () => onSecondary!.call(), child: Text(secondaryLabel!)),
          ]),
        ]),
      );
}

String _auditStatusLabel(AuditStatus status) => switch (status) {
      AuditStatus.pending => '待审核',
      AuditStatus.approved => '已通过',
      AuditStatus.rejected => '已驳回',
    };

String _reportStatusLabel(ReportStatus status) => switch (status) {
      ReportStatus.pending => '待处理',
      ReportStatus.processed => '已处理',
    };
