import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../routes/app_routes.dart';
import '../shared/widgets/login_prompt_dialog.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _usernameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _oldPwdCtrl = TextEditingController();
  final _newPwdCtrl = TextEditingController();
  final _deletePwdCtrl = TextEditingController();
  final _profileFormKey = GlobalKey<FormState>();
  final _pwdFormKey = GlobalKey<FormState>();
  bool _profileLoading = false;
  bool _pwdLoading = false;
  int? _boundUserId;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _bioCtrl.dispose();
    _oldPwdCtrl.dispose();
    _newPwdCtrl.dispose();
    _deletePwdCtrl.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_profileFormKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();
    final userId = auth.currentUser!.id;

    setState(() => _profileLoading = true);
    try {
      await userProvider.updateProfile(
        userId,
        nickname: _usernameCtrl.text.trim(),
        bio: _bioCtrl.text.trim(),
      );
      await auth.reloadCurrentUser();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('个人资料已更新')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('更新失败: $e')));
      }
    } finally {
      if (mounted) setState(() => _profileLoading = false);
    }
  }

  Future<void> _changePassword() async {
    if (!_pwdFormKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();
    final userId = auth.currentUser!.id;

    setState(() => _pwdLoading = true);
    try {
      await userProvider.changePassword(
        userId,
        _oldPwdCtrl.text,
        _newPwdCtrl.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('密码修改成功')));
        _oldPwdCtrl.clear();
        _newPwdCtrl.clear();
        _pwdFormKey.currentState?.reset();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('密码修改失败: $e')));
      }
    } finally {
      if (mounted) setState(() => _pwdLoading = false);
    }
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        icon: const Icon(Icons.warning, color: Colors.red, size: 48),
        title: const Text('确认注销账号'),
        content: TextField(
          controller: _deletePwdCtrl,
          obscureText: true,
          decoration: const InputDecoration(labelText: '请输入密码确认注销'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final password = _deletePwdCtrl.text.trim();
              if (password.isEmpty) {
                return;
              }
              Navigator.of(dialogCtx).pop();
              await context.read<AuthProvider>().deleteAccount(password);
              _deletePwdCtrl.clear();
              if (mounted) {
                context.go(AppRoutes.home);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('账号已注销')));
              }
            },
            child: const Text('确认注销', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final currentUser = auth.currentUser;
    if (currentUser == null) {
      _boundUserId = null;
      if (_usernameCtrl.text.isNotEmpty || _bioCtrl.text.isNotEmpty) {
        _usernameCtrl.clear();
        _bioCtrl.clear();
      }
    } else if (_boundUserId != currentUser.id) {
      _boundUserId = currentUser.id;
      _usernameCtrl.text = currentUser.nickname;
      _bioCtrl.text = currentUser.bio;
    }

    if (auth.isGuest) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_outline,
              size: 64,
              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              '个人中心',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              '正在跳转登录页...',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => const LoginPromptDialog(),
              ),
              icon: const Icon(Icons.login, size: 18),
              label: const Text('去登录'),
            ),
          ],
        ),
      );
    }

    final user = auth.currentUser!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile header with gradient
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.secondary],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Text(
                      user.nickname.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.nickname,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: user.status == 'admin'
                                ? Colors.deepPurpleAccent
                                : Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            user.status == 'admin' ? '管理员' : '普通用户',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Profile form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.edit, size: 20, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          '编辑资料',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Form(
                      key: _profileFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _usernameCtrl,
                            decoration: const InputDecoration(
                              labelText: '昵称',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (v) =>
                                v == null || v.trim().isEmpty ? '请输入昵称' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _bioCtrl,
                            decoration: const InputDecoration(
                              labelText: '个人简介',
                              prefixIcon: Icon(Icons.description_outlined),
                              alignLabelWithHint: true,
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            onPressed: _profileLoading ? null : _updateProfile,
                            icon: _profileLoading
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.save, size: 20),
                            label: Text(_profileLoading ? '保存中...' : '保存修改'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Password form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lock, size: 20, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          '修改密码',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Form(
                      key: _pwdFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _oldPwdCtrl,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: '旧密码',
                              prefixIcon: Icon(Icons.lock_outline),
                            ),
                            validator: (v) =>
                                v == null || v.isEmpty ? '请输入旧密码' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _newPwdCtrl,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: '新密码',
                              prefixIcon: Icon(Icons.lock_reset),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return '请输入新密码';
                              if (v.length < 6) return '密码长度至少6位';
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            onPressed: _pwdLoading ? null : _changePassword,
                            icon: _pwdLoading
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.lock_reset, size: 20),
                            label: Text(_pwdLoading ? '修改中...' : '修改密码'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Delete account
            Card(
              color: colorScheme.errorContainer.withOpacity(0.3),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: colorScheme.error),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '注销账号',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.error,
                            ),
                          ),
                          Text(
                            '此操作不可撤销',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: _confirmDeleteAccount,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.error,
                        side: BorderSide(color: colorScheme.error),
                      ),
                      child: const Text('确认注销'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
