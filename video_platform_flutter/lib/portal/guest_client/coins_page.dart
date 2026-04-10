import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/coin_provider.dart';
import '../shared/widgets/login_prompt_dialog.dart';

class CoinsPage extends StatefulWidget {
  const CoinsPage({super.key});

  @override
  State<CoinsPage> createState() => _CoinsPageState();
}

class _CoinsPageState extends State<CoinsPage> {
  int? _loadedUserId;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userId = auth.currentUser?.id;
    if (userId == null) {
      _loadedUserId = null;
    } else if (_loadedUserId != userId) {
      _loadedUserId = userId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || auth.currentUser?.id != userId) {
          return;
        }
        context.read<CoinProvider>().getBalance(userId);
      });
    }

    if (auth.isGuest) {
      return const _CoinsRedirectPlaceholder();
    }

    final coin = context.watch<CoinProvider>();
    final currentUserId = auth.currentUser!.id;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Balance
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange[300]!, Colors.orangeAccent[700]!],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.monetization_on,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                const Text(
                  '当前余额',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                Text(
                  '${coin.balance}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Check-in button
          FilledButton.icon(
            onPressed: coin.hasCheckedInToday
                ? null
                : () async {
                    final messenger = ScaffoldMessenger.of(context);
                    await context.read<CoinProvider>().checkIn(currentUserId);
                    if (mounted) {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('签到成功')),
                      );
                    }
                  },
            icon: const Icon(Icons.event_note),
            label: Text(coin.hasCheckedInToday ? '今日已签到' : '每日签到'),
          ),
          if (coin.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                coin.error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          const SizedBox(height: 32),
          // Sign in history
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '签到记录',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          if (coin.signInHistory.isEmpty)
            const Center(
              child: Column(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 48,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 8),
                  Text('暂无签到记录'),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: coin.signInHistory.length,
              itemBuilder: (context, index) {
                final date = coin.signInHistory[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                    ),
                    title: Text(date),
                    trailing: const Text('+10 硬币'),
                  ),
                );
              },
            ),
          const SizedBox(height: 32),

          // Transaction history
          if (coin.records.isEmpty)
            const Center(
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 48,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 8),
                  Text('暂无记录'),
                ],
              ),
            )
          else
            ...coin.records.map(
              (r) => Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.monetization_on,
                    color: Colors.orange,
                  ),
                  title: Text('投币 ${r.count} 个'),
                  subtitle: Text(
                    '视频 #${r.videoId} - ${DateFormat('yyyy-MM-dd HH:mm').format(r.createDate)}',
                  ),
                  trailing: Text('-${r.count}'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CoinsRedirectPlaceholder extends StatelessWidget {
  const _CoinsRedirectPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.monetization_on, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            '硬币钱包',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
