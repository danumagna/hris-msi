import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/attendance_provider.dart';

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

            // ── Attendance Section ───────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(child: _AttendanceSection()),
            ),

            // ── Quick Info Cards ──────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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

// ── Attendance Section ──────────────────────────────────

class _AttendanceSection extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AttendanceSection> createState() => _AttendanceSectionState();
}

class _AttendanceSectionState extends ConsumerState<_AttendanceSection> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() => _now = DateTime.now()),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final attendance = ref.watch(attendanceProvider);
    final isCheckedIn = attendance.isCheckedIn;
    final isCheckedOut = attendance.isCheckedOut;

    final hour = _now.hour.toString().padLeft(2, '0');
    final minute = _now.minute.toString().padLeft(2, '0');
    final second = _now.second.toString().padLeft(2, '0');

    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final dateText =
        '${days[_now.weekday - 1]}, '
        '${_now.day} ${months[_now.month - 1]} ${_now.year}';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Date & Real-time clock ───────────
          Center(
            child: Text(
              dateText,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              '$hour:$minute:$second',
              style: AppTextStyles.headlineLarge.copyWith(
                color: AppColors.darkBlue,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.access_time_rounded,
                  size: 20,
                  color: AppColors.accentBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Attendance', style: AppTextStyles.titleSmall),
                    if (isCheckedIn && attendance.checkInTime != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          'Checked in at '
                          '${attendance.checkInTime!.hour.toString().padLeft(2, '0')}:'
                          '${attendance.checkInTime!.minute.toString().padLeft(2, '0')}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          // ── Attendance Summary ────────────
          if (isCheckedIn) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accentBlue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  _summaryRow(
                    Icons.schedule_rounded,
                    'Shift',
                    attendance.shift,
                  ),
                  const SizedBox(height: 8),
                  _summaryRow(
                    Icons.location_on_rounded,
                    'Work Location',
                    attendance.workLocation ?? '-',
                  ),
                  const SizedBox(height: 8),
                  _summaryRow(
                    Icons.login_rounded,
                    'Check In',
                    attendance.checkInTime != null
                        ? '${attendance.checkInTime!.hour.toString().padLeft(2, '0')}:'
                              '${attendance.checkInTime!.minute.toString().padLeft(2, '0')}'
                        : '-',
                  ),
                  if (isCheckedOut && attendance.checkOutTime != null) ...[
                    const SizedBox(height: 8),
                    _summaryRow(
                      Icons.logout_rounded,
                      'Check Out',
                      '${attendance.checkOutTime!.hour.toString().padLeft(2, '0')}:'
                          '${attendance.checkOutTime!.minute.toString().padLeft(2, '0')}',
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isCheckedIn
                      ? null
                      : () => context.push(RoutePaths.checkIn),
                  icon: const Icon(Icons.login_rounded, size: 18),
                  label: Text(
                    isCheckedIn ? 'Checked In' : 'Check In',
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: AppColors.white,
                    disabledBackgroundColor: AppColors.divider,
                    disabledForegroundColor: AppColors.textHint,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: (isCheckedIn && !isCheckedOut)
                      ? () => context.push(RoutePaths.checkOut)
                      : null,
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: Text(
                    isCheckedOut ? 'Checked Out' : 'Check Out',
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: AppColors.white,
                    disabledBackgroundColor: AppColors.divider,
                    disabledForegroundColor: AppColors.textHint,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.accentBlue),
        const SizedBox(width: 8),
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(child: Text(value, style: AppTextStyles.bodySmall)),
      ],
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
                mainAxisAlignment: MainAxisAlignment.center,
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
    _ShortcutItem(Icons.assignment_rounded, 'Task', null),
    _ShortcutItem(Icons.calendar_month_rounded, 'Calendar', null),
    _ShortcutItem(Icons.beach_access_rounded, 'Cuti', null),
    _ShortcutItem(Icons.fingerprint_rounded, 'Absent', null),
    _ShortcutItem(
      Icons.receipt_long_rounded,
      'Reimburse',
      RoutePaths.reimbursement,
    ),
    _ShortcutItem(Icons.more_time_rounded, 'Overtime', null),
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
              onTap: () {
                if (s.route != null) context.push(s.route!);
              },
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
  final String? route;
  const _ShortcutItem(this.icon, this.label, this.route);
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
