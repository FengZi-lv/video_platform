import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/comment_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/comment_provider.dart';
import '../../../routes/app_routes.dart';
import 'user_avatar.dart';

class CommentTile extends StatefulWidget {
  final CommentModel comment;
  final int? currentUserId;
  final bool isVideoUploader;
  final VoidCallback? onReply;

  const CommentTile({
    super.key,
    required this.comment,
    this.currentUserId,
    this.isVideoUploader = false,
    this.onReply,
  });

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {
  bool _isReplying = false;
  final _replyCtrl = TextEditingController();

  @override
  void dispose() {
    _replyCtrl.dispose();
    super.dispose();
  }

  void _submitReply(BuildContext context) {
    final text = _replyCtrl.text.trim();
    if (text.isEmpty) return;

    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) return;

    context.read<CommentProvider>().addComment(
      user.id,
      widget.comment.videoId,
      text,
      parentId: widget.comment.id,
    );
    _replyCtrl.clear();
    setState(() => _isReplying = false);
  }

  void _openUserHome(BuildContext context, int userId) {
    final router = GoRouter.of(context);
    Future.microtask(() {
      if (!mounted) return;
      router.push(AppRoutes.userHomeRoute(userId));
    });
  }

  Widget _buildComment(BuildContext context, CommentModel c, int depth) {
    final auth = context.watch<AuthProvider>();
    final provider = context.read<CommentProvider>();
    final isOwner = auth.isAuthenticated && c.userId == widget.currentUserId;
    final isLiked = provider.likedCommentIds.contains(c.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: depth * 16.0, bottom: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserAvatar(
                nickname: c.username,
                size: 32,
                userId: c.userId,
                onTap: c.userId != null && c.status != 'del'
                    ? () => _openUserHome(context, c.userId!)
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.username ?? '已注销用户',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: c.username != null ? null : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (c.status == 'del')
                      Text(
                        '该评论已删除',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    else
                      Text(c.context, style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          DateFormat('MM-dd HH:mm').format(c.createDate),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: c.status != 'del' && auth.currentUser != null
                              ? () => provider.toggleCommentLike(
                                  auth.currentUser!.id,
                                  c.id,
                                )
                              : null,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isLiked
                                    ? Icons.thumb_up
                                    : Icons.thumb_up_outlined,
                                size: 16,
                                color: isLiked ? Colors.blue : Colors.grey[600],
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${c.likes}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isLiked
                                      ? Colors.blue
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Reply button
                        if (c.status != 'del')
                          GestureDetector(
                            onTap: () =>
                                setState(() => _isReplying = !_isReplying),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 12.0),
                              child: Text(
                                '回复',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _isReplying
                                      ? Colors.blue
                                      : Colors.blue[700],
                                  fontWeight: _isReplying
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        if ((isOwner || widget.isVideoUploader) &&
                            c.status != 'del')
                          GestureDetector(
                            onTap: () => _onDelete(context, c.id),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 12.0),
                              child: Icon(
                                Icons.delete_outline,
                                size: 16,
                                color: Colors.red[400],
                              ),
                            ),
                          ),
                        if (c.replies.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: Text(
                              '${c.replies.length} 回复',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.blue[700],
                              ),
                            ),
                          ),
                      ],
                    ),
                    // Inline reply input
                    if (_isReplying)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _replyCtrl,
                                autofocus: true,
                                decoration: const InputDecoration(
                                  hintText: '回复...',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  isDense: true,
                                ),
                                maxLines: 1,
                                onSubmitted: (_) => _submitReply(context),
                              ),
                            ),
                            const SizedBox(width: 4),
                            TextButton(
                              onPressed: () => _submitReply(context),
                              child: const Text('发送'),
                            ),
                            TextButton(
                              onPressed: () {
                                _replyCtrl.clear();
                                setState(() => _isReplying = false);
                              },
                              child: const Text('取消'),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Nested replies
        if (c.replies.isNotEmpty)
          ...c.replies.map((r) => _buildNestedComment(context, r, depth + 1)),
      ],
    );
  }

  /// Widget for nested replies — each reply is its own state so its reply
  /// toggle is independent.
  Widget _buildNestedComment(BuildContext context, CommentModel c, int depth) {
    return _NestedCommentTile(
      comment: c,
      depth: depth,
      currentUserId: widget.currentUserId,
      isVideoUploader: widget.isVideoUploader,
    );
  }

  void _onDelete(BuildContext context, int commentId) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('删除后无法恢复'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              context.read<CommentProvider>().deleteComment(commentId);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildComment(context, widget.comment, 0);
  }
}

