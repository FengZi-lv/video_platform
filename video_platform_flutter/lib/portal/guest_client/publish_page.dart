import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../shared/widgets/login_prompt_dialog.dart';
import '../shared/widgets/upload_form.dart';

class PublishPage extends StatelessWidget {
  const PublishPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    if (auth.isGuest) {
      return _emptyState(
        icon: Icons.cloud_upload_outlined,
        title: '发布视频',
        subtitle: '请先登录后再发布视频',
        actionLabel: '去登录',
        action: () => showDialog(
          context: context,
          builder: (_) => const LoginPromptDialog(),
        ),
      );
    }

    if (auth.isBanned) {
      return _emptyState(
        icon: Icons.block,
        title: '账号已被封禁',
        subtitle: '无法发布视频',
        color: colorScheme.error,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.cloud_upload,
                    size: 28,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '发布视频',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '填写视频信息，提交后将进入审核',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: UploadForm(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? color,
    String? actionLabel,
    VoidCallback? action,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 72, color: color ?? Colors.grey),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: TextStyle(color: Colors.grey[600])),
          if (actionLabel != null && action != null) ...[
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: action,
              icon: const Icon(Icons.login, size: 18),
              label: Text(actionLabel),
            ),
          ],
        ],
      ),
    );
  }
}
