import 'package:flutter/material.dart';

import '../../controller/app_controller.dart';
import '../../models/models.dart';
import '../app_shell.dart';

class FrontstageShell extends StatefulWidget {
  const FrontstageShell({super.key, required this.controller});
  final AppController controller;
  @override
  State<FrontstageShell> createState() => _FrontstageShellState();
}

class _FrontstageShellState extends State<FrontstageShell> {
  late final TextEditingController _searchController;
  AppController get controller => widget.controller;

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
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= 1080;
    return Scaffold(
      appBar: AppBar(
        title: const Text('视界云播'),
        actions: [
          if (width >= 900)
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
          IconButton(
            key: const Key('home-refresh-button'),
            onPressed: () async {
              await controller.refreshHome();
              if (context.mounted) showFeedback(context, '内容已刷新');
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: controller.currentUser == null
                ? FilledButton.tonal(
                    onPressed: () => controller.navigate('/front/profile'),
                    child: const Text('登录'),
                  )
                : Chip(label: Text(controller.currentUser!.nickname)),
          ),
        ],
      ),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: controller.frontSection.index,
              onDestinationSelected: (index) => controller.navigate(
                index == 0 ? '/front/home' : '/front/profile',
              ),
              destinations: const [
                NavigationDestination(icon: Icon(Icons.home_outlined), label: '首页'),
                NavigationDestination(icon: Icon(Icons.person_outline), label: '个人页'),
              ],
            ),
      body: Row(
        children: [
          if (wide)
            NavigationRail(
              selectedIndex: controller.frontSection.index,
              onDestinationSelected: (index) => controller.navigate(
                index == 0 ? '/front/home' : '/front/profile',
              ),
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.home_outlined), label: Text('首页')),
                NavigationRailDestination(icon: Icon(Icons.person_outline), label: Text('个人页')),
              ],
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1320),
                  child: controller.currentPath.startsWith('/front/video/')
                      ? _VideoDetail(controller: controller)
                      : controller.frontSection == FrontSection.profile
                          ? _ProfilePage(controller: controller)
                          : _HomePage(
                              controller: controller,
                              searchController: _searchController,
                            ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage({required this.controller, required this.searchController});
  final AppController controller;
  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    final result = controller.searchResult;
    if (controller.homeLoading) return const Center(child: CircularProgressIndicator());
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (MediaQuery.sizeOf(context).width < 900) ...[
        TextField(
          key: const Key('home-search-field'),
          controller: searchController,
          decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: '搜索视频'),
          onSubmitted: controller.updateSearchKeyword,
        ),
        const SizedBox(height: 16),
      ],
      Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(controller.searchKeyword.isEmpty ? '推荐内容流' : '搜索“${controller.searchKeyword}”'),
        ),
      ),
      const SizedBox(height: 16),
      Wrap(
        spacing: 16,
        runSpacing: 16,
        children: controller.recommendations
            .map((video) => SizedBox(width: 320, child: _VideoCard(video: video, onTap: () => controller.openVideo(video.id))))
            .toList(),
      ),
      const SizedBox(height: 16),
      Wrap(
        spacing: 16,
        runSpacing: 16,
        children: result.items
            .map((video) => SizedBox(width: 320, child: _VideoCard(video: video, onTap: () => controller.openVideo(video.id))))
            .toList(),
      ),
      const SizedBox(height: 16),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('第 ${result.page} / ${result.totalPages} 页'),
        Wrap(spacing: 12, children: [
          OutlinedButton(onPressed: result.hasPrevious ? () => controller.jumpToSearchPage(result.page - 1) : null, child: const Text('上一页')),
          FilledButton.tonal(onPressed: result.hasNext ? () => controller.jumpToSearchPage(result.page + 1) : null, child: const Text('下一页')),
        ]),
      ]),
    ]);
  }
}

class _VideoDetail extends StatefulWidget {
  const _VideoDetail({required this.controller});
  final AppController controller;
  @override
  State<_VideoDetail> createState() => _VideoDetailState();
}