/// Standalone tile used for nested replies so each nesting level has its
/// own independent reply-toggle state.
class _NestedCommentTile extends StatefulWidget {
  final CommentModel comment;
  final int depth;
  final int? currentUserId;
  final bool isVideoUploader;

  const _NestedCommentTile({
    required this.comment,
    required this.depth,
    this.currentUserId,
    this.isVideoUploader = false,
  });

  @override
  State<_NestedCommentTile> createState() => _NestedCommentTileState();
}

class _NestedCommentTileState extends State<_NestedCommentTile> {
  bool _isReplying = false;
  final _replyCtrl = TextEditingController();

  @override
  void dispose() {
    _replyCtrl.dispose();
    super.dispose();
  }

  void _submitReply(BuildContext context) {
    final text = _replyCtrl.text.trim();
    if (text.isEmpty) return;

    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) return;

    context.read<CommentProvider>().addComment(
      user.id,
      widget.comment.videoId,
      text,
      parentId: widget.comment.id,
    );
    _replyCtrl.clear();
    setState(() => _isReplying = false);
  }

  void _openUserHome(BuildContext context, int userId) {
    final router = GoRouter.of(context);
    Future.microtask(() {
      if (!mounted) return;
      router.push(AppRoutes.userHomeRoute(userId));
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.read<CommentProvider>();
    final c = widget.comment;
    final isOwner = auth.isAuthenticated && c.userId == widget.currentUserId;
    final isLiked = provider.likedCommentIds.contains(c.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: widget.depth * 16.0, bottom: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserAvatar(
                nickname: c.username,
                size: 28,
                userId: c.userId,
                onTap: c.userId != null && c.status != 'del'
                    ? () => _openUserHome(context, c.userId!)
                    : null,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.username ?? '已注销用户',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: c.username != null ? null : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (c.status == 'del')
                      Text(
                        '该评论已删除',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    else
                      Text(c.context, style: const TextStyle(fontSize: 13)),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          DateFormat('MM-dd HH:mm').format(c.createDate),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: c.status != 'del' && auth.currentUser != null
                              ? () => provider.toggleCommentLike(
                                  auth.currentUser!.id,
                                  c.id,
                                )
                              : null,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isLiked
                                    ? Icons.thumb_up
                                    : Icons.thumb_up_outlined,
                                size: 14,
                                color: isLiked ? Colors.blue : Colors.grey[600],
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${c.likes}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isLiked
                                      ? Colors.blue
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (c.status != 'del')
                          GestureDetector(
                            onTap: () =>
                                setState(() => _isReplying = !_isReplying),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 12.0),
                              child: Text(
                                '回复',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _isReplying
                                      ? Colors.blue
                                      : Colors.blue[700],
                                  fontWeight: _isReplying
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        if ((isOwner || widget.isVideoUploader) &&
                            c.status != 'del')
                          GestureDetector(
                            onTap: () => _onDelete(context, c.id),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 12.0),
                              child: Icon(
                                Icons.delete_outline,
                                size: 14,
                                color: Colors.red[400],
                              ),
                            ),
                          ),
                        if (c.replies.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: Text(
                              '${c.replies.length} 回复',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.blue[700],
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (_isReplying)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _replyCtrl,
                                autofocus: true,
                                decoration: const InputDecoration(
                                  hintText: '回复...',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  isDense: true,
                                ),
                                maxLines: 1,
                                onSubmitted: (_) => _submitReply(context),
                              ),
                            ),
                            const SizedBox(width: 4),
                            TextButton(
                              onPressed: () => _submitReply(context),
                              child: const Text('发送'),
                            ),
                            TextButton(
                              onPressed: () {
                                _replyCtrl.clear();
                                setState(() => _isReplying = false);
                              },
                              child: const Text('取消'),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Deeper nested replies
        if (c.replies.isNotEmpty)
          ...c.replies.map(
            (r) => _NestedCommentTile(
              comment: r,
              depth: widget.depth + 1,
              currentUserId: widget.currentUserId,
              isVideoUploader: widget.isVideoUploader,
            ),
          ),
      ],
    );
  }

  void _onDelete(BuildContext context, int commentId) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('删除后无法恢复'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              context.read<CommentProvider>().deleteComment(commentId);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
