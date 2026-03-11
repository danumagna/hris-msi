import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// System tab — settings, profile, and app administration.
class SystemPage extends ConsumerWidget {
  const SystemPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = switch (authState) {
      AuthAuthenticated(:final user) => user,
      _ => null,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('System')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Profile Card ────────────────────────
          _ProfileCard(user: user),
          const SizedBox(height: 24),

          Text('System Menu', style: AppTextStyles.titleSmall),
          const SizedBox(height: 12),

          _SettingsTile(
            icon: Icons.touch_app_rounded,
            title: 'Action',
            subtitle: 'Manage system actions',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.view_quilt_rounded,
            title: 'Appview',
            subtitle: 'Manage application views',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.link_rounded,
            title: 'Map Role Appview',
            subtitle: 'Map roles to application views',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.group_work_rounded,
            title: 'Map User Role',
            subtitle: 'Assign roles to users',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.widgets_rounded,
            title: 'Module',
            subtitle: 'Manage system modules',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.admin_panel_settings_rounded,
            title: 'Role',
            subtitle: 'Manage roles and permissions',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.people_alt_rounded,
            title: 'User',
            subtitle: 'Manage user accounts',
            onTap: () {},
          ),

          const SizedBox(height: 32),

          // ── Logout Button ──────────────────────
          SizedBox(
            width: double.infinity,

            child: OutlinedButton.icon(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Sign Out'),
                    content: const Text('Are you sure you want to sign out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        child: const Text('Sign Out'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  ref.read(authProvider.notifier).logout();
                }
              },
              icon: const Icon(Icons.logout_rounded, color: AppColors.error),
              label: Text(
                'Sign Out',
                style: AppTextStyles.button.copyWith(color: AppColors.error),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ── Profile Card ────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({this.user});
  final User? user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBlue.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.white.withValues(alpha: 0.2),
            child: Text(
              (user?.fullName ?? 'U')
                  .split(' ')
                  .take(2)
                  .map((e) => e.isNotEmpty ? e[0] : '')
                  .join(),
              style: AppTextStyles.titleLarge.copyWith(color: AppColors.white),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.fullName ?? 'User',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user?.email ?? '',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user?.role.toUpperCase() ?? '',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Settings tile ───────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
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
