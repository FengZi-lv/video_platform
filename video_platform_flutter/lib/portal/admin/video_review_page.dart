import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/video_model.dart';
import '../../providers/admin_provider.dart';

class VideoReviewPage extends StatefulWidget {
  const VideoReviewPage({super.key});

  @override
  State<VideoReviewPage> createState() => _VideoReviewPageState();
}

class _VideoReviewPageState extends State<VideoReviewPage> {
  String _filter = 'all';
  bool _initialLoad = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<AdminProvider>().loadPendingVideos();
      if (mounted) setState(() => _initialLoad = false);
    });
  }

  List<VideoModel> _filteredList(List<VideoModel> videos) {
    if (_filter == 'all') return videos;
    return videos.where((v) => v.status == _filter).toList();
  }

  Color _statusColor(String status) {
    return switch (status) {
      'pass' => Colors.green,
      'reject' => Colors.red,
      'reviewing' => Colors.orange,
      _ => Colors.grey,
    };
  }

  String _statusText(String status) {
    return switch (status) {
      'pass' => '已通过',
      'reject' => '已拒绝',
      'reviewing' => '审核中',
      _ => status,
    };
  }

  void _approveVideo(int videoId) async {
    final admin = context.read<AdminProvider>();
    try {
      await admin.approveVideo(videoId);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('视频已通过')));
      }
    } catch (_) {
      // 错误已由全局拦截器提示，此处只吞没异常避免奔溃
    }
  }

  void _rejectVideo(int videoId) async {
    final admin = context.read<AdminProvider>();
    try {
      await admin.rejectVideo(videoId);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('视频已拒绝')));
      }
    } catch (_) {
      // 错误已由全局拦截器提示
    }
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final filtered = _filteredList(admin.pendingVideos);

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '视频审核',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('全部'),
                    selected: _filter == 'all',
                    onSelected: (_) => setState(() => _filter = 'all'),
                  ),
                  FilterChip(
                    label: const Text('审核中'),
                    selected: _filter == 'reviewing',
                    onSelected: (_) => setState(() => _filter = 'reviewing'),
                  ),
                  FilterChip(
                    label: const Text('已拒绝'),
                    selected: _filter == 'reject',
                    onSelected: (_) => setState(() => _filter = 'reject'),
                  ),
                  FilterChip(
                    label: const Text('已通过'),
                    selected: _filter == 'pass',
                    onSelected: (_) => setState(() => _filter = 'pass'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (filtered.isEmpty)
                const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.video_library_outlined,
                        size: 48,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 8),
                      Text('暂无视频'),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final video = filtered[index];
                    final isReviewing = video.status == 'reviewing';
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 120,
                                  height: 68,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.play_circle_outline,
                                    size: 36,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        video.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        video.intro,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _statusColor(video.status),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              _statusText(video.status),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '上传者ID: ${video.uploaderId}',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            DateFormat(
                                              'yyyy-MM-dd',
                                            ).format(video.createDate),
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (isReviewing) ...[
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: admin.loading
                                        ? null
                                        : () => _rejectVideo(video.id),
                                    icon: const Icon(Icons.close, size: 18),
                                    label: const Text('拒绝'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      side: const BorderSide(color: Colors.red),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    onPressed: admin.loading
                                        ? null
                                        : () => _approveVideo(video.id),
                                    icon: const Icon(Icons.check, size: 18),
                                    label: const Text('通过'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
        if (admin.loading && !_initialLoad) ...[
          const ModalBarrier(dismissible: false),
          const Center(child: CircularProgressIndicator()),
        ],
      ],
    );
  }
}
