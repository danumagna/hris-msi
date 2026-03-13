import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/overtime_request.dart';
import '../providers/overtime_provider.dart';

/// Overtime list page — shows all submitted overtime requests.
class OvertimePage extends ConsumerStatefulWidget {
  const OvertimePage({super.key});

  @override
  ConsumerState<OvertimePage> createState() => _OvertimePageState();
}

class _OvertimePageState extends ConsumerState<OvertimePage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(overtimeFilterProvider);
    final items = ref.watch(filteredOvertimesProvider);
    final totalHours = ref.watch(totalOvertimeHoursProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Overtime')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.push(RoutePaths.overtimeAdd),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Create Overtime'),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: _FilterChip(
                    icon: Icons.calendar_month_rounded,
                    label: _periodLabel(filter.periodStart, filter.periodEnd),
                    onTap: () => _pickPeriod(context),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _FilterChip(
                    icon: Icons.category_rounded,
                    label: filter.type?.label ?? 'All Overtime Types',
                    onTap: () => _pickType(context),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => ref
                  .read(overtimeFilterProvider.notifier)
                  .setSearchQuery(value),
              decoration: InputDecoration(
                hintText: 'Search overtime no, type, shift...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(overtimeFilterProvider.notifier)
                              .setSearchQuery('');
                        },
                      )
                    : null,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.work_history_rounded,
                          size: 64,
                          color: AppColors.textHint.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No overtime data',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textHint,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap "Create Overtime" to add one',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  )
                : Stack(
                    children: [
                      ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 72),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => _OvertimeCard(item: items[i]),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            border: const Border(
                              top: BorderSide(color: AppColors.divider),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.textPrimary.withValues(
                                  alpha: 0.08,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, -2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Overtime',
                                style: AppTextStyles.titleSmall,
                              ),
                              Text(
                                _formatDuration(totalHours),
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: AppColors.darkBlue,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  String _periodLabel(DateTime start, DateTime end) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final startLabel = '${start.day} ${months[start.month - 1]}';
    final endLabel = '${end.day} ${months[end.month - 1]}';

    if (start.year != end.year) {
      return '$startLabel ${start.year} - $endLabel ${end.year}';
    }

    return '$startLabel - $endLabel ${end.year}';
  }

  Future<void> _pickPeriod(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 2),
      initialDateRange: DateTimeRange(
        start: ref.read(overtimeFilterProvider).periodStart,
        end: ref.read(overtimeFilterProvider).periodEnd,
      ),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(
            context,
          ).colorScheme.copyWith(primary: AppColors.darkBlue),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      ref
          .read(overtimeFilterProvider.notifier)
          .setPeriod(picked.start, picked.end);
    }
  }

  Future<void> _pickType(BuildContext context) async {
    final current = ref.read(overtimeFilterProvider).type;
    final result = await showModalBottomSheet<OvertimeType?>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text('Filter by Overtime Type', style: AppTextStyles.titleMedium),
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(
                Icons.all_inclusive_rounded,
                color: current == null
                    ? AppColors.darkBlue
                    : AppColors.textHint,
              ),
              title: const Text('All Overtime Types'),
              selected: current == null,
              onTap: () => Navigator.pop(context, null),
            ),
            ...OvertimeType.values.map(
              (type) => ListTile(
                leading: Icon(
                  _typeIcon(type),
                  color: current == type
                      ? AppColors.darkBlue
                      : AppColors.textHint,
                ),
                title: Text(type.label),
                selected: current == type,
                onTap: () => Navigator.pop(context, type),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (context.mounted) {
      ref.read(overtimeFilterProvider.notifier).setType(result);
    }
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.accentBlue),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.labelMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }
}

class _OvertimeCard extends StatelessWidget {
  const _OvertimeCard({required this.item});

  final OvertimeRequest item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showDetailDialog(context, item),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.overtimeNo,
                    style: AppTextStyles.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _StatusBadge(status: item.status),
              ],
            ),
            const SizedBox(height: 10),
            _detailRow('Overtime Type', item.type.label),
            const SizedBox(height: 4),
            _detailRow('Date', _formatDate(item.overtimeDate)),
            const SizedBox(height: 4),
            _detailRow(
              'Schedule',
              '${item.scheduleShift} (${item.scheduleHours})',
            ),
            const SizedBox(height: 4),
            _detailRow(
              'Overtime Time',
              '${_formatTime(item.startAt)} - ${_formatTime(item.endAt)}',
            ),
            const SizedBox(height: 4),
            _detailRow('Duration', _formatDuration(item.durationHours)),
            const SizedBox(height: 4),
            _detailRow('Evidence', '${item.evidenceFiles.length} file(s)'),
            const SizedBox(height: 4),
            _detailRow('Entry Time', _formatDateTime(item.entryTime)),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

