import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/report_model.dart';
import '../../providers/admin_provider.dart';

class ReportReviewPage extends StatefulWidget {
  const ReportReviewPage({super.key});

  @override
  State<ReportReviewPage> createState() => _ReportReviewPageState();
}

class _ReportReviewPageState extends State<ReportReviewPage> {
  String _filter = 'all'; // all | reviewing | pass | reject
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<AdminProvider>().loadReports();
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    });
  }

  List<ReportModel> _getFilteredReports(List<ReportModel> reports) {
    if (_filter == 'all') return reports;
    return reports.where((r) => r.status == _filter).toList();
  }

  String _statusText(String status) {
    return switch (status) {
      'pass' => '已处理',
      'reject' => '已驳回',
      'reviewing' => '处理中',
      _ => status,
    };
  }

  Color _statusBg(String status) {
    return switch (status) {
      'pass' => Colors.green,
      'reject' => Colors.red,
      'reviewing' => Colors.orange,
      _ => Colors.grey,
    };
  }

  void _resolveReport(int reportId, bool passed) async {
    final admin = context.read<AdminProvider>();
    await admin.resolveReport(reportId, passed);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(passed ? '举报已确认' : '举报已驳回')));
    }
  }

  String _getUsername(int? userId) {
    if (userId == null) return '已注销';
    return '用户 #$userId';
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '举报处理',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Filter chips
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('全部'),
                    selected: _filter == 'all',
                    onSelected: (_) => setState(() => _filter = 'all'),
                  ),
                  FilterChip(
                    label: const Text('处理中'),
                    selected: _filter == 'reviewing',
                    onSelected: (_) => setState(() => _filter = 'reviewing'),
                  ),
                  FilterChip(
                    label: const Text('已处理'),
                    selected: _filter == 'pass',
                    onSelected: (_) => setState(() => _filter = 'pass'),
                  ),
                  FilterChip(
                    label: const Text('已驳回'),
                    selected: _filter == 'reject',
                    onSelected: (_) => setState(() => _filter = 'reject'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (admin.reports.isEmpty)
                const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.flag_outlined, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('暂无举报'),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _getFilteredReports(admin.reports).length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final report = _getFilteredReports(admin.reports)[index];
                    final reporterName = _getUsername(report.userId);
                    final isReviewing = report.status == 'reviewing';

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _statusBg(report.status),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    _statusText(report.status),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  DateFormat(
                                    'yyyy-MM-dd HH:mm',
                                  ).format(report.createDate),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '举报内容:',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              report.context,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  '视频ID: ${report.videoId}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  '举报者: ${reporterName}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            if (isReviewing) ...[
                              const SizedBox(height: 12),
                              const Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: admin.loading
                                        ? null
                                        : () =>
                                              _resolveReport(report.id, false),
                                    icon: const Icon(Icons.close, size: 18),
                                    label: const Text('驳回'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      side: const BorderSide(color: Colors.red),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    onPressed: admin.loading
                                        ? null
                                        : () => _resolveReport(report.id, true),
                                    icon: const Icon(Icons.check, size: 18),
                                    label: const Text('确认'),
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
        if (admin.loading && _loading == false)
          const ModalBarrier(dismissible: false),
        if (admin.loading && _loading == false)
          const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
