import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Report tab — access to all generated reports.
class ReportPage extends ConsumerWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Summary Cards ───────────────────────
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  icon: Icons.description_rounded,
                  label: 'Generated',
                  value: '24',
                  color: AppColors.darkBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  icon: Icons.schedule_rounded,
                  label: 'Scheduled',
                  value: '3',
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Text('Available Reports', style: AppTextStyles.titleSmall),
          const SizedBox(height: 12),

          _ReportTile(
            icon: Icons.people_alt_rounded,
            title: 'Employee Report',
            subtitle: 'Headcount, demographics, and turnover analysis',
            onTap: () {},
          ),
          const SizedBox(height: 10),
          _ReportTile(
            icon: Icons.access_time_rounded,
            title: 'Attendance Report',
            subtitle: 'Daily/monthly attendance summary & tardiness',
            onTap: () {},
          ),
          const SizedBox(height: 10),
          _ReportTile(
            icon: Icons.payments_rounded,
            title: 'Payroll Report',
            subtitle: 'Salary, allowance, deduction & tax summaries',
            onTap: () {},
          ),
          const SizedBox(height: 10),
          _ReportTile(
            icon: Icons.event_note_rounded,
            title: 'Leave Report',
            subtitle: 'Leave balance, usage & approval stats',
            onTap: () {},
          ),
          const SizedBox(height: 10),
          _ReportTile(
            icon: Icons.trending_up_rounded,
            title: 'Performance Report',
            subtitle: 'KPI achievement & performance reviews',
            onTap: () {},
          ),
          const SizedBox(height: 10),
          _ReportTile(
            icon: Icons.receipt_long_rounded,
            title: 'Reimbursement Report',
            subtitle: 'Expense claims summary & approval status',
            onTap: () {},
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ── Summary card ────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.headlineMedium.copyWith(color: color),
          ),
          Text(label, style: AppTextStyles.labelMedium),
        ],
      ),
    );
  }
}

// ── Report tile ─────────────────────────────────────────

class _ReportTile extends StatelessWidget {
  const _ReportTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.darkBlue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 24, color: AppColors.darkBlue),
            ),
            const SizedBox(width: 14),
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
