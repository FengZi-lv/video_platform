import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/video_provider.dart';
import '../shared/widgets/login_prompt_dialog.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  bool _loading = false;
  Map<String, int> _stats = {};
  int? _loadedUserId;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadStats(int userId) async {
    setState(() => _loading = true);
    try {
      final stats = await context.read<VideoProvider>().getVideoStats(userId);
      if (mounted) {
        setState(() => _stats = stats);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('加载统计失败: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userId = auth.currentUser?.id;
    if (userId == null) {
      _loadedUserId = null;
    } else if (_loadedUserId != userId) {
      _loadedUserId = userId;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted || auth.currentUser?.id != userId) {
          return;
        }
        await _loadStats(userId);
      });
    }

    if (auth.isGuest) {
      return const _ProtectedPagePlaceholder(
        icon: Icons.bar_chart,
        title: '统计信息',
      );
    }

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '我的数据统计',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _statCard(
                    '总获赞',
                    _stats['total_likes']?.toString() ?? '-',
                    Icons.visibility,
                    Colors.blue,
                  ),
                  _statCard(
                    '获硬币',
                    _stats['total_coins']?.toString() ?? '-',
                    Icons.thumb_up,
                    Colors.red,
                  ),
                  _statCard(
                    '投稿数',
                    _stats['total_videos']?.toString() ?? '-',
                    Icons.favorite,
                    Colors.purple,
                  ),
                  _statCard(
                    '浏览数',
                    '暂不支持',
                    Icons.monetization_on,
                    Colors.orange,
                  ),
                  _statCard('收藏数', '暂不支持', Icons.video_library, Colors.green),
                ],
              ),
            ],
          ),
        ),
        if (_loading) const ModalBarrier(dismissible: false),
        if (_loading) const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}

class _ProtectedPagePlaceholder extends StatelessWidget {
  const _ProtectedPagePlaceholder({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('正在跳转登录页...'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => const LoginPromptDialog(),
            ),
            child: const Text('去登录'),
          ),
        ],
      ),
    );
  }
}
