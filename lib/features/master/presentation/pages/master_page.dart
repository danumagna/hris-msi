import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Master-data tab — entry point to all master-data modules.
class MasterPage extends ConsumerStatefulWidget {
  const MasterPage({super.key});

  @override
  ConsumerState<MasterPage> createState() => _MasterPageState();
}

class _MasterPageState extends ConsumerState<MasterPage> {
  static const _menus = [
    _MasterMenuItem(
      icon: Icons.approval_rounded,
      title: 'Approval',
      subtitle: 'Manage approval workflows',
    ),
    _MasterMenuItem(
      icon: Icons.dynamic_form_rounded,
      title: 'Form',
      subtitle: 'Manage form templates',
    ),
    _MasterMenuItem(
      icon: Icons.person_rounded,
      title: 'User',
      subtitle: 'Manage user accounts',
      route: RoutePaths.masterUser,
    ),
    _MasterMenuItem(
      icon: Icons.playlist_add_check_circle_rounded,
      title: 'Action',
      subtitle: 'Manage action settings',
      route: RoutePaths.masterAction,
    ),
    _MasterMenuItem(
      icon: Icons.business_rounded,
      title: 'Company',
      subtitle: 'Manage company data',
      route: RoutePaths.masterCompany,
    ),
    _MasterMenuItem(
      icon: Icons.account_balance_wallet_rounded,
      title: 'Cost Center',
      subtitle: 'Manage cost centers',
    ),
    _MasterMenuItem(
      icon: Icons.email_rounded,
      title: 'Email',
      subtitle: 'Manage email configurations',
    ),
    _MasterMenuItem(
      icon: Icons.people_alt_rounded,
      title: 'Employee',
      subtitle: 'Manage employee data',
      route: RoutePaths.masterEmployee,
    ),
    _MasterMenuItem(
      icon: Icons.functions_rounded,
      title: 'Formula',
      subtitle: 'Manage calculation formulas',
    ),
    _MasterMenuItem(
      icon: Icons.account_balance_rounded,
      title: 'GL Account',
      subtitle: 'Manage general ledger accounts',
    ),
    _MasterMenuItem(
      icon: Icons.group_rounded,
      title: 'Group',
      subtitle: 'Manage employee groups',
    ),
    _MasterMenuItem(
      icon: Icons.event_rounded,
      title: 'Holiday',
      subtitle: 'Manage holiday calendar',
    ),
    _MasterMenuItem(
      icon: Icons.account_tree_rounded,
      title: 'Organization Level',
      subtitle: 'Manage organization levels',
    ),
    _MasterMenuItem(
      icon: Icons.factory_rounded,
      title: 'Plant',
      subtitle: 'Manage plant locations',
      route: RoutePaths.masterPlant,
    ),
    _MasterMenuItem(
      icon: Icons.badge_rounded,
      title: 'Position',
      subtitle: 'Manage job positions',
      route: RoutePaths.masterPosition,
    ),
    _MasterMenuItem(
      icon: Icons.leaderboard_rounded,
      title: 'Position Level',
      subtitle: 'Manage position levels',
    ),
    _MasterMenuItem(
      icon: Icons.school_rounded,
      title: 'Position Major',
      subtitle: 'Manage position majors',
    ),
    _MasterMenuItem(
      icon: Icons.folder_special_rounded,
      title: 'Project',
      subtitle: 'Manage projects',
    ),
    _MasterMenuItem(
      icon: Icons.tune_rounded,
      title: 'Setting',
      subtitle: 'Master data settings',
    ),
    _MasterMenuItem(
      icon: Icons.schedule_rounded,
      title: 'Shift',
      subtitle: 'Manage work shifts',
    ),
    _MasterMenuItem(
      icon: Icons.location_on_rounded,
      title: 'Work Location',
      subtitle: 'Manage work locations',
    ),
  ];

  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  List<_MasterMenuItem> get _filteredMenus {
    final query = _query.trim().toLowerCase();
    final sortedMenus = [..._menus]
      ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

    if (query.isEmpty) return sortedMenus;

    return sortedMenus.where((menu) {
      return menu.title.toLowerCase().contains(query) ||
          menu.subtitle.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredMenus = _filteredMenus;

    return Scaffold(
      appBar: AppBar(title: const Text('Master Data')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SearchMenuField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value),
            onClear: () {
              _searchController.clear();
              setState(() => _query = '');
            },
          ),
          const SizedBox(height: 12),
          ...filteredMenus.map(
            (menu) => _MenuTile(
              icon: menu.icon,
              title: menu.title,
              subtitle: menu.subtitle,
              onTap: () {
                if (menu.route == null) return;
                context.push(menu.route!);
              },
            ),
          ),
          if (filteredMenus.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Menu tidak ditemukan',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
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

class _MasterMenuItem {
  const _MasterMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.route,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? route;
}

class _SearchMenuField extends StatelessWidget {
  const _SearchMenuField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search menu master...',
        hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: AppColors.textSecondary,
        ),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                onPressed: onClear,
                icon: const Icon(
                  Icons.close_rounded,
                  color: AppColors.textSecondary,
                ),
              ),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.accentBlue),
        ),
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
