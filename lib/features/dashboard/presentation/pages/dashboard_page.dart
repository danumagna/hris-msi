import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Dashboard — first tab and primary landing page after login.
///
/// Shows a greeting, quick-info cards, and common shortcuts.
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = switch (authState) {
      AuthAuthenticated(:final user) => user,
      _ => null,
    };

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ────────────────────────────────
            SliverToBoxAdapter(child: _Header(user: user)),

            // ── Quick Info Cards ──────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(child: _QuickInfoSection()),
            ),

            // ── Activity / Shortcut Grid ─────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              sliver: SliverToBoxAdapter(
                child: Text('Quick Actions', style: AppTextStyles.titleMedium),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: const _ShortcutGrid(),
            ),

            // ── Recent Activity ──────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Recent Activity',
                  style: AppTextStyles.titleMedium,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              sliver: const _RecentActivityList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ──────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({this.user});
  final User? user;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greeting = now.hour < 12
        ? 'Good Morning'
        : now.hour < 17
        ? 'Good Afternoon'
        : 'Good Evening';

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBlue.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting 👋',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  user?.fullName ?? 'User',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.role.toUpperCase() ?? '',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.white.withValues(alpha: 0.7),
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          CircleAvatar(
            radius: 28,
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
        ],
      ),
    );
  }
}

// ── Quick Info Cards ────────────────────────────────────

class _QuickInfoSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const items = [
      _InfoItem(
        icon: Icons.people_alt_rounded,
        label: 'Total Employees',
        value: '128',
        color: AppColors.darkBlue,
      ),
      _InfoItem(
        icon: Icons.check_circle_rounded,
        label: 'Present Today',
        value: '115',
        color: AppColors.success,
      ),
      _InfoItem(
        icon: Icons.event_busy_rounded,
        label: 'On Leave',
        value: '8',
        color: AppColors.warning,
      ),
      _InfoItem(
        icon: Icons.pending_actions_rounded,
        label: 'Pending Requests',
        value: '5',
        color: AppColors.info,
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: items
          .map(
            (item) => Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(item.icon, size: 18, color: item.color),
                  ),
                  const Spacer(),
                  Text(
                    item.value,
                    style: AppTextStyles.titleLarge.copyWith(
                      color: item.color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    item.label,
                    style: AppTextStyles.labelSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}

// ── Shortcut Grid ───────────────────────────────────────

class _ShortcutGrid extends StatelessWidget {
  const _ShortcutGrid();

  static const _shortcuts = [
    _ShortcutItem(Icons.fingerprint_rounded, 'Attendance'),
    _ShortcutItem(Icons.beach_access_rounded, 'Leave'),
    _ShortcutItem(Icons.account_balance_wallet_rounded, 'Payroll'),
    _ShortcutItem(Icons.assignment_rounded, 'Tasks'),
    _ShortcutItem(Icons.schedule_rounded, 'Schedule'),
    _ShortcutItem(Icons.more_horiz_rounded, 'More'),
  ];

  @override
  Widget build(BuildContext context) {
    return SliverGrid.count(
      crossAxisCount: 3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.0,
      children: _shortcuts
          .map(
            (s) => InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.darkBlue.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(s.icon, size: 22, color: AppColors.darkBlue),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      s.label,
                      style: AppTextStyles.labelMedium,
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

class _ShortcutItem {
  final IconData icon;
  final String label;
  const _ShortcutItem(this.icon, this.label);
}

// ── Recent Activity ─────────────────────────────────────

class _RecentActivityList extends StatelessWidget {
  const _RecentActivityList();

  @override
  Widget build(BuildContext context) {
    final activities = [
      _Activity(
        'Leave approved',
        'Annual leave — 3 days',
        Icons.check_circle_rounded,
        AppColors.success,
      ),
      _Activity(
        'Attendance',
        'Clock-in 08:02 AM',
        Icons.access_time_rounded,
        AppColors.info,
      ),
      _Activity(
        'Payroll processed',
        'March 2026 salary',
        Icons.payments_rounded,
        AppColors.darkBlue,
      ),
    ];

    return SliverList.separated(
      itemCount: activities.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final a = activities[i];
        return Container(
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
                  color: a.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(a.icon, size: 22, color: a.color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.title, style: AppTextStyles.titleSmall),
                    const SizedBox(height: 2),
                    Text(a.subtitle, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textHint,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Activity {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  const _Activity(this.title, this.subtitle, this.icon, this.color);
}
