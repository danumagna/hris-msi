import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/master_formula_data.dart';

class MasterFormulaDetailPage extends StatelessWidget {
  const MasterFormulaDetailPage({super.key, required this.formulaData});

  final MasterFormulaData formulaData;

  Future<void> _openEdit(BuildContext context) async {
    final updatedData = await context.push<MasterFormulaData>(
      RoutePaths.masterFormulaAdd,
      extra: formulaData,
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
    final statusColor = formulaData.isActive
        ? AppColors.success
        : AppColors.error;

    return Scaffold(
      appBar: AppBar(title: const Text('Formula Detail')),
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
                Text(formulaData.code, style: AppTextStyles.titleLarge),
                const SizedBox(height: 4),
                Text(formulaData.name, style: AppTextStyles.bodyMedium),
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
                    formulaData.status,
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
              _DetailRow(label: 'Company', value: formulaData.company),
              _DetailRow(label: 'Code', value: formulaData.code),
              _DetailRow(label: 'Name', value: formulaData.name),
              _DetailRow(label: 'Description', value: formulaData.description),
              _DetailRow(
                label: 'Effective Date',
                value: _formatDate(formulaData.effectiveDate),
              ),
              _DetailRow(
                label: 'Is Expired',
                value: formulaData.isExpired ? 'Yes' : 'No',
              ),
              _DetailRow(
                label: 'Expiration Date',
                value: formulaData.expirationDate == null
                    ? '-'
                    : _formatDate(formulaData.expirationDate!),
              ),
              _DetailRow(label: 'Type', value: formulaData.type),
              _DetailRow(label: 'Table Name', value: formulaData.tableName),
              _DetailRow(label: 'Status', value: formulaData.status),
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
