import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/master_plant_data.dart';

class MasterPlantDetailPage extends StatelessWidget {
  const MasterPlantDetailPage({super.key, required this.plant});

  final MasterPlantData plant;

  Future<void> _openEditForm(BuildContext context) async {
    final updatedData = await context.push<MasterPlantData>(
      RoutePaths.masterPlantAdd,
      extra: plant,
    );

    if (!context.mounted || updatedData == null) return;
    context.pop(updatedData);
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = plant.isActive ? AppColors.success : AppColors.error;

    return Scaffold(
      appBar: AppBar(title: const Text('Plant Detail')),
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
                Text(plant.plantCode, style: AppTextStyles.titleLarge),
                const SizedBox(height: 4),
                Text(plant.plantName, style: AppTextStyles.bodyMedium),
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
                    plant.statusLabel,
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
              _DetailRow(label: 'Company Name', value: plant.companyName),
              _DetailRow(label: 'Plant Code', value: plant.plantCode),
              _DetailRow(label: 'Plant Name', value: plant.plantName),
              _DetailRow(label: 'Plant Desc', value: plant.plantDesc),
              _DetailRow(label: 'City', value: plant.city),
              _DetailRow(label: 'Street', value: plant.street),
              _DetailRow(label: 'Postal Code', value: plant.postalCode),
              _DetailRow(
                label: 'Effective Start Date',
                value: _formatDate(plant.effectiveStartDate),
              ),
              _DetailRow(
                label: 'Effective End Date',
                value: plant.effectiveEndDate == null
                    ? '-'
                    : _formatDate(plant.effectiveEndDate!),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _openEditForm(context),
            icon: const Icon(Icons.edit_rounded),
            label: const Text('Edit Plant'),
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