class _VideoDetailState extends State<_VideoDetail> {
  final TextEditingController _commentController = TextEditingController();
  String? _replyTargetId;
  AppController get controller => widget.controller;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller.detailLoading) return const Center(child: CircularProgressIndicator());
    final video = controller.selectedVideo;
    if (video == null) return Card(child: Padding(padding: const EdgeInsets.all(24), child: Text(controller.bootstrapError ?? '视频不存在')));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(video.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(video.description),
            const SizedBox(height: 12),
            Wrap(spacing: 12, children: [
              FilledButton.icon(key: const Key('detail-like-button'), onPressed: () => _run(() => controller.toggleVideoLike(video.id)), icon: const Icon(Icons.thumb_up_alt_outlined), label: const Text('点赞')),
              FilledButton.tonalIcon(onPressed: () => _run(() => controller.toggleFavorite(video.id)), icon: const Icon(Icons.favorite_outline_rounded), label: const Text('收藏')),
              OutlinedButton.icon(onPressed: () => _run(() => controller.giveCoin(video.id)), icon: const Icon(Icons.monetization_on_rounded), label: const Text('投币')),
              OutlinedButton.icon(onPressed: () => _run(() => controller.reportVideo(video.id)), icon: const Icon(Icons.flag_outlined), label: const Text('举报')),
            ]),
          ]),
        ),
      ),
      const SizedBox(height: 16),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('互动操作'),
            const SizedBox(height: 12),
            TextField(controller: _commentController, maxLines: 3, decoration: InputDecoration(hintText: _replyTargetId == null ? '写下你的评论' : '回复 $_replyTargetId')),
            const SizedBox(height: 12),
            FilledButton(onPressed: () async { final msg = await controller.addComment(video.id, _commentController.text, parentId: _replyTargetId); if (!context.mounted) return; showFeedback(context, msg); if (msg.contains('已')) { _commentController.clear(); setState(() => _replyTargetId = null); } }, child: const Text('发送')),
            const SizedBox(height: 16),
            ...controller.selectedVideoComments.map((comment) => _CommentView(comment: comment, video: video, controller: controller, onReply: (id) => setState(() => _replyTargetId = id))),
          ]),
        ),
      ),
    ]);
  }

  Future<void> _run(Future<String> Function() action) async {
    final msg = await action();
    if (mounted) showFeedback(context, msg);
  }
}

class _ProfilePage extends StatefulWidget {
  const _ProfilePage({required this.controller});
  final AppController controller;
  @override
  State<_ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<_ProfilePage> {
  final _account = TextEditingController();
  final _password = TextEditingController();
  final _nickname = TextEditingController();
  final _bio = TextEditingController();
  final _currentPassword = TextEditingController();
  final _nextPassword = TextEditingController();
  final _title = TextEditingController();
  final _category = TextEditingController();
  final _description = TextEditingController();
  AppController get controller => widget.controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = controller.currentUser;
    if (user != null) {
      _nickname.text = user.nickname;
      _bio.text = user.bio;
    }
  }

  @override
  void dispose() {
    for (final c in [_account, _password, _nickname, _bio, _currentPassword, _nextPassword, _title, _category, _description]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller.profileLoading) return const Center(child: CircularProgressIndicator());
    final user = controller.currentUser;
    if (user == null) {
      return Card(child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('登录 / 注册'),
        const SizedBox(height: 12),
        TextField(controller: _account, decoration: const InputDecoration(labelText: '账号')),
        const SizedBox(height: 12),
        TextField(controller: _nickname, decoration: const InputDecoration(labelText: '昵称（注册时使用）')),
        const SizedBox(height: 12),
        TextField(controller: _password, decoration: const InputDecoration(labelText: '密码'), obscureText: true),
        const SizedBox(height: 12),
        Wrap(spacing: 12, children: [
          FilledButton(key: const Key('guest-login-button'), onPressed: () => _run(() => controller.login(account: _account.text, password: _password.text)), child: const Text('登录')),
          FilledButton.tonal(key: const Key('guest-register-button'), onPressed: () => _run(() => controller.register(account: _account.text, password: _password.text, nickname: _nickname.text)), child: const Text('注册')),
        ]),
      ])));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('个人中心', style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 16),
      Wrap(spacing: 16, runSpacing: 16, children: [
        _Panel(title: '账号信息', width: 420, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${user.nickname} · ${user.account}'),
          const SizedBox(height: 8),
          TextField(controller: _nickname, decoration: const InputDecoration(labelText: '昵称')),
          const SizedBox(height: 8),
          TextField(controller: _bio, maxLines: 3, decoration: const InputDecoration(labelText: '简介')),
          const SizedBox(height: 8),
          FilledButton.tonal(onPressed: () => _run(() => controller.updateProfile(nickname: _nickname.text, bio: _bio.text)), child: const Text('保存资料')),
        ])),
        _Panel(title: '账号操作', width: 320, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          FilledButton.tonalIcon(key: const Key('profile-checkin-button'), onPressed: controller.isBanned ? null : () => _run(controller.performCheckIn), icon: const Icon(Icons.calendar_month_rounded), label: const Text('每日签到')),
          if (controller.isAdmin) ...[
            const SizedBox(height: 12),
            FilledButton.icon(key: const Key('enter-admin-button'), onPressed: () => controller.navigate('/admin/dashboard'), icon: const Icon(Icons.admin_panel_settings_rounded), label: const Text('进入管理端')),
          ],
          const SizedBox(height: 12),
          FilledButton.tonalIcon(onPressed: () => _run(controller.logout), icon: const Icon(Icons.logout_rounded), label: const Text('退出登录')),
        ])),
        _Panel(title: '修改密码', width: 360, child: Column(children: [
          TextField(controller: _currentPassword, decoration: const InputDecoration(labelText: '当前密码'), obscureText: true),
          const SizedBox(height: 8),
          TextField(controller: _nextPassword, decoration: const InputDecoration(labelText: '新密码'), obscureText: true),
          const SizedBox(height: 8),
          Align(alignment: Alignment.centerLeft, child: FilledButton.tonal(onPressed: () => _run(() => controller.changePassword(_currentPassword.text, _nextPassword.text)), child: const Text('更新密码'))),
        ])),
      ]),
      const SizedBox(height: 16),
      _Panel(title: '发布视频', width: double.infinity, child: Column(children: [
        TextField(key: const Key('publish-title-field'), controller: _title, decoration: const InputDecoration(labelText: '视频标题')),
        const SizedBox(height: 8),
        TextField(controller: _category, decoration: const InputDecoration(labelText: '分类')),
        const SizedBox(height: 8),
        TextField(controller: _description, maxLines: 3, decoration: const InputDecoration(labelText: '视频简介')),
        const SizedBox(height: 8),
        Align(alignment: Alignment.centerLeft, child: FilledButton(key: const Key('publish-submit-button'), onPressed: controller.isBanned ? null : () => _run(() => controller.publishVideo(title: _title.text, description: _description.text, category: _category.text)), child: const Text('提交审核'))),
      ])),
      const SizedBox(height: 16),
      _Strip(title: '我的发布', videos: controller.myVideos, onTap: controller.openVideo),
      const SizedBox(height: 16),
      _Strip(title: '历史浏览', videos: controller.historyVideos, onTap: controller.openVideo),
      const SizedBox(height: 16),
      _Strip(title: '我的收藏', videos: controller.favoriteVideos, onTap: controller.openVideo),
    ]);
  }

  Future<void> _run(Future<String> Function() action) async {
    final msg = await action();
    if (mounted) showFeedback(context, msg);
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child, required this.width});
  final String title;
  final Widget child;
  final double width;
  @override
  Widget build(BuildContext context) => SizedBox(width: width, child: Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title), const SizedBox(height: 12), child]))));
}

