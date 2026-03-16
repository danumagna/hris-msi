import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/master_position_data.dart';

class MasterPositionDetailPage extends StatelessWidget {
  const MasterPositionDetailPage({super.key, required this.position});

  final MasterPositionData position;

  Future<void> _openEditForm(BuildContext context) async {
    final updatedData = await context.push<MasterPositionData>(
      RoutePaths.masterPositionAdd,
      extra: position,
    );

    if (!context.mounted || updatedData == null) return;
    context.pop(updatedData);
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = position.isActive ? AppColors.success : AppColors.error;

    return Scaffold(
      appBar: AppBar(title: const Text('Position Detail')),
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
                Text(position.positionCode, style: AppTextStyles.titleLarge),
                const SizedBox(height: 4),
                Text(position.positionName, style: AppTextStyles.bodyMedium),
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
                    position.statusLabel,
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
              _DetailRow(label: 'Position Code', value: position.positionCode),
              _DetailRow(label: 'Position Name', value: position.positionName),
              _DetailRow(label: 'Position Desc', value: position.positionDesc),
              _DetailRow(
                label: 'Position Level',
                value: position.positionLevel,
              ),
              _DetailRow(label: 'Job Spec', value: position.jobSpec),
              _DetailRow(label: 'Man Spec', value: position.manSpec),
              _DetailRow(
                label: 'Valid Start Date',
                value: _formatDate(position.validStartDate),
              ),
              _DetailRow(
                label: 'Valid End Date',
                value: position.validEndDate == null
                    ? '-'
                    : _formatDate(position.validEndDate!),
              ),
              _DetailRow(label: 'Major', value: position.majors.join(', ')),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _openEditForm(context),
            icon: const Icon(Icons.edit_rounded),
            label: const Text('Edit Position'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
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
