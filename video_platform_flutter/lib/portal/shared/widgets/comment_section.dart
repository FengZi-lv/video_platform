import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/comment_provider.dart';
import 'comment_tile.dart';
import 'login_prompt_dialog.dart';

class CommentSection extends StatefulWidget {
  final int videoId;
  final bool isVideoUploader;
  const CommentSection({
    super.key,
    required this.videoId,
    this.isVideoUploader = false,
  });

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void didUpdateWidget(covariant CommentSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoId != widget.videoId) {
      _loadComments();
    }
  }

  void _loadComments() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommentProvider>().loadComments(widget.videoId);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submitComment(BuildContext context) {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;

    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) {
      showDialog(context: context, builder: (_) => const LoginPromptDialog());
      return;
    }

    context.read<CommentProvider>().addComment(user.id, widget.videoId, text);
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommentProvider>();
    final comments = provider.getTopLevelComments(widget.videoId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  decoration: const InputDecoration(
                    hintText: '发表评论...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  maxLines: 1,
                  onSubmitted: (_) => _submitComment(context),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _submitComment(context),
                child: const Text('发送'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (comments.isEmpty && !provider.loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.comment_outlined, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('暂无评论，快来抢沙发'),
                ],
              ),
            ),
          )
        else
          ...comments.map((c) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 4.0,
              ),
              child: CommentTile(
                comment: c,
                currentUserId: context.read<AuthProvider>().currentUser?.id,
                isVideoUploader: widget.isVideoUploader,
              ),
            );
          }),
      ],
    );
  }
}
