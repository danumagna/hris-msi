import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/master_action_data.dart';

class MasterActionDetailPage extends StatelessWidget {
  const MasterActionDetailPage({super.key, required this.action});

  final MasterActionData action;

  Future<void> _openEditForm(BuildContext context) async {
    final updatedData = await context.push<MasterActionData>(
      RoutePaths.masterActionAdd,
      extra: action,
    );

    if (!context.mounted || updatedData == null) return;
    context.pop(updatedData);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = action.isActive ? AppColors.success : AppColors.error;

    return Scaffold(
      appBar: AppBar(title: const Text('Action Detail')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(action.actionCode, style: AppTextStyles.titleLarge),
                const SizedBox(height: 4),
                Text(action.actionName, style: AppTextStyles.bodyMedium),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    action.status,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _DetailCard(
            children: [
              _DetailRow(label: 'Action Code', value: action.actionCode),
              _DetailRow(label: 'Action Name', value: action.actionName),
              _DetailRow(label: 'Action Role', value: action.actionRole),
              _DetailRow(label: 'Action User', value: action.actionUser),
              _DetailRow(label: 'Email', value: action.email),
              _DetailRow(label: 'Status', value: action.status),
              _DetailRow(
                label: 'Valid Action',
                value: _formatDate(action.validAction),
              ),
              _DetailRow(
                label: 'End Until',
                value: action.endUntil == null
                    ? '-'
                    : _formatDate(action.endUntil!),
              ),
              _DetailRow(
                label: 'Modified By',
                value: action.modifiedBy?.isNotEmpty == true
                    ? action.modifiedBy!
                    : '-',
              ),
              _DetailRow(
                label: 'Modified Date',
                value: action.modifiedDate == null
                    ? '-'
                    : _formatDate(action.modifiedDate!),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _openEditForm(context),
            icon: const Icon(Icons.edit_rounded),
            label: const Text('Edit Action'),
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(children: children),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(value, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }
}
