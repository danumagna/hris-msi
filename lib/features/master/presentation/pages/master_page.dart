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
        children: const [
          _MenuTile(
            icon: Icons.approval_rounded,
            title: 'Approval',
            subtitle: 'Manage approval workflows',
          ),
          _MenuTile(
            icon: Icons.business_rounded,
            title: 'Company',
            subtitle: 'Manage company data',
          ),
          _MenuTile(
            icon: Icons.account_balance_wallet_rounded,
            title: 'Cost Center',
            subtitle: 'Manage cost centers',
          ),
          _MenuTile(
            icon: Icons.email_rounded,
            title: 'Email',
            subtitle: 'Manage email configurations',
          ),
          _MenuTile(
            icon: Icons.people_alt_rounded,
            title: 'Employee',
            subtitle: 'Manage employee data',
          ),
          _MenuTile(
            icon: Icons.functions_rounded,
            title: 'Formula',
            subtitle: 'Manage calculation formulas',
          ),
          _MenuTile(
            icon: Icons.account_balance_rounded,
            title: 'GL Account',
            subtitle: 'Manage general ledger accounts',
          ),
          _MenuTile(
            icon: Icons.group_rounded,
            title: 'Group',
            subtitle: 'Manage employee groups',
          ),
          _MenuTile(
            icon: Icons.event_rounded,
            title: 'Holiday',
            subtitle: 'Manage holiday calendar',
          ),
          _MenuTile(
            icon: Icons.account_tree_rounded,
            title: 'Organization Level',
            subtitle: 'Manage organization levels',
          ),
          _MenuTile(
            icon: Icons.factory_rounded,
            title: 'Plant',
            subtitle: 'Manage plant locations',
          ),
          _MenuTile(
            icon: Icons.badge_rounded,
            title: 'Position',
            subtitle: 'Manage job positions',
          ),
          _MenuTile(
            icon: Icons.leaderboard_rounded,
            title: 'Position Level',
            subtitle: 'Manage position levels',
          ),
          _MenuTile(
            icon: Icons.school_rounded,
            title: 'Position Major',
            subtitle: 'Manage position majors',
          ),
          _MenuTile(
            icon: Icons.folder_special_rounded,
            title: 'Project',
            subtitle: 'Manage projects',
          ),
          _MenuTile(
            icon: Icons.tune_rounded,
            title: 'Setting',
            subtitle: 'Master data settings',
          ),
          _MenuTile(
            icon: Icons.schedule_rounded,
            title: 'Shift',
            subtitle: 'Manage work shifts',
          ),
          _MenuTile(
            icon: Icons.location_on_rounded,
            title: 'Work Location',
            subtitle: 'Manage work locations',
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ── Menu Tile ───────────────────────────────────────────

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {},
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
                  color: AppColors.accentBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 22, color: AppColors.accentBlue),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.titleSmall),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textHint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
