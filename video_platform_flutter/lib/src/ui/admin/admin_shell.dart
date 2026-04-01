import 'package:flutter/material.dart';

import '../../controller/mock_app_controller.dart';
import '../../models/models.dart';
import '../app_shell.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({super.key, required this.controller});

  final MockAppController controller;

  @override
  Widget build(BuildContext context) {
    if (!controller.adminAuthenticated) {
      return _AdminLoginPage(controller: controller);
    }

    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final railExtended = width >= 1280;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('管理端控制台'),
            Text(
              '视频审核、举报处理、用户管理',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          FilledButton.tonalIcon(
            key: const Key('admin-export-button'),
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('导出所有用户信息表格'),
                  content: SizedBox(
                    width: 520,
                    child: SingleChildScrollView(
                      child: SelectableText(controller.exportUsersCsv()),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('关闭'),
                    ),
                  ],
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
              onPressed: () {
                showFeedback(context, controller.adminLogout());
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('退出管理端'),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            extended: railExtended,
            selectedIndex: controller.adminSection.index,
            onDestinationSelected: (index) {
              controller.setAdminSection(AdminSection.values[index]);
            },
            leading: Padding(
              padding: const EdgeInsets.all(18),
              child: Text(
                '审核中心',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.space_dashboard_outlined),
                selectedIcon: Icon(Icons.space_dashboard_rounded),
                label: Text('总览'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.verified_outlined),
                selectedIcon: Icon(Icons.verified_rounded),
                label: Text('视频审核'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.outlined_flag_rounded),
                selectedIcon: Icon(Icons.flag_rounded),
                label: Text('举报处理'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_outline_rounded),
                selectedIcon: Icon(Icons.people_rounded),
                label: Text('用户管理'),
              ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1360),
                  child: _buildSection(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context) {
    switch (controller.adminSection) {
      case AdminSection.dashboard:
        return _AdminDashboard(controller: controller);
      case AdminSection.reviews:
        return _AdminReviewSection(controller: controller);
      case AdminSection.reports:
        return _AdminReportSection(controller: controller);
      case AdminSection.users:
        return _AdminUserSection(controller: controller);
    }
  }
}

class _AdminLoginPage extends StatelessWidget {
  const _AdminLoginPage({required this.controller});

  final MockAppController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '管理员登录',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 12),
                  const Text('首版为 mock 管理登录，点击按钮直接进入管理台。'),
                  const SizedBox(height: 18),
                  const TextField(
                    decoration: InputDecoration(labelText: '管理员账号'),
                  ),
                  const SizedBox(height: 12),
                  const TextField(
                    decoration: InputDecoration(labelText: '密码'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    key: const Key('admin-login-button'),
                    onPressed: () {
                      showFeedback(context, controller.adminLogin());
                    },
                    icon: const Icon(Icons.admin_panel_settings_rounded),
                    label: const Text('进入管理台'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminDashboard extends StatelessWidget {
  const _AdminDashboard({required this.controller});

  final MockAppController controller;

  @override
  Widget build(BuildContext context) {
    final pendingAudits =
        controller.auditItems.where((item) => item.status == AuditStatus.pending);
    final pendingReports = controller.reportItems
        .where((item) => item.status == ReportStatus.pending);
    final bannedUsers = controller.allUsers.where((item) => item.isBanned);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _AdminMetricCard(label: '待审核视频', value: '${pendingAudits.length}'),
            _AdminMetricCard(label: '待处理举报', value: '${pendingReports.length}'),
            _AdminMetricCard(label: '已封禁账号', value: '${bannedUsers.length}'),
            _AdminMetricCard(label: '用户总数', value: '${controller.allUsers.length}'),
          ],
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            SizedBox(
              width: 660,
              child: _AdminPanel(
                title: '审核队列概览',
                subtitle: '展示当前待审核的视频以及最近处理记录。',
                child: Column(
                  children: controller.auditItems.take(3).map((item) {
                    return _SummaryTile(
                      title: item.videoTitle,
                      subtitle: '${item.uploaderName} · ${_auditStatusLabel(item.status)}',
                      leading: Icons.video_collection_rounded,
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(
              width: 660,
              child: _AdminPanel(
                title: '举报和用户状态',
                subtitle: '快速查看待处理举报与封禁账号。',
                child: Column(
                  children: [
                    ...controller.reportItems.take(2).map((item) {
                      return _SummaryTile(
                        title: item.videoTitle,
                        subtitle: '${item.reason} · ${_reportStatusLabel(item.status)}',
                        leading: Icons.flag_rounded,
                      );
                    }),
                    ...controller.allUsers.where((user) => user.isBanned).take(2).map((user) {
                      return _SummaryTile(
                        title: user.nickname,
                        subtitle: '账号 ${user.account} · 已封禁',
                        leading: Icons.block_rounded,
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AdminReviewSection extends StatelessWidget {
  const _AdminReviewSection({required this.controller});

  final MockAppController controller;

  @override
  Widget build(BuildContext context) {
    final audits = controller.auditItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: '审核视频',
          description: '查看待审核、已通过、已驳回的视频，并执行审核操作。',
        ),
        const SizedBox(height: 16),
        _AdminFilterRow(
          chips: [
            _FilterChipData('全部', '${audits.length}'),
            _FilterChipData(
              '待审核',
              '${audits.where((item) => item.status == AuditStatus.pending).length}',
            ),
            _FilterChipData(
              '已通过',
              '${audits.where((item) => item.status == AuditStatus.approved).length}',
            ),
            _FilterChipData(
              '已驳回',
              '${audits.where((item) => item.status == AuditStatus.rejected).length}',
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: _AdminPanel(
                title: '审核列表',
                subtitle: '每条记录都可直接通过或驳回。',
                child: Column(
                  children: audits.map((item) {
                    final video = controller.findVideoById(item.videoId);
                    return _ActionTile(
                      key: Key('audit-tile-${item.id}'),
                      title: item.videoTitle,
                      badge: _auditStatusLabel(item.status),
                      subtitle:
                          '${item.uploaderName} · ${item.submittedLabel}\n${item.note}',
                      footer: video == null
                          ? null
                          : '时长 ${video.duration} · 分类 ${video.category} · 播放 ${video.metrics.views}',
                      primaryLabel: '通过',
                      secondaryLabel: '驳回',
                      onPrimary: item.status == AuditStatus.approved
                          ? null
                          : () {
                              showFeedback(
                                context,
                                controller.updateAuditStatus(
                                  item.id,
                                  AuditStatus.approved,
                                ),
                              );
                            },
                      onSecondary: item.status == AuditStatus.rejected
                          ? null
                          : () {
                              showFeedback(
                                context,
                                controller.updateAuditStatus(
                                  item.id,
                                  AuditStatus.rejected,
                                ),
                              );
                            },
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 5,
              child: _AdminPanel(
                title: '审核说明',
                subtitle: '本页对应“审核视频”能力。',
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BulletLine('可以查看待审核、已通过、已驳回的视频记录。'),
                    _BulletLine('点击“通过”后，前台视频会进入可浏览列表。'),
                    _BulletLine('点击“驳回”后，投稿仍保留在创作者记录中，但状态为驳回。'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AdminReportSection extends StatelessWidget {
  const _AdminReportSection({required this.controller});

  final MockAppController controller;

  @override
  Widget build(BuildContext context) {
    final reports = controller.reportItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: '处理举报',
          description: '查看视频举报原因、举报人和处理状态，并执行处理。',
        ),
        const SizedBox(height: 16),
        _AdminFilterRow(
          chips: [
            _FilterChipData('全部', '${reports.length}'),
            _FilterChipData(
              '待处理',
              '${reports.where((item) => item.status == ReportStatus.pending).length}',
            ),
            _FilterChipData(
              '已处理',
              '${reports.where((item) => item.status == ReportStatus.processed).length}',
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: _AdminPanel(
                title: '举报列表',
                subtitle: '可查看每条举报对应的视频与原因。',
                child: Column(
                  children: reports.map((item) {
                    final video = controller.findVideoById(item.videoId);
                    return _ActionTile(
                      key: Key('report-tile-${item.id}'),
                      title: item.videoTitle,
                      badge: _reportStatusLabel(item.status),
                      subtitle:
                          '${item.reporterName} · ${item.createdLabel}\n举报原因：${item.reason}',
                      footer: video == null
                          ? null
                          : '作者 ${video.ownerName} · 点赞 ${video.metrics.likes} · 收藏 ${video.metrics.favorites}',
                      primaryLabel: item.status == ReportStatus.processed
                          ? '已处理'
                          : '标记已处理',
                      onPrimary: item.status == ReportStatus.processed
                          ? null
                          : () {
                              showFeedback(
                                context,
                                controller.resolveReport(item.id),
                              );
                            },
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 5,
              child: _AdminPanel(
                title: '处理规则',
                subtitle: '本页对应“处理举报”能力。',
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BulletLine('保留举报原因为 mock 文案，便于前后端联调时替换。'),
                    _BulletLine('标记已处理后，状态立即变更为“已处理”。'),
                    _BulletLine('导出的用户表格与举报处理互不影响，保持独立。'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AdminUserSection extends StatelessWidget {
  const _AdminUserSection({required this.controller});

  final MockAppController controller;

  @override
  Widget build(BuildContext context) {
    final users = controller.allUsers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: '用户管理',
          description: '查看所有用户信息，并执行封禁或解封操作。',
        ),
        const SizedBox(height: 16),
        _AdminFilterRow(
          chips: [
            _FilterChipData('全部用户', '${users.length}'),
            _FilterChipData(
              '正常',
              '${users.where((user) => !user.isBanned).length}',
            ),
            _FilterChipData(
              '已封禁',
              '${users.where((user) => user.isBanned).length}',
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: _AdminPanel(
                title: '用户列表',
                subtitle: '封禁用户后，前台 mock 登录将进入受限状态。',
                child: Column(
                  children: users.map((user) {
                    return _ActionTile(
                      key: Key('user-tile-${user.id}'),
                      title: user.nickname,
                      badge: user.isBanned ? '已封禁' : '正常',
                      subtitle:
                          '账号 ${user.account}\n硬币 ${user.coins} · ${user.bio}',
                      footer: user.isCurrentMember ? '当前客户端演示账号' : null,
                      primaryLabel: user.isBanned ? '解除封禁' : '封禁账号',
                      onPrimary: () {
                        showFeedback(context, controller.toggleBanUser(user.id));
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 5,
              child: _AdminPanel(
                title: '管理说明',
                subtitle: '本页对应“封禁账号”与“导出用户信息表格”能力。',
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BulletLine('封禁后，用户在前台只能浏览，不能继续使用互动功能。'),
                    _BulletLine('再次点击按钮即可解封，便于 mock 场景反复演示。'),
                    _BulletLine('顶部“导出用户表格”可查看当前用户 CSV 内容。'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 6),
        Text(description),
      ],
    );
  }
}

class _AdminPanel extends StatelessWidget {
  const _AdminPanel({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Text(subtitle),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _AdminMetricCard extends StatelessWidget {
  const _AdminMetricCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label),
              const SizedBox(height: 10),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminFilterRow extends StatelessWidget {
  const _AdminFilterRow({required this.chips});

  final List<_FilterChipData> chips;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: chips
          .map(
            (chip) => Chip(
              label: Text('${chip.label} ${chip.count}'),
            ),
          )
          .toList(),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    super.key,
    required this.title,
    required this.badge,
    required this.subtitle,
    required this.primaryLabel,
    this.secondaryLabel,
    this.footer,
    this.onPrimary,
    this.onSecondary,
  });

  final String title;
  final String badge;
  final String subtitle;
  final String primaryLabel;
  final String? secondaryLabel;
  final String? footer;
  final VoidCallback? onPrimary;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Chip(label: Text(badge)),
            ],
          ),
          const SizedBox(height: 10),
          Text(subtitle),
          if (footer != null) ...[
            const SizedBox(height: 10),
            Text(
              footer!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.tonal(
                onPressed: onPrimary,
                child: Text(primaryLabel),
              ),
              if (secondaryLabel != null)
                OutlinedButton(
                  onPressed: onSecondary,
                  child: Text(secondaryLabel!),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.title,
    required this.subtitle,
    required this.leading,
  });

  final String title;
  final String subtitle;
  final IconData leading;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(leading),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}

class _BulletLine extends StatelessWidget {
  const _BulletLine(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 8),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _FilterChipData {
  const _FilterChipData(this.label, this.count);

  final String label;
  final String count;
}

String _auditStatusLabel(AuditStatus status) {
  switch (status) {
    case AuditStatus.pending:
      return '待审核';
    case AuditStatus.approved:
      return '已通过';
    case AuditStatus.rejected:
      return '已驳回';
  }
}

String _reportStatusLabel(ReportStatus status) {
  switch (status) {
    case ReportStatus.pending:
      return '待处理';
    case ReportStatus.processed:
      return '已处理';
  }
}
