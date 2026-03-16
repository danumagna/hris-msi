import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/master_form_data.dart';

class MasterFormDetailPage extends StatelessWidget {
  const MasterFormDetailPage({super.key, required this.formData});

  final MasterFormData formData;

  Future<void> _openEditForm(BuildContext context) async {
    final updatedData = await context.push<MasterFormData>(
      RoutePaths.masterFormAdd,
      extra: formData,
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
    final statusColor = formData.isActive ? AppColors.success : AppColors.error;

    return Scaffold(
      appBar: AppBar(title: const Text('Form Detail')),
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
                Text(formData.formCode, style: AppTextStyles.titleLarge),
                const SizedBox(height: 4),
                Text(formData.formName, style: AppTextStyles.bodyMedium),
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
                    formData.status,
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
              _DetailRow(label: 'Module Name', value: formData.moduleName),
              _DetailRow(label: 'Form Code', value: formData.formCode),
              _DetailRow(label: 'Form Name', value: formData.formName),
              _DetailRow(label: 'Form Desc', value: formData.formDesc),
              _DetailRow(label: 'Form Title', value: formData.formTitle),
              _DetailRow(label: 'Form Link', value: formData.formLink),
              _DetailRow(label: 'Form Icon', value: formData.formIcon),
              _DetailRow(
                label: 'Form Order',
                value: formData.formOrder.toString(),
              ),
              _DetailRow(label: 'Role Name', value: formData.roleName),
              _DetailRow(
                label: 'Effective Start Date',
                value: _formatDate(formData.effectiveStartDate),
              ),
              _DetailRow(
                label: 'Effective End Date',
                value: formData.effectiveEndDate == null
                    ? '-'
                    : _formatDate(formData.effectiveEndDate!),
              ),
              _DetailRow(label: 'Status', value: formData.status),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _openEditForm(context),
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
