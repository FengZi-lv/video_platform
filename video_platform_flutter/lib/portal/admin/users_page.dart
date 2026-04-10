import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;

import '../../models/user_model.dart';
import '../../providers/admin_provider.dart';
import '../../providers/user_provider.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  late Future<List<UserModel>> _usersFuture;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _usersFuture = context.read<UserProvider>().getAllUsers();
  }

  Future<void> _exportCsv(BuildContext context) async {
    final admin = context.read<AdminProvider>();
    final provider = context.read<UserProvider>();
    final users = await provider.getAllUsers();

    setState(() => _loading = true);
    try {
      final csv = await admin.exportUsersCsv(users);
      if (csv != null && mounted) {
        final bytes = utf8.encode('\uFEFF$csv'); // with BOM for Excel
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute(
            'download',
            'users_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv',
          )
          ..click();
        html.Url.revokeObjectUrl(url);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('导出成功')));
      } else if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('导出失败')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('导出失败: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Color _statusColor(String status) {
    return switch (status) {
      'admin' => Colors.purple,
      'ban' => Colors.red,
      'active' => Colors.green,
      _ => Colors.grey,
    };
  }

  String _statusText(String status) {
    return switch (status) {
      'admin' => '管理员',
      'ban' => '已封禁',
      'active' => '正常',
      _ => status,
    };
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '用户管理',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _loading ? null : () => _exportCsv(context),
                    icon: _loading
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.download),
                    label: const Text('导出CSV'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<UserModel>>(
                future: _usersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('加载失败: ${snapshot.error}'));
                  }
                  final users = snapshot.data ?? [];
                  if (users.isEmpty) {
                    return const Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 48,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text('暂无用户'),
                        ],
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('账号')),
                        DataColumn(label: Text('昵称')),
                        DataColumn(label: Text('状态')),
                        DataColumn(label: Text('硬币')),
                        DataColumn(label: Text('简介')),
                      ],
                      rows: users
                          .map(
                            (u) => DataRow(
                              cells: [
                                DataCell(Text('${u.id}')),
                                DataCell(
                                  Text(u.account.isEmpty ? '-' : u.account),
                                ),
                                DataCell(Text(u.nickname)),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _statusColor(u.status),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      _statusText(u.status),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(Text('${u.coins}')),
                                DataCell(
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 200,
                                    ),
                                    child: Text(
                                      u.bio,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        if (admin.loading) const ModalBarrier(dismissible: false),
        if (admin.loading) const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
