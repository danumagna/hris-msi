import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/master_approval_data.dart';

class MasterApprovalDetailPage extends StatelessWidget {
  const MasterApprovalDetailPage({super.key, required this.approvalData});

  final MasterApprovalData approvalData;

  Future<void> _openEdit(BuildContext context) async {
    final updatedData = await context.push<MasterApprovalData>(
      RoutePaths.masterApprovalAdd,
      extra: approvalData,
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
    final statusColor = approvalData.isActive
        ? AppColors.success
        : AppColors.error;

    return Scaffold(
      appBar: AppBar(title: const Text('Approval Detail')),
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
                Text(approvalData.code, style: AppTextStyles.titleLarge),
                const SizedBox(height: 4),
                Text(approvalData.transaction, style: AppTextStyles.bodyMedium),
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
                    approvalData.status,
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
              _DetailRow(label: 'Company', value: approvalData.companyName),
              _DetailRow(
                label: 'Company Code',
                value: approvalData.companyCode,
              ),
              _DetailRow(label: 'Transaction', value: approvalData.transaction),
              _DetailRow(label: 'Plant', value: approvalData.plant),
              _DetailRow(
                label: 'Organization',
                value: approvalData.organization,
              ),
              _DetailRow(
                label: 'Organization Level',
                value: approvalData.organizationLevel,
              ),
              _DetailRow(label: 'Action', value: approvalData.action),
              _DetailRow(label: 'Employee', value: approvalData.employee),
              _DetailRow(
                label: 'Approval Max',
                value: approvalData.approvalMax.toString(),
              ),
              _DetailRow(
                label: 'Effective Start Date',
                value: _formatDate(approvalData.effectiveStartDate),
              ),
              _DetailRow(
                label: 'Expired',
                value: approvalData.expired ? 'Yes' : 'No',
              ),
              _DetailRow(
                label: 'Effective End Date',
                value: approvalData.effectiveEndDate == null
                    ? '-'
                    : _formatDate(approvalData.effectiveEndDate!),
              ),
              _DetailRow(label: 'Status', value: approvalData.status),
            ],
          ),
          const SizedBox(height: 12),
          Text('Approval Flow', style: AppTextStyles.titleSmall),
          const SizedBox(height: 8),
          ...approvalData.flows.asMap().entries.map((entry) {
            final index = entry.key;
            final flow = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Flow ${index + 1}',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _DetailRow(
                      label: 'Approval Level',
                      value: flow.approvalLevel,
                    ),
                    _DetailRow(label: 'Employee', value: flow.employee),
                    _DetailRow(
                      label: 'Position Code',
                      value: flow.positionCode,
                    ),
                    _DetailRow(
                      label: 'Mandatory',
                      value: flow.mandatory ? 'Yes' : 'No',
                    ),
                    _DetailRow(label: 'Value', value: flow.value),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _openEdit(context),
            icon: const Icon(Icons.edit_rounded),
            label: const Text('Edit Form'),
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
            width: 150,
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