class _Strip extends StatelessWidget {
  const _Strip({required this.title, required this.videos, required this.onTap});
  final String title;
  final List<VideoItem> videos;
  final ValueChanged<String> onTap;
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title), const SizedBox(height: 12), if (videos.isEmpty) const Text('暂无内容') else Wrap(spacing: 12, runSpacing: 12, children: videos.map((video) => SizedBox(width: 280, child: _VideoCard(video: video, onTap: () => onTap(video.id)))).toList())])));
}

class _VideoCard extends StatelessWidget {
  const _VideoCard({required this.video, required this.onTap});
  final VideoItem video;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(child: InkWell(key: Key('open-video-${video.id}'), onTap: onTap, child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(height: 140, decoration: BoxDecoration(color: video.coverColor, borderRadius: BorderRadius.circular(18))), const SizedBox(height: 12), Text(video.title, maxLines: 2, overflow: TextOverflow.ellipsis), const SizedBox(height: 8), Text(video.description, maxLines: 2, overflow: TextOverflow.ellipsis), const SizedBox(height: 8), Text('${video.ownerName} · ${video.metrics.views} 播放')]))));
}

class _CommentView extends StatelessWidget {
  const _CommentView({required this.comment, required this.video, required this.controller, required this.onReply, this.depth = 0});
  final CommentNode comment;
  final VideoItem video;
  final AppController controller;
  final ValueChanged<String> onReply;
  final int depth;
  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(left: depth * 20, top: 12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(border: Border.all(color: Theme.of(context).colorScheme.outlineVariant), borderRadius: BorderRadius.circular(16)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(comment.authorName),
            const SizedBox(height: 6),
            Text(comment.content),
            Wrap(spacing: 8, children: [
              TextButton(onPressed: () async { final msg = await controller.toggleCommentLike(comment.id); if (context.mounted) showFeedback(context, msg); }, child: Text('点赞 ${comment.likeCount}')),
              TextButton(onPressed: () => onReply(comment.id), child: const Text('回复')),
              if (controller.canDeleteComment(comment, video)) TextButton(onPressed: () async { final msg = await controller.deleteComment(comment.id); if (context.mounted) showFeedback(context, msg); }, child: const Text('删除')),
            ]),
            ...comment.replies.map((item) => _CommentView(comment: item, video: video, controller: controller, onReply: onReply, depth: depth + 1)),
          ]),
        ),
      );
}
