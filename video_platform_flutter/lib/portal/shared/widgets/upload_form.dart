import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/video_provider.dart';
import '../../../services/i_video_service.dart';
import 'login_prompt_dialog.dart';

enum _UploadStep { selectFiles, uploading, publishForm }

class UploadForm extends StatefulWidget {
  final VoidCallback? onSubmitted;
  const UploadForm({super.key, this.onSubmitted});

  @override
  State<UploadForm> createState() => _UploadFormState();
}

class _UploadFormState extends State<UploadForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _introCtrl = TextEditingController();
  _UploadStep _step = _UploadStep.selectFiles;
  bool _loading = false;
  PlatformFile? _videoFile;
  PlatformFile? _thumbnailFile;
  UploadMediaResult? _uploadResult;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _introCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickVideoFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
      withData: kIsWeb,
    );
    if (!mounted || result == null || result.files.isEmpty) {
      return;
    }
    setState(() => _videoFile = result.files.single);
  }

  Future<void> _pickThumbnailFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: kIsWeb,
    );
    if (!mounted || result == null || result.files.isEmpty) {
      return;
    }
    setState(() => _thumbnailFile = result.files.single);
  }

  Future<void> _startUpload() async {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) {
      showDialog(context: context, builder: (_) => const LoginPromptDialog());
      return;
    }

    final videoFile = _videoFile;
    final thumbnailFile = _thumbnailFile;
    if (videoFile == null || !_isUsableFile(videoFile)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请选择要上传的视频文件')));
      return;
    }
    if (thumbnailFile == null || !_isUsableFile(thumbnailFile)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请选择要上传的缩略图文件')));
      return;
    }

    setState(() {
      _step = _UploadStep.uploading;
      _loading = true;
    });

    try {
      final videoProvider = context.read<VideoProvider>();
      final result = await videoProvider.uploadFiles(
        videoFile: _toUploadFileData(videoFile),
        thumbnailFile: _toUploadFileData(thumbnailFile),
      );
      if (!mounted) return;
      setState(() {
        _uploadResult = result;
        _step = _UploadStep.publishForm;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _step = _UploadStep.selectFiles);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('上传失败: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) {
      showDialog(context: context, builder: (_) => const LoginPromptDialog());
      return;
    }

    final result = _uploadResult;
    if (result == null) return;

    setState(() => _loading = true);
    try {
      await context.read<VideoProvider>().publishVideo(
        user.id,
        _titleCtrl.text.trim(),
        _introCtrl.text.trim(),
        result.videoUrl,
        result.thumbnailUrl,
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('视频已提交，等待审核')));
        _resetForm();
        widget.onSubmitted?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('发布失败: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _resetForm() {
    _titleCtrl.clear();
    _introCtrl.clear();
    setState(() {
      _step = _UploadStep.selectFiles;
      _videoFile = null;
      _thumbnailFile = null;
      _uploadResult = null;
      _loading = false;
    });
  }

  bool _isUsableFile(PlatformFile file) {
    return (file.path?.isNotEmpty ?? false) ||
        ((file.bytes?.isNotEmpty ?? false));
  }

  UploadFileData _toUploadFileData(PlatformFile file) {
    return UploadFileData(name: file.name, path: file.path, bytes: file.bytes);
  }

  Widget _buildStepSelectFiles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          enabled: false,
          decoration: const InputDecoration(
            labelText: '视频标题',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.title),
            hintText: '上传文件后填写',
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          enabled: false,
          decoration: const InputDecoration(
            labelText: '简介',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.description),
            hintText: '上传文件后填写',
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        _FilePickerField(
          label: '视频文件',
          icon: Icons.movie_outlined,
          fileName: _videoFile?.name,
          onPick: _pickVideoFile,
        ),
        const SizedBox(height: 16),
        _FilePickerField(
          label: '缩略图文件',
          icon: Icons.image_outlined,
          fileName: _thumbnailFile?.name,
          onPick: _pickThumbnailFile,
          previewBytes: _thumbnailFile?.bytes,
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _loading ? null : _startUpload,
          icon: _loading
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.upload),
          label: Text(_loading ? '准备中...' : '下一步'),
        ),
      ],
    );
  }

  Widget _buildStepUploading() {
    final progress = context.select((VideoProvider p) => p.uploadProgress);
    final pct = (progress * 100).toStringAsFixed(0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.cloud_upload, size: 64),
        const SizedBox(height: 24),
        const Text(
          '正在上传文件...',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        LinearProgressIndicator(value: progress),
        const SizedBox(height: 8),
        Text('$pct%', style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildStepPublishForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 已上传文件信息
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '文件已上传',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      if (_videoFile != null)
                        Text(
                          '视频: ${_videoFile!.name}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 封面预览
          if (_thumbnailFile?.bytes != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                _thumbnailFile!.bytes!,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _titleCtrl,
            decoration: const InputDecoration(
              labelText: '视频标题',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.title),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? '请输入标题' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _introCtrl,
            decoration: const InputDecoration(
              labelText: '简介',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description),
            ),
            maxLines: 3,
            validator: (v) => v == null || v.trim().isEmpty ? '请输入简介' : null,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loading ? null : _publish,
            icon: _loading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.publish),
            label: Text(_loading ? '发布中...' : '发布'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _loading ? null : _resetForm,
            icon: const Icon(Icons.arrow_back),
            label: const Text('重新选择文件'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_step) {
      case _UploadStep.selectFiles:
        return _buildStepSelectFiles();
      case _UploadStep.uploading:
        return _buildStepUploading();
      case _UploadStep.publishForm:
        return _buildStepPublishForm();
    }
  }
}

class _FilePickerField extends StatelessWidget {
  const _FilePickerField({
    required this.label,
    required this.icon,
    required this.onPick,
    this.fileName,
    this.previewBytes,
  });

  final String label;
  final IconData icon;
  final String? fileName;
  final VoidCallback? onPick;
  final Uint8List? previewBytes;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (previewBytes != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.memory(
                Uint8List.fromList(previewBytes!),
                width: 48,
                height: 48,
                fit: BoxFit.cover,
              ),
            )
          else
            Icon(icon, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  fileName ?? '尚未选择文件',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: onPick,
            child: Text(fileName == null ? '选择' : '更换'),
          ),
        ],
      ),
    );
  }
}
