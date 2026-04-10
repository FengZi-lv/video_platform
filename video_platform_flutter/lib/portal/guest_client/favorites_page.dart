import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/video_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../shared/widgets/login_prompt_dialog.dart';
import '../shared/widgets/video_card.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
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
        context.read<UserProvider>().loadFavorites(userId);
      });
    }

    if (auth.isGuest) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite_border, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              '我的收藏',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              '正在跳转登录页...',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
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

    final userProvider = context.watch<UserProvider>();
    final favoriteVideos = userProvider.favoriteVideos;

    if (favoriteVideos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('暂无收藏'),
          ],
        ),
      );
    }

    // Use same VideoCard widget as home page, with unified grid layout
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: favoriteVideos.length,
      itemBuilder: (context, index) {
        final video = favoriteVideos[index];
        return _FavoriteVideoTile(
          video: video,
          onToggle: () async {
            await context.read<UserProvider>().removeFromFavorites(
              auth.currentUser!.id,
              video.id,
            );
          },
          isFav: true,
        );
      },
    );
  }
}

class _FavoriteVideoTile extends StatelessWidget {
  final VideoModel video;
  final VoidCallback onToggle;
  final bool isFav;
  const _FavoriteVideoTile({
    required this.video,
    required this.onToggle,
    required this.isFav,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        VideoCard(video: video),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(isFav ? Icons.bookmark : Icons.bookmark_border),
              iconSize: 20,
              onPressed: onToggle,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ),
      ],
    );
  }
}
