import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Master-data tab — entry point to all master-data modules.
class MasterPage extends ConsumerWidget {
  const MasterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Master Data')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Search bar ──────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: AppColors.textHint),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search master data...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textHint,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text('Organization', style: AppTextStyles.titleSmall),
          const SizedBox(height: 12),
          _MasterGrid(
            items: const [
              _MasterItem(Icons.business_rounded, 'Company'),
              _MasterItem(Icons.account_tree_rounded, 'Department'),
              _MasterItem(Icons.badge_rounded, 'Position'),
              _MasterItem(Icons.location_on_rounded, 'Location'),
            ],
          ),

          const SizedBox(height: 24),
          Text('Employee', style: AppTextStyles.titleSmall),
          const SizedBox(height: 12),
          _MasterGrid(
            items: const [
              _MasterItem(Icons.people_rounded, 'Employees'),
              _MasterItem(Icons.school_rounded, 'Education'),
              _MasterItem(Icons.work_rounded, 'Experience'),
              _MasterItem(Icons.family_restroom_rounded, 'Family'),
            ],
          ),

          const SizedBox(height: 24),
          Text('Payroll', style: AppTextStyles.titleSmall),
          const SizedBox(height: 12),
          _MasterGrid(
            items: const [
              _MasterItem(Icons.payments_rounded, 'Salary Grade'),
              _MasterItem(Icons.price_change_rounded, 'Allowances'),
              _MasterItem(Icons.money_off_rounded, 'Deductions'),
              _MasterItem(Icons.account_balance_rounded, 'Banks'),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _MasterGrid extends StatelessWidget {
  const _MasterGrid({required this.items});
  final List<_MasterItem> items;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: items
          .map(
            (item) => InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(14),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item.icon, size: 26, color: AppColors.accentBlue),
                    const SizedBox(height: 6),
                    Text(
                      item.label,
                      style: AppTextStyles.labelSmall.copyWith(fontSize: 9),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _MasterItem {
  final IconData icon;
  final String label;
  const _MasterItem(this.icon, this.label);
}
