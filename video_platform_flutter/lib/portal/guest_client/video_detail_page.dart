import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/video_provider.dart';
import '../../providers/coin_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/admin_provider.dart';
import '../shared/widgets/video_player_widget.dart';
import '../shared/widgets/comment_section.dart';
import '../shared/widgets/login_prompt_dialog.dart';
import '../shared/widgets/user_avatar.dart';
import '../../routes/app_routes.dart';
import '../../models/user_model.dart';

class VideoDetailPage extends StatefulWidget {
  final int videoId;
  const VideoDetailPage({super.key, required this.videoId});

  @override
  State<VideoDetailPage> createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> {
  UserModel? _uploader;
  bool _loadingUploader = true;

  @override
  void initState() {
    super.initState();
    _loadVideoData();
  }

  @override
  void didUpdateWidget(covariant VideoDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoId != widget.videoId) {
      _loadingUploader = true;
      _uploader = null;
      _loadVideoData();
    }
  }

  void _loadVideoData() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final videoProvider = context.read<VideoProvider>();
      await videoProvider.getVideoById(widget.videoId);

      final auth = context.read<AuthProvider>();
      if (!auth.isGuest) {
        await context.read<UserProvider>().loadFavorites(auth.currentUser!.id);
      }

      final video = videoProvider.currentVideo;
      if (video != null) {
        final uploaderId = video.uploaderId;
        final uploader = uploaderId != null && uploaderId > 0
            ? await context.read<UserProvider>().getUserById(uploaderId)
            : null;
        if (mounted) {
          setState(() {
            _uploader = uploader;
            _loadingUploader = false;
          });
        }
      } else if (mounted) {
        setState(() => _loadingUploader = false);
      }
    });
  }

  Future<void> _onLike(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    if (auth.isGuest) {
      showDialog(context: context, builder: (_) => const LoginPromptDialog());
      return;
    }
    await context.read<VideoProvider>().toggleLike(widget.videoId);
  }

  Future<void> _onFavorite(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    if (auth.isGuest) {
      showDialog(context: context, builder: (_) => const LoginPromptDialog());
      return;
    }
    final userProvider = context.read<UserProvider>();
    final videoProvider = context.read<VideoProvider>();
    final isFavorite = userProvider.favoriteIds.contains(widget.videoId);
    if (isFavorite) {
      await userProvider.removeFromFavorites(
        auth.currentUser!.id,
        widget.videoId,
      );
      videoProvider.syncFavoriteState(widget.videoId, isFavorited: false);
    } else {
      await userProvider.addToFavorites(auth.currentUser!.id, widget.videoId);
      videoProvider.syncFavoriteState(widget.videoId, isFavorited: true);
    }
  }

  void _onCoin(BuildContext context) {
    final auth = context.read<AuthProvider>();
    if (auth.isGuest) {
      showDialog(context: context, builder: (_) => const LoginPromptDialog());
      return;
    }

    showDialog(
      context: context,
      builder: (dialogCtx) {
        int selected = 1;
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('投币'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('选择投币数量'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text('1币'),
                      selected: selected == 1,
                      onSelected: (_) => setState(() => selected = 1),
                    ),
                    const SizedBox(width: 16),
                    ChoiceChip(
                      label: const Text('2币'),
                      selected: selected == 2,
                      onSelected: (_) => setState(() => selected = 2),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(),
                child: const Text('取消'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final coinProvider = context.read<CoinProvider>();
                  final userId = auth.currentUser!.id;
                  try {
                    await coinProvider.coinVideo(
                      userId,
                      widget.videoId,
                      selected,
                    );
                    if (context.mounted) {
                      Navigator.of(dialogCtx).pop();
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('已投 $selected 币')));
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('投币失败: $e')));
                    }
                  }
                },
                child: const Text('确认'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onReport(BuildContext context) {
    final auth = context.read<AuthProvider>();
    if (auth.isGuest) {
      showDialog(context: context, builder: (_) => const LoginPromptDialog());
      return;
    }

    final reportCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('举报'),
        content: TextField(
          controller: reportCtrl,
          decoration: const InputDecoration(
            hintText: '请描述举报原因',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final reason = reportCtrl.text.trim();
              if (reason.isEmpty) return;
              try {
                await context.read<AdminProvider>().reportVideo(
                  auth.currentUser!.id,
                  widget.videoId,
                  reason,
                );
                if (context.mounted) {
                  Navigator.of(dialogCtx).pop();
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('举报已提交')));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('举报提交失败: $e')));
                }
              }
            },
            child: const Text('提交'),
          ),
        ],
      ),
    );
  }

  Widget _buildUploaderSection(BuildContext context) {
    if (_loadingUploader) {
      return const Padding(
        padding: EdgeInsets.only(top: 16.0),
        child: LinearProgressIndicator(),
      );
    }

    if (_uploader != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          children: [
            InkWell(
              onTap: () => context.push(AppRoutes.userHomeRoute(_uploader!.id)),
              borderRadius: BorderRadius.circular(16),
              child: UserAvatar(nickname: _uploader!.nickname),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: () => context.push(AppRoutes.userHomeRoute(_uploader!.id)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _uploader!.nickname,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _uploader!.bio.isNotEmpty ? _uploader!.bio : '这个用户还没有填写简介',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.amber[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber.shade200),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, size: 18, color: Colors.orange),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                '当前视频详情接口没有返回上传者 ID，暂时无法显示作者个人信息。',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final videoProvider = context.watch<VideoProvider>();
    final userProvider = context.watch<UserProvider>();
    final auth = context.watch<AuthProvider>();
    final video = videoProvider.currentVideo;

    if (videoProvider.loading && video == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (video == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text('未找到视频'),
          ],
        ),
      );
    }

    final isLiked =
        video.isLiked || videoProvider.likedVideos.contains(video.id);
    final isFav =
        video.isFavorited || userProvider.favoriteIds.contains(video.id);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video Player
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: VideoPlayerWidget(videoUrl: video.videoUrl),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.title.isNotEmpty ? video.title : '视频 #${video.id}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      DateFormat('yyyy-MM-dd').format(video.createDate),
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(Icons.thumb_up, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text('${video.likesCount}'),
                        const SizedBox(width: 12),
                        Icon(Icons.bookmark, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text('${video.favoritesCount}'),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.monetization_on,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text('${video.coinsCount}'),
                      ],
                    ),
                  ],
                ),
                // Action buttons
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async => _onLike(context),
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                      ),
                      label: Text(isLiked ? '已赞' : '点赞'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isLiked ? Colors.red[50] : null,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async => _onFavorite(context),
                      icon: Icon(
                        isFav ? Icons.bookmark : Icons.bookmark_border,
                      ),
                      label: Text(isFav ? '已收藏' : '收藏'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFav ? Colors.orange[50] : null,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _onCoin(context),
                      icon: const Icon(Icons.monetization_on_outlined),
                      label: const Text('投币'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _onReport(context),
                      icon: const Icon(Icons.flag_outlined),
                      label: const Text('举报'),
                    ),
                    OutlinedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.download_outlined),
                      label: const Text('后端暂不支持下载'),
                    ),
                  ],
                ),
                _buildUploaderSection(context),
                // Description
                const Text(
                  '简介',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  video.intro,
                  style: const TextStyle(fontSize: 14, height: 1.6),
                ),
                const SizedBox(height: 16),
                const Text(
                  '评论',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
          // Comment Section
          CommentSection(
            videoId: video.id,
            isVideoUploader:
                auth.currentUser != null &&
                video.uploaderId != null &&
                auth.currentUser!.id == video.uploaderId,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
