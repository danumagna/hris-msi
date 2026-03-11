import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Root shell that wraps the five main tabs with a
/// [BottomNavigationBar].
///
/// Uses [StatefulShellRoute] integration via GoRouter
/// so each tab keeps its own navigation stack.
class MainShellPage extends StatelessWidget {
  const MainShellPage({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  // Tab metadata in display order
  static const _tabs = [
    _TabItem(
      icon: Icons.dashboard_rounded,
      label: 'Dashboard',
    ),
    _TabItem(
      icon: Icons.swap_horiz_rounded,
      label: 'Transaction',
    ),
    _TabItem(
      icon: Icons.storage_rounded,
      label: 'Master',
    ),
    _TabItem(
      icon: Icons.settings_rounded,
      label: 'System',
    ),
    _TabItem(
      icon: Icons.bar_chart_rounded,
      label: 'Report',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.darkBlue.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                _tabs.length,
                (i) => _NavBarItem(
                  icon: _tabs[i].icon,
                  label: _tabs[i].label,
                  isSelected: navigationShell.currentIndex == i,
                  onTap: () => navigationShell.goBranch(
                    i,
                    initialLocation:
                        i == navigationShell.currentIndex,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Tab descriptor ──────────────────────────────────────

class _TabItem {
  final IconData icon;
  final String label;

  const _TabItem({required this.icon, required this.label});
}

// ── Individual Nav-bar Item ─────────────────────────────

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.darkBlue.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected
                  ? AppColors.darkBlue
                  : AppColors.textHint,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected
                    ? AppColors.darkBlue
                    : AppColors.textHint,
                fontWeight: isSelected
                    ? FontWeight.w600
                    : FontWeight.w400,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
