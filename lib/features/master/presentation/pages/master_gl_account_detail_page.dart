import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/master_gl_account_data.dart';

class MasterGlAccountDetailPage extends StatelessWidget {
  const MasterGlAccountDetailPage({super.key, required this.glAccountData});

  final MasterGlAccountData glAccountData;

  Future<void> _openEdit(BuildContext context) async {
    final updatedData = await context.push<MasterGlAccountData>(
      RoutePaths.masterGlAccountAdd,
      extra: glAccountData,
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
    final statusColor = glAccountData.isActive
        ? AppColors.success
        : AppColors.error;

    return Scaffold(
      appBar: AppBar(title: const Text('GL Account Detail')),
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
                Text(
                  glAccountData.glAccountNumber,
                  style: AppTextStyles.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  glAccountData.glAccountText,
                  style: AppTextStyles.bodyMedium,
                ),
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
                    glAccountData.status,
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
              _DetailRow(
                label: 'Company Code',
                value: glAccountData.companyCode,
              ),
              _DetailRow(label: 'Company', value: glAccountData.company),
              _DetailRow(
                label: 'Chart of Account',
                value: glAccountData.chartOfAccount,
              ),
              _DetailRow(
                label: 'GL Account Number',
                value: glAccountData.glAccountNumber,
              ),
              _DetailRow(
                label: 'GL Account Text',
                value: glAccountData.glAccountText,
              ),
              _DetailRow(
                label: 'GL Account Group',
                value: glAccountData.glAccountGroup,
              ),
              _DetailRow(
                label: 'Integration',
                value: glAccountData.integration,
              ),
              _DetailRow(label: 'Name', value: glAccountData.name),
              _DetailRow(
                label: 'Description',
                value: glAccountData.description,
              ),
              _DetailRow(
                label: 'Effective Start Date',
                value: _formatDate(glAccountData.effectiveStartDate),
              ),
              _DetailRow(
                label: 'Is Expired',
                value: glAccountData.isExpired ? 'Yes' : 'No',
              ),
              _DetailRow(
                label: 'Effective End Date',
                value: glAccountData.effectiveEndDate == null
                    ? '-'
                    : _formatDate(glAccountData.effectiveEndDate!),
              ),
              _DetailRow(label: 'Status', value: glAccountData.status),
            ],
          ),
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
