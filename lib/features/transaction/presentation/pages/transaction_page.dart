import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Transaction tab — list of HR transactions.
///
/// Placeholder that will be expanded per-module
/// (leave, attendance, payroll, etc.).
class TransactionPage extends ConsumerWidget {
  const TransactionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _TransactionCategoryCard(
            icon: Icons.beach_access_rounded,
            title: 'Leave Request',
            subtitle: 'Apply for annual, sick, or personal leave',
            color: AppColors.info,
            onTap: () => context.push(RoutePaths.leave),
          ),
          const SizedBox(height: 12),
          _TransactionCategoryCard(
            icon: Icons.fingerprint_rounded,
            title: 'Attendance',
            subtitle: 'Clock in/out and view attendance log',
            color: AppColors.success,
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _TransactionCategoryCard(
            icon: Icons.receipt_long_rounded,
            title: 'Reimbursement',
            subtitle: 'Submit expense claims',
            color: AppColors.warning,
            onTap: () => context.push(RoutePaths.reimbursement),
          ),
          const SizedBox(height: 12),
          _TransactionCategoryCard(
            icon: Icons.work_history_rounded,
            title: 'Overtime',
            subtitle: 'Request and track overtime hours',
            color: AppColors.accentBlue,
            onTap: () => context.push(RoutePaths.overtime),
          ),
          const SizedBox(height: 12),
          _TransactionCategoryCard(
            icon: Icons.swap_horiz_rounded,
            title: 'Transfer',
            subtitle: 'Employee transfer & mutation requests',
            color: AppColors.darkBlue,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _TransactionCategoryCard extends StatelessWidget {
  const _TransactionCategoryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 26, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.titleSmall),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}
