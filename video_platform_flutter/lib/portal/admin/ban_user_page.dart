import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_model.dart';
import '../../providers/admin_provider.dart';
import '../../providers/user_provider.dart';

class BanUserPage extends StatefulWidget {
  const BanUserPage({super.key});

  @override
  State<BanUserPage> createState() => _BanUserPageState();
}

class _BanUserPageState extends State<BanUserPage> {
  List<UserModel> _users = [];
  bool _loading = true;
  String _filter = 'all'; // all | ban | active

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userProvider = context.read<UserProvider>();
      final allUsers = await userProvider.getAllUsers();
      if (mounted) {
        setState(() {
          _users = allUsers;
          _loading = false;
        });
        context.read<AdminProvider>().setAllUsers(allUsers);
      }
    });
  }

  List<UserModel> _getFilteredUsers() {
    if (_filter == 'all') return _users;
    return _users.where((u) => u.status == _filter).toList();
  }

  Future<void> _toggleBan(UserModel user) async {
    final admin = context.read<AdminProvider>();
    final userProvider = context.read<UserProvider>();

    if (user.status != 'ban') {
      await userProvider.banUser(user.id);
    } else if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('后端暂未提供解封接口')));
      return;
    }

    // Reload users
    final updatedUsers = await userProvider.getAllUsers();
    if (mounted) {
      setState(() {
        _users = updatedUsers;
      });
      admin.setAllUsers(updatedUsers);
    }
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
              Text(
                '封禁管理',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Filter
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('全部'),
                    selected: _filter == 'all',
                    onSelected: (_) => setState(() => _filter = 'all'),
                  ),
                  FilterChip(
                    label: const Text('已封禁'),
                    selected: _filter == 'ban',
                    onSelected: (_) => setState(() => _filter = 'ban'),
                  ),
                  FilterChip(
                    label: const Text('正常'),
                    selected: _filter == 'active',
                    onSelected: (_) => setState(() => _filter = 'active'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else if (_getFilteredUsers().isEmpty)
                const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people_outline, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('没有符合条件的用户'),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _getFilteredUsers().length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final user = _getFilteredUsers()[index];
                    final isAdmin = user.status == 'admin';

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: user.status == 'ban'
                              ? Colors.red[100]
                              : Colors.blue[100],
                          child: Text(
                            user.nickname.substring(0, 1).toUpperCase(),
                          ),
                        ),
                        title: Text(user.nickname),
                        subtitle: Text(
                          user.account.isEmpty
                              ? '后端未返回账号信息'
                              : '账号: ${user.account}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: user.status == 'admin'
                                    ? Colors.purple
                                    : user.status == 'ban'
                                    ? Colors.red
                                    : Colors.green,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                user.status == 'admin'
                                    ? '管理员'
                                    : user.status == 'ban'
                                    ? '已封禁'
                                    : '正常',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            if (!isAdmin)
                              FilledButton.tonal(
                                onPressed: () => _toggleBan(user),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: Text(
                                  user.status == 'ban' ? '暂不支持解封' : '封禁',
                                ),
                              )
                            else
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  '不可操作',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
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
