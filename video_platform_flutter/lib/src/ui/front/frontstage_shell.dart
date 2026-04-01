import 'package:flutter/material.dart';

import '../../controller/mock_app_controller.dart';
import '../../models/models.dart';
import '../app_shell.dart';

class FrontstageShell extends StatefulWidget {
  const FrontstageShell({super.key, required this.controller});

  final MockAppController controller;

  @override
  State<FrontstageShell> createState() => _FrontstageShellState();
}

class _FrontstageShellState extends State<FrontstageShell> {
  late final TextEditingController _searchController;

  MockAppController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: controller.searchKeyword);
  }

  @override
  void didUpdateWidget(covariant FrontstageShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_searchController.text != controller.searchKeyword) {
      _searchController.text = controller.searchKeyword;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final wide = screenWidth >= 1080;
    final compact = screenWidth < 900;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 78,
        titleSpacing: 24,
        title: compact
            ? Text(
                '视界云播',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              )
            : Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0D6E6E), Color(0xFFD4A74F)],
                      ),
                    ),
                    child: const Icon(Icons.play_arrow_rounded,
                        color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '视界云播',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        controller.isGuest
                            ? '游客可浏览，互动功能需登录'
                            : controller.isBanned
                                ? '账号已封禁，仅保留浏览能力'
                                : 'Material 3 Web 视频平台演示版',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
        actions: [
          if (!compact)
            SizedBox(
              width: wide ? 320 : 220,
              child: TextField(
                key: const Key('home-search-field'),
                controller: _searchController,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  hintText: '搜索视频标题 / 作者',
                  prefixIcon: Icon(Icons.search_rounded),
                  isDense: true,
                ),
                onSubmitted: controller.updateSearchKeyword,
              ),
            ),
          if (!compact) const SizedBox(width: 12),
          if (!compact)
            FilledButton.tonalIcon(
              key: const Key('home-refresh-button'),
              onPressed: () {
                controller.refreshRecommendations();
                showFeedback(context, '推荐内容已刷新');
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('刷新'),
            )
          else
            IconButton(
              key: const Key('home-refresh-button'),
              onPressed: () {
                controller.refreshRecommendations();
                showFeedback(context, '推荐内容已刷新');
              },
              icon: const Icon(Icons.refresh_rounded),
            ),
          const SizedBox(width: 12),
          if (!compact && !controller.isGuest && !controller.isAdmin)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Chip(
                avatar: const Icon(Icons.monetization_on_rounded, size: 18),
                label: Text('${controller.currentUser.coins} 硬币'),
              ),
            ),
          PopupMenuButton<DemoRole>(
            key: const Key('demo-role-menu'),
            tooltip: '演示身份',
            onSelected: controller.setDemoRole,
            itemBuilder: (context) => DemoRole.values
                .map(
                  (role) => PopupMenuItem(
                    value: role,
                    child: Text(demoRoleLabel(role)),
                  ),
                )
                .toList(),
            child: Padding(
              padding: const EdgeInsets.only(right: 24),
              child: compact
                  ? const Icon(Icons.switch_account_rounded)
                  : Chip(
                      avatar: const Icon(Icons.switch_account_rounded),
                      label: Text('演示身份：${demoRoleLabel(controller.role)}'),
                    ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: controller.frontSection.index,
              onDestinationSelected: (index) {
                controller.setFrontSection(FrontSection.values[index]);
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: '首页',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: '个人页',
                ),
              ],
            ),
      body: Row(
        children: [
          if (wide)
            SizedBox(
              width: 120,
              child: NavigationRail(
                selectedIndex: controller.frontSection.index,
                groupAlignment: -0.8,
                onDestinationSelected: (index) {
                  controller.setFrontSection(FrontSection.values[index]);
                },
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home_rounded),
                    label: Text('首页'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.account_circle_outlined),
                    selectedIcon: Icon(Icons.account_circle_rounded),
                    label: Text('个人页'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF7F8F2), Color(0xFFF1F2EA)],
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(8, 18, 24, 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1360),
                      child: _buildPage(context),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(BuildContext context) {
    if (controller.currentPath.startsWith('/front/video/')) {
      return VideoDetailPage(controller: controller);
    }
    if (controller.frontSection == FrontSection.profile) {
      return ProfilePage(controller: controller);
    }
    return HomePage(controller: controller);
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.controller});

  final MockAppController controller;

  @override
  Widget build(BuildContext context) {
    final result = controller.searchResult;
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 900;
    final columns = width >= 1400 ? 3 : width >= 900 ? 2 : 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Wrap(
              runSpacing: 20,
              spacing: 24,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '首页推荐与分页搜索',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        controller.searchKeyword.isEmpty
                            ? '当前展示为推荐内容流。你可以直接浏览视频卡片，也可以通过顶部搜索框按关键词分页筛选。'
                            : '当前按“${controller.searchKeyword}”搜索，共 ${result.totalItems} 条结果。',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _MetricPill(
                      label: '可浏览视频',
                      value: '${controller.publishedVideos.length}',
                    ),
                    _MetricPill(
                      label: '历史浏览',
                      value: '${controller.historyVideos.length}',
                    ),
                    _MetricPill(
                      label: '收藏视频',
                      value: '${controller.favoriteVideos.length}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (compact) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextFormField(
                key: const Key('home-search-field'),
                initialValue: controller.searchKeyword,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  hintText: '搜索视频标题 / 作者',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
                onFieldSubmitted: controller.updateSearchKeyword,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
        if (controller.recommendedVideos.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '推荐精选',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: controller.recommendedVideos.take(4).length,
              separatorBuilder: (context, index) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final video = controller.recommendedVideos[index];
                return _FeatureVideoCard(
                  video: video,
                  onTap: () => controller.openVideo(video.id),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            controller.searchKeyword.isEmpty ? '推荐列表' : '搜索结果',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = ((constraints.maxWidth - (columns - 1) * 16) /
                    columns)
                .clamp(280, 420)
                .toDouble();
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: result.items
                  .map(
                    (video) => SizedBox(
                      width: cardWidth,
                      child: _VideoListCard(
                        video: video,
                        onTap: () => controller.openVideo(video.id),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('第 ${result.page} / ${result.totalPages} 页'),
                Wrap(
                  spacing: 12,
                  children: [
                    OutlinedButton(
                      onPressed: result.hasPrevious
                          ? () => controller.jumpToSearchPage(result.page - 1)
                          : null,
                      child: const Text('上一页'),
                    ),
                    FilledButton.tonal(
                      onPressed: result.hasNext
                          ? () => controller.jumpToSearchPage(result.page + 1)
                          : null,
                      child: const Text('下一页'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class VideoDetailPage extends StatefulWidget {
  const VideoDetailPage({super.key, required this.controller});

  final MockAppController controller;

  @override
  State<VideoDetailPage> createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  String? _replyTargetId;

  MockAppController get controller => widget.controller;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final video = controller.selectedVideo;
    final theme = Theme.of(context);
    final comments = controller.selectedVideoComments;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            SizedBox(
              width: 860,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: LinearGradient(
                              colors: [
                                video.coverColor,
                                video.coverColor.withValues(alpha: 0.72),
                              ],
                            ),
                          ),
                          child: Stack(
                            children: [
                              const Center(
                                child: Icon(
                                  Icons.play_circle_fill_rounded,
                                  color: Colors.white,
                                  size: 88,
                                ),
                              ),
                              Positioned(
                                left: 20,
                                right: 20,
                                bottom: 18,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Mock Web Player',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      video.duration,
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        video.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(video.description, style: theme.textTheme.bodyLarge),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _MetricPill(label: '播放', value: '${video.metrics.views}'),
                          _MetricPill(label: '点赞', value: '${video.metrics.likes}'),
                          _MetricPill(
                            label: '收藏',
                            value: '${video.metrics.favorites}',
                          ),
                          _MetricPill(label: '投币', value: '${video.metrics.coins}'),
                          _MetricPill(
                            label: '评论',
                            value: '${video.metrics.comments}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 420,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '互动操作',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          FilledButton.tonalIcon(
                            key: const Key('detail-like-button'),
                            onPressed: () {
                              showFeedback(
                                context,
                                controller.toggleVideoLike(video.id),
                              );
                            },
                            icon: Icon(video.isLiked
                                ? Icons.thumb_up_alt_rounded
                                : Icons.thumb_up_alt_outlined),
                            label: Text(video.isLiked ? '取消点赞' : '点赞'),
                          ),
                          FilledButton.tonalIcon(
                            onPressed: () {
                              showFeedback(
                                context,
                                controller.toggleFavorite(video.id),
                              );
                            },
                            icon: Icon(video.isFavorited
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded),
                            label: Text(video.isFavorited ? '取消收藏' : '收藏'),
                          ),
                          FilledButton.tonalIcon(
                            onPressed: () {
                              showFeedback(context, controller.giveCoin(video.id));
                            },
                            icon: const Icon(Icons.monetization_on_rounded),
                            label: const Text('投币'),
                          ),
                          FilledButton.tonalIcon(
                            onPressed: () {
                              showFeedback(
                                context,
                                controller.downloadVideo(video.id),
                              );
                            },
                            icon: const Icon(Icons.download_rounded),
                            label: const Text('下载'),
                          ),
                          FilledButton.tonalIcon(
                            onPressed: () {
                              showFeedback(
                                context,
                                controller.reportVideo(video.id),
                              );
                            },
                            icon: const Icon(Icons.flag_outlined),
                            label: const Text('举报'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '作者信息',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('${video.ownerName} · ${video.uploadLabel}'),
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: controller.isGuest
                              ? theme.colorScheme.errorContainer
                              : controller.isBanned
                                  ? theme.colorScheme.secondaryContainer
                                  : theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          controller.isGuest
                              ? '游客可以看详情页，但点赞、收藏、投币、评论、下载等功能会提示登录。'
                              : controller.isBanned
                                  ? '当前账号已封禁，保留浏览能力，不可继续互动。'
                                  : '你对该视频的所有互动都会即时写入 mock 数据。返回个人页可看到历史与收藏变化。',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '评论区（支持多级评论）',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  key: const Key('comment-input-field'),
                  controller: _commentController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: _replyTargetId == null
                        ? '说点什么吧...'
                        : '回复评论 $_replyTargetId',
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  children: [
                    FilledButton(
                      key: const Key('comment-submit-button'),
                      onPressed: () {
                        final message = controller.addComment(
                          video.id,
                          _commentController.text,
                          parentId: _replyTargetId,
                        );
                        showFeedback(context, message);
                        if (!message.contains('不能为空') &&
                            !message.contains('登录') &&
                            !message.contains('封禁')) {
                          _commentController.clear();
                          setState(() => _replyTargetId = null);
                        }
                      },
                      child: Text(_replyTargetId == null ? '发表评论' : '发送回复'),
                    ),
                    if (_replyTargetId != null)
                      OutlinedButton(
                        onPressed: () => setState(() => _replyTargetId = null),
                        child: const Text('取消回复'),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                ...comments.map(
                  (comment) => _CommentTile(
                    comment: comment,
                    video: video,
                    controller: controller,
                    onReply: (id) => setState(() => _replyTargetId = id),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.controller});

  final MockAppController controller;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final TextEditingController _nicknameController;
  late final TextEditingController _bioController;
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _publishTitleController = TextEditingController();
  final TextEditingController _publishCategoryController =
      TextEditingController();
  final TextEditingController _publishDescriptionController =
      TextEditingController();

  MockAppController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _nicknameController =
        TextEditingController(text: controller.currentUser.nickname);
    _bioController = TextEditingController(text: controller.currentUser.bio);
  }

  @override
  void didUpdateWidget(covariant ProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _nicknameController.text = controller.currentUser.nickname;
    _bioController.text = controller.currentUser.bio;
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _bioController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _publishTitleController.dispose();
    _publishCategoryController.dispose();
    _publishDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller.isGuest) {
      return _GuestProfilePage(controller: controller);
    }

    final theme = Theme.of(context);
    final user = controller.currentUser;
    final stats = controller.stats;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Wrap(
              spacing: 28,
              runSpacing: 24,
              children: [
                SizedBox(
                  width: 360,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '个人中心',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        controller.isBanned
                            ? '账号已被封禁，保留信息查看能力，编辑与互动操作将被拦截。'
                            : '你可以在这里维护资料、投稿、查看历史记录和数据统计。',
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _MetricPill(label: '昵称', value: user.nickname),
                          _MetricPill(label: '账号', value: user.account),
                          _MetricPill(label: '硬币', value: '${user.coins}'),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 320,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '每日签到',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        controller.checkedInToday
                            ? '今天已领取 5 枚硬币奖励'
                            : '签到可立即获得 5 枚硬币',
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        key: const Key('profile-checkin-button'),
                        onPressed: () {
                          showFeedback(context, controller.performCheckIn());
                        },
                        icon: const Icon(Icons.calendar_month_rounded),
                        label: const Text('立即签到'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            _ProfileSectionCard(
              title: '基本信息',
              width: 430,
              child: Column(
                children: [
                  TextField(
                    key: const Key('profile-nickname-field'),
                    controller: _nicknameController,
                    decoration: const InputDecoration(labelText: '昵称'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _bioController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: '个人简介'),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton(
                      onPressed: () {
                        showFeedback(
                          context,
                          controller.updateProfile(
                            nickname: _nicknameController.text,
                            bio: _bioController.text,
                          ),
                        );
                      },
                      child: const Text('保存资料'),
                    ),
                  ),
                ],
              ),
            ),
            _ProfileSectionCard(
              title: '修改密码',
              width: 430,
              child: Column(
                children: [
                  TextField(
                    controller: _currentPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: '当前密码'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: '新密码'),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton.tonal(
                      onPressed: () {
                        showFeedback(
                          context,
                          controller.changePassword(
                            _currentPasswordController.text,
                            _newPasswordController.text,
                          ),
                        );
                      },
                      child: const Text('更新密码'),
                    ),
                  ),
                ],
              ),
            ),
            _ProfileSectionCard(
              title: '账号操作',
              width: 340,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: () {
                      showFeedback(context, controller.logout());
                    },
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('退出登录'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      showFeedback(context, controller.deleteAccount());
                    },
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('注销账号'),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            _ProfileSectionCard(
              title: '发布视频',
              width: 520,
              child: Column(
                children: [
                  TextField(
                    key: const Key('publish-title-field'),
                    controller: _publishTitleController,
                    decoration: const InputDecoration(labelText: '视频标题'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _publishCategoryController,
                    decoration: const InputDecoration(labelText: '分类'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _publishDescriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: '视频简介'),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton(
                      key: const Key('publish-submit-button'),
                      onPressed: () {
                        showFeedback(
                          context,
                          controller.publishVideo(
                            title: _publishTitleController.text,
                            description: _publishDescriptionController.text,
                            category: _publishCategoryController.text,
                          ),
                        );
                        _publishTitleController.clear();
                        _publishCategoryController.clear();
                        _publishDescriptionController.clear();
                      },
                      child: const Text('提交审核'),
                    ),
                  ),
                ],
              ),
            ),
            _ProfileSectionCard(
              title: '发布数据统计',
              width: 700,
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _MetricPill(label: '发布总数', value: '${stats.videoCount}'),
                  _MetricPill(label: '总点赞', value: '${stats.totalLikes}'),
                  _MetricPill(
                    label: '总收藏',
                    value: '${stats.totalFavorites}',
                  ),
                  _MetricPill(label: '总投币', value: '${stats.totalCoins}'),
                  _MetricPill(label: '总播放', value: '${stats.totalViews}'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _ProfileVideoStrip(
          title: '我的发布',
          videos: controller.myVideos,
          onTap: controller.openVideo,
        ),
        const SizedBox(height: 20),
        _ProfileVideoStrip(
          title: '历史浏览',
          videos: controller.historyVideos,
          onTap: controller.openVideo,
        ),
        const SizedBox(height: 20),
        _ProfileVideoStrip(
          title: '我的收藏',
          videos: controller.favoriteVideos,
          onTap: controller.openVideo,
        ),
      ],
    );
  }
}

class _GuestProfilePage extends StatelessWidget {
  const _GuestProfilePage({required this.controller});

  final MockAppController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Wrap(
          spacing: 28,
          runSpacing: 28,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '登录 / 注册',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '游客可以浏览首页和视频详情，但个人功能、发布、评论、收藏、投币等操作都需要先登录。',
                  ),
                  const SizedBox(height: 18),
                  const TextField(
                    decoration: InputDecoration(labelText: '账号'),
                  ),
                  const SizedBox(height: 12),
                  const TextField(
                    decoration: InputDecoration(labelText: '密码'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 12,
                    children: [
                      FilledButton(
                        key: const Key('guest-login-button'),
                        onPressed: () {
                          showFeedback(context, controller.loginMember());
                        },
                        child: const Text('登录'),
                      ),
                      FilledButton.tonal(
                        onPressed: () {
                          showFeedback(context, controller.registerMember());
                        },
                        child: const Text('注册'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 420,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '登录后可用',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 12),
                  Text('查看并编辑个人信息'),
                  SizedBox(height: 8),
                  Text('发布视频并查看投稿数据'),
                  SizedBox(height: 8),
                  Text('签到获取硬币，进行点赞、收藏、投币、评论'),
                  SizedBox(height: 8),
                  Text('查看自己的历史浏览和收藏列表'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileSectionCard extends StatelessWidget {
  const _ProfileSectionCard({
    required this.title,
    required this.child,
    required this.width,
  });

  final String title;
  final Widget child;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
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
              const SizedBox(height: 16),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileVideoStrip extends StatelessWidget {
  const _ProfileVideoStrip({
    required this.title,
    required this.videos,
    required this.onTap,
  });

  final String title;
  final List<VideoItem> videos;
  final ValueChanged<String> onTap;

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
            const SizedBox(height: 14),
            if (videos.isEmpty)
              const Text('暂无内容')
            else
              SizedBox(
                height: 380,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    final video = videos[index];
                    return SizedBox(
                      width: 280,
                      child: _VideoListCard(
                        video: video,
                        onTap: () => onTap(video.id),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => const SizedBox(width: 14),
                  itemCount: videos.length,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FeatureVideoCard extends StatelessWidget {
  const _FeatureVideoCard({required this.video, required this.onTap});

  final VideoItem video;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: onTap,
      child: Ink(
        width: 360,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: LinearGradient(
            colors: [video.coverColor, video.coverColor.withValues(alpha: 0.68)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Chip(label: Text(video.category)),
              const Spacer(),
              Text(
                video.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '${video.ownerName} · ${video.duration}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoListCard extends StatelessWidget {
  const _VideoListCard({required this.video, required this.onTap});

  final VideoItem video;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        key: Key('open-video-${video.id}'),
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    color: video.coverColor,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Text(
                      video.duration,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                video.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                video.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _TinyInfo(label: video.ownerName),
                  _TinyInfo(label: '${video.metrics.views} 播放'),
                  _TinyInfo(label: '${video.metrics.likes} 点赞'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({
    required this.comment,
    required this.video,
    required this.controller,
    required this.onReply,
    this.depth = 0,
  });

  final CommentNode comment;
  final VideoItem video;
  final MockAppController controller;
  final ValueChanged<String> onReply;
  final int depth;

  @override
  Widget build(BuildContext context) {
    final indent = depth * 26.0;
    return Padding(
      padding: EdgeInsets.only(left: indent, bottom: 14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              comment.authorName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Text(comment.content),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(comment.createdLabel),
                TextButton.icon(
                  onPressed: () {
                    showFeedback(
                      context,
                      controller.toggleCommentLike(video.id, comment.id),
                    );
                  },
                  icon: Icon(
                    comment.isLiked
                        ? Icons.thumb_up_alt_rounded
                        : Icons.thumb_up_alt_outlined,
                    size: 18,
                  ),
                  label: Text('${comment.likeCount}'),
                ),
                TextButton(
                  onPressed: () => onReply(comment.id),
                  child: const Text('回复'),
                ),
                if (controller.canDeleteComment(comment, video))
                  TextButton(
                    onPressed: () {
                      showFeedback(
                        context,
                        controller.deleteComment(video.id, comment.id),
                      );
                    },
                    child: const Text('删除'),
                  ),
              ],
            ),
            if (comment.replies.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...comment.replies.map(
                (reply) => _CommentTile(
                  comment: reply,
                  video: video,
                  controller: controller,
                  onReply: onReply,
                  depth: depth + 1,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _TinyInfo extends StatelessWidget {
  const _TinyInfo({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(label),
    );
  }
}
