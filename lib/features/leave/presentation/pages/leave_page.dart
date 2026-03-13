import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/leave_request.dart';
import '../providers/leave_provider.dart';

/// Leave list page — shows all submitted leave requests.
class LeavePage extends ConsumerStatefulWidget {
  const LeavePage({super.key});

  @override
  ConsumerState<LeavePage> createState() => _LeavePageState();
}

class _LeavePageState extends ConsumerState<LeavePage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(leaveFilterProvider);
    final items = ref.watch(filteredLeaveRequestsProvider);
    final totalDays = ref.watch(totalLeaveDaysProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Leave')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.push(RoutePaths.leaveAdd),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add Form'),
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
                    label: filter.type?.label ?? 'All Leave Types',
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
              onChanged: (value) =>
                  ref.read(leaveFilterProvider.notifier).setSearchQuery(value),
              decoration: InputDecoration(
                hintText: 'Search leave no, notes, substitute...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(leaveFilterProvider.notifier)
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
                          Icons.beach_access_rounded,
                          size: 64,
                          color: AppColors.textHint.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No leave request data',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textHint,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap "Add Form" to create one',
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
                        itemBuilder: (_, i) => _LeaveCard(item: items[i]),
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
                                'Total Leave Days',
                                style: AppTextStyles.titleSmall,
                              ),
                              Text(
                                _formatLeaveDays(totalDays),
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
        start: ref.read(leaveFilterProvider).periodStart,
        end: ref.read(leaveFilterProvider).periodEnd,
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
          .read(leaveFilterProvider.notifier)
          .setPeriod(picked.start, picked.end);
    }
  }

  Future<void> _pickType(BuildContext context) async {
    final current = ref.read(leaveFilterProvider).type;
    final result = await showModalBottomSheet<LeaveType?>(
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
            Text('Filter by Leave Type', style: AppTextStyles.titleMedium),
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(
                Icons.all_inclusive_rounded,
                color: current == null
                    ? AppColors.darkBlue
                    : AppColors.textHint,
              ),
              title: const Text('All Leave Types'),
              selected: current == null,
              onTap: () => Navigator.pop(context, null),
            ),
            ...LeaveType.values.map(
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
      ref.read(leaveFilterProvider.notifier).setType(result);
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

class _LeaveCard extends StatelessWidget {
  const _LeaveCard({required this.item});

  final LeaveRequest item;

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
                    item.leaveNo,
                    style: AppTextStyles.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _StatusBadge(status: item.status),
              ],
            ),
            const SizedBox(height: 10),
            _detailRow('Leave Type', item.type.label),
            const SizedBox(height: 4),
            _detailRow('Day Mode', item.dayMode.label),
            const SizedBox(height: 4),
            _detailRow(
              'Period',
              '${_formatDate(item.startDate)} - ${_formatDate(item.endDate)}',
            ),
            const SizedBox(height: 4),
            _detailRow('Leave Days', _formatLeaveDays(item.leaveDays)),
            const SizedBox(height: 4),
            _detailRow(
              'Substitute',
              '${item.substituteName} (${item.substituteId})',
            ),
            const SizedBox(height: 4),
            _detailRow('Notes', item.notes),
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

void _showDetailDialog(BuildContext context, LeaveRequest item) {
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
                      'Leave Detail',
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
                            item.leaveNo,
                            style: AppTextStyles.titleSmall.copyWith(
                              fontSize: 16,
                            ),
                          ),
                        ),
                        _StatusBadge(status: item.status),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _dialogDetailRow('Leave Type', item.type.label),
                    _dialogDetailRow('Day Mode', item.dayMode.label),
                    _dialogDetailRow('Start Date', _formatDate(item.startDate)),
                    _dialogDetailRow('End Date', _formatDate(item.endDate)),
                    _dialogDetailRow(
                      'Leave Days',
                      _formatLeaveDays(item.leaveDays),
                      valueColor: AppColors.darkBlue,
                    ),
                    _dialogDetailRow('Substitute ID', item.substituteId),
                    _dialogDetailRow('Substitute Name', item.substituteName),
                    _dialogDetailRow(
                      'Substitute Position',
                      item.substitutePosition,
                    ),
                    _dialogDetailRow('Notes', item.notes),
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

Widget _dialogDetailRow(String label, String value, {Color? valueColor}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
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

IconData _typeIcon(LeaveType type) {
  return switch (type) {
    LeaveType.annual => Icons.beach_access_rounded,
    LeaveType.sick => Icons.local_hospital_rounded,
    LeaveType.unpaid => Icons.money_off_csred_rounded,
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

  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

String _formatDateTime(DateTime date) {
  final d = _formatDate(date);
  final h = date.hour.toString().padLeft(2, '0');
  final m = date.minute.toString().padLeft(2, '0');
  return '$d $h:$m';
}

String _formatLeaveDays(double value) {
  if (value == value.toInt()) {
    final intValue = value.toInt();
    return '$intValue ${intValue == 1 ? 'Day' : 'Days'}';
  }
  return '${value.toStringAsFixed(1)} Days';
}