void _showDetailDialog(BuildContext context, OvertimeRequest item) {
  final imagePaths = item.evidenceFiles.where(_isImagePath).toList();
  final otherFiles = item.evidenceFiles.where((p) => !_isImagePath(p)).toList();

  showDialog(
    context: context,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Overtime Detail',
                      style: AppTextStyles.titleMedium,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, size: 22),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.overtimeNo,
                            style: AppTextStyles.titleSmall.copyWith(
                              fontSize: 16,
                            ),
                          ),
                        ),
                        _StatusBadge(status: item.status),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _dialogDetailRow('Overtime Type', item.type.label),
                    _dialogDetailRow('Date', _formatDate(item.overtimeDate)),
                    _dialogDetailRow('Shift', item.scheduleShift),
                    _dialogDetailRow('Schedule', item.scheduleHours),
                    _dialogDetailRow('Start', _formatTime(item.startAt)),
                    _dialogDetailRow('End', _formatTime(item.endAt)),
                    _dialogDetailRow(
                      'Duration',
                      _formatDuration(item.durationHours),
                      valueColor: AppColors.darkBlue,
                    ),
                    _dialogDetailRow(
                      'Evidence',
                      '${item.evidenceFiles.length} file(s)',
                    ),
                    if (otherFiles.isNotEmpty)
                      _dialogDetailRow(
                        'Document',
                        otherFiles.map(_displayFileName).join(', '),
                      ),
                    _dialogDetailRow(
                      'Entry Time',
                      _formatDateTime(item.entryTime),
                    ),
                    if (item.rejectionReason != null &&
                        item.rejectionReason!.isNotEmpty)
                      _dialogDetailRow(
                        'Rejection Reason',
                        item.rejectionReason!,
                        valueColor: AppColors.error,
                      ),

                    if (imagePaths.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Attachments (${imagePaths.length})',
                        style: AppTextStyles.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                            ),
                        itemCount: imagePaths.length,
                        itemBuilder: (ctx, i) {
                          final path = imagePaths[i];
                          return GestureDetector(
                            onTap: () => _showFullImage(ctx, path),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                File(path),
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  color: AppColors.background,
                                  child: const Icon(
                                    Icons.broken_image_rounded,
                                    color: AppColors.textHint,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

bool _isImagePath(String value) {
  final lower = value.toLowerCase();
  final hasImageExtension =
      lower.endsWith('.jpg') ||
      lower.endsWith('.jpeg') ||
      lower.endsWith('.png') ||
      lower.endsWith('.webp') ||
      lower.endsWith('.heic');
  final looksLikePath =
      value.contains('/') || value.contains('\\') || value.startsWith('file:');

  return hasImageExtension && looksLikePath;
}

String _displayFileName(String value) {
  if (value.isEmpty) return value;

  final normalized = value.replaceAll('\\', '/');
  final segments = normalized.split('/');
  return segments.isEmpty ? value : segments.last;
}

void _showFullImage(BuildContext context, String path) {
  showDialog(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: InteractiveViewer(
              child: Image.file(
                File(path),
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => Container(
                  width: 200,
                  height: 200,
                  color: AppColors.background,
                  child: const Icon(
                    Icons.broken_image_rounded,
                    size: 48,
                    color: AppColors.textHint,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.textPrimary.withValues(alpha: 0.6),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: AppColors.white,
                ),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _dialogDetailRow(String label, String value, {Color? valueColor}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: valueColor ?? AppColors.textPrimary,
              fontWeight: valueColor != null
                  ? FontWeight.w600
                  : FontWeight.w400,
            ),
          ),
        ),
      ],
    ),
  );
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status.toLowerCase()) {
      'approved' => AppColors.success,
      'rejected' => AppColors.error,
      _ => AppColors.warning,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

IconData _typeIcon(OvertimeType type) {
  return switch (type) {
    OvertimeType.workday => Icons.business_center_rounded,
    OvertimeType.weekend => Icons.weekend_rounded,
    OvertimeType.holiday => Icons.celebration_rounded,
  };
}

String _formatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  final day = date.day.toString().padLeft(2, '0');
  return '$day ${months[date.month - 1]} ${date.year}';
}

String _formatTime(DateTime date) {
  final h = date.hour.toString().padLeft(2, '0');
  final m = date.minute.toString().padLeft(2, '0');
  return '$h.$m WIB';
}

String _formatDateTime(DateTime date) {
  final d = _formatDate(date);
  final h = date.hour.toString().padLeft(2, '0');
  final m = date.minute.toString().padLeft(2, '0');
  return '$d $h:$m';
}

String _formatDuration(double hours) {
  if (hours == hours.toInt()) {
    final h = hours.toInt();
    return '$h ${h == 1 ? 'Hour' : 'Hours'}';
  }
  return '${hours.toStringAsFixed(1)} Hours';
}
