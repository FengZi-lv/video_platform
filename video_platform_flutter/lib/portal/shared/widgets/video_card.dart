import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';

import '../../../models/video_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../routes/app_routes.dart';

class VideoCard extends StatelessWidget {
  final VideoModel video;
  const VideoCard({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final token = context.watch<AuthProvider>().token;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(AppRoutes.videoDetail(video.id)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (video.thumbnailUrl.isNotEmpty)
                    Image.network(
                      video.thumbnailUrl,
                      fit: BoxFit.cover,
                      headers: {'Authorization': 'Bearer $token'},
                      errorBuilder: (_, _, _) =>
                          _buildThumbnailFallback(colorScheme),
                    )
                  else
                    _buildThumbnailFallback(colorScheme),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        (video.thumbnailUrl.isNotEmpty
                                ? video.thumbnailUrl
                                : video.videoUrl)
                            .split('/')
                            .last,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      video.intro,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    _buildStatsRow(colorScheme, textTheme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnailFallback(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withOpacity(0.08),
            colorScheme.primary.withOpacity(0.04),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.play_circle,
          size: 40,
          color: colorScheme.primary.withOpacity(0.6),
        ),
      ),
    );
  }

  Widget _buildStatsRow(ColorScheme cs, TextTheme tt) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(
              Icons.visibility_outlined,
              size: 14,
              color: cs.onSurfaceVariant,
            ),
            const SizedBox(width: 2),
            Text(
              '${video.likesCount + video.favoritesCount}',
              style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            const Spacer(),
            Text(
              DateFormat('MM-dd').format(video.createDate),
              style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            _statBadge(Icons.thumb_up_outlined, '${video.likesCount}', cs, tt),
            const SizedBox(width: 8),
            _statBadge(
              Icons.favorite_border,
              '${video.favoritesCount}',
              cs,
              tt,
            ),
            const SizedBox(width: 8),
            _statBadge(Icons.currency_exchange, '${video.coinsCount}', cs, tt),
          ],
        ),
      ],
    );
  }

  Widget _statBadge(IconData icon, String value, ColorScheme cs, TextTheme tt) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: cs.onSurfaceVariant),
        const SizedBox(width: 2),
        Text(value, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
      ],
    );
  }
}
