import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/video_provider.dart';
import '../shared/widgets/video_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VideoProvider>().loadHomeFeed();
    });
  }

  @override
  Widget build(BuildContext context) {
    final video = context.watch<VideoProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FilledButton.tonalIcon(
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('刷新'),
                onPressed: video.loading
                    ? null
                    : () => context.read<VideoProvider>().refreshHomeFeed(),
              ),
            ],
          ),
        ),
        Expanded(
          child: video.loading && video.homeFeed.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '正在加载视频...',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              : video.error != null && video.homeFeed.isEmpty
              ? _errorState(context)
              : video.isSearching
              ? _searchResultState(context, video)
              : _feedState(context, video),
        ),
      ],
    );
  }

  Widget _errorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          Text(
            '加载失败',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            context.read<VideoProvider>().error!,
            style: TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => context.read<VideoProvider>().loadHomeFeed(),
            icon: const Icon(Icons.replay, size: 18),
            label: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _searchResultState(BuildContext context, VideoProvider video) {
    if (video.searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              '没有找到相关视频',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              '换个关键词试试',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              childCount: video.searchResults.length,
              (context, index) => VideoCard(video: video.searchResults[index]),
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
          ),
        ),
        if (video.searchTotalPages > 1)
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: video.searchPage > 1 && !video.loading
                        ? () => context.read<VideoProvider>().searchVideos(
                            '',
                            page: video.searchPage - 1,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '第 ${video.searchPage} 页 / 共 ${video.searchTotalPages} 页',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed:
                        video.searchPage < video.searchTotalPages &&
                            !video.loading
                        ? () => context.read<VideoProvider>().searchVideos(
                            '',
                            page: video.searchPage + 1,
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _feedState(BuildContext context, VideoProvider video) {
    return RefreshIndicator(
      onRefresh: () => context.read<VideoProvider>().refreshHomeFeed(),
      child: video.homeFeed.isEmpty
          ? _videoGrid(context, video.homeFeed, showPagination: false)
          : CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      childCount: video.homeFeed.length,
                      (context, index) =>
                          VideoCard(video: video.homeFeed[index]),
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                  ),
                ),
                if (video.hasMore)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    sliver: SliverToBoxAdapter(
                      child: Center(
                        child: FilledButton.tonal(
                          onPressed: video.loading
                              ? null
                              : () => context.read<VideoProvider>().loadMore(),
                          child: video.loading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('加载更多'),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _videoGrid(
    BuildContext context,
    List videos, {
    required bool showPagination,
  }) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        if (videos.isEmpty) return const SizedBox.shrink();
        return VideoCard(video: videos[index]);
      },
    );
  }
}
