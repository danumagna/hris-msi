import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/master_user_data.dart';

class MasterUserPage extends StatefulWidget {
  const MasterUserPage({super.key});

  @override
  State<MasterUserPage> createState() => _MasterUserPageState();
}

class _MasterUserPageState extends State<MasterUserPage> {
  final TextEditingController _userNameFilterController =
      TextEditingController();
  final TextEditingController _userCodeFilterController =
      TextEditingController();
  final TextEditingController _roleUserFilterController =
      TextEditingController();
  final TextEditingController _emailFilterController = TextEditingController();
  final TextEditingController _employeeIdFilterController =
      TextEditingController();
  final TextEditingController _passwordFilterController =
      TextEditingController();

  final List<MasterUserData> _users = [
    MasterUserData(
      id: 'usr-001',
      userCode: 'ALIFI-1001',
      userName: 'Alifi Ramadhan',
      email: 'alifi.ramadhan@msi.com',
      roleUser: 'HR Admin',
      validAction: DateTime(2024, 1, 15),
      employeeId: 'EMP-1001',
      password: 'Pass@123',
    ),
    MasterUserData(
      id: 'usr-002',
      userCode: 'DEWIX-2002',
      userName: 'Dewi Kartika',
      email: 'dewi.kartika@msi.com',
      roleUser: 'Manager',
      validAction: DateTime(2023, 8, 1),
      employeeId: 'EMP-1002',
      password: 'Mng#456',
    ),
    MasterUserData(
      id: 'usr-003',
      userCode: 'RIZKA-3003',
      userName: 'Rizky Saputra',
      email: 'rizky.saputra@msi.com',
      roleUser: 'Employee',
      validAction: DateTime(2022, 3, 10),
      endUntil: DateTime(2024, 12, 31),
      employeeId: 'EMP-1003',
      password: 'Emp!789',
    ),
  ];

  String _statusFilter = 'all';
  DateTime? _validStartFilter;
  DateTime? _validEndFilter;
  bool _isFilterExpanded = false;

  bool get _hasActiveFilters {
    return _userNameFilterController.text.trim().isNotEmpty ||
        _userCodeFilterController.text.trim().isNotEmpty ||
        _roleUserFilterController.text.trim().isNotEmpty ||
        _emailFilterController.text.trim().isNotEmpty ||
        _employeeIdFilterController.text.trim().isNotEmpty ||
        _passwordFilterController.text.trim().isNotEmpty ||
        _statusFilter != 'all' ||
        _validStartFilter != null ||
        _validEndFilter != null;
  }

  int get _activeFilterCount {
    var count = 0;

    if (_userNameFilterController.text.trim().isNotEmpty) count++;
    if (_userCodeFilterController.text.trim().isNotEmpty) count++;
    if (_roleUserFilterController.text.trim().isNotEmpty) count++;
    if (_emailFilterController.text.trim().isNotEmpty) count++;
    if (_employeeIdFilterController.text.trim().isNotEmpty) count++;
    if (_passwordFilterController.text.trim().isNotEmpty) count++;
    if (_statusFilter != 'all') count++;
    if (_validStartFilter != null) count++;
    if (_validEndFilter != null) count++;

    return count;
  }

  List<String> get _activeFilterSummaries {
    final summaries = <String>[];

    if (_userNameFilterController.text.trim().isNotEmpty) {
      summaries.add('User Name');
    }
    if (_userCodeFilterController.text.trim().isNotEmpty) {
      summaries.add('User Code');
    }
    if (_roleUserFilterController.text.trim().isNotEmpty) {
      summaries.add('Role User');
    }
    if (_emailFilterController.text.trim().isNotEmpty) {
      summaries.add('Email');
    }
    if (_employeeIdFilterController.text.trim().isNotEmpty) {
      summaries.add('Employee ID');
    }
    if (_passwordFilterController.text.trim().isNotEmpty) {
      summaries.add('Password');
    }
    if (_statusFilter != 'all') {
      summaries.add('Status: $_statusLabel');
    }
    if (_validStartFilter != null) {
      summaries.add('Valid Start: ${_formatDate(_validStartFilter!)}');
    }
    if (_validEndFilter != null) {
      summaries.add('Valid End: ${_formatDate(_validEndFilter!)}');
    }

    return summaries;
  }

  List<MasterUserData> get _filteredUsers {
    final userNameQuery = _userNameFilterController.text.trim().toLowerCase();
    final userCodeQuery = _userCodeFilterController.text.trim().toLowerCase();
    final roleUserQuery = _roleUserFilterController.text.trim().toLowerCase();
    final emailQuery = _emailFilterController.text.trim().toLowerCase();
    final employeeIdQuery = _employeeIdFilterController.text
        .trim()
        .toLowerCase();
    final passwordQuery = _passwordFilterController.text.trim().toLowerCase();

    return _users.where((user) {
      final matchesUserName =
          userNameQuery.isEmpty ||
          user.userName.toLowerCase().contains(userNameQuery);
      final matchesUserCode =
          userCodeQuery.isEmpty ||
          user.userCode.toLowerCase().contains(userCodeQuery);
      final matchesRoleUser =
          roleUserQuery.isEmpty ||
          user.roleUser.toLowerCase().contains(roleUserQuery);
      final matchesEmail =
          emailQuery.isEmpty || user.email.toLowerCase().contains(emailQuery);
      final matchesEmployeeId =
          employeeIdQuery.isEmpty ||
          user.employeeId.toLowerCase().contains(employeeIdQuery);
      final matchesPassword =
          passwordQuery.isEmpty ||
          user.password.toLowerCase().contains(passwordQuery);

      final matchesStatus = switch (_statusFilter) {
        'active' => user.isActive,
        'inactive' => !user.isActive,
        _ => true,
      };

      final matchesValidStart =
          _validStartFilter == null ||
          _isSameDate(user.validAction, _validStartFilter!);

      final matchesValidEnd =
          _validEndFilter == null ||
          (user.endUntil != null &&
              _isSameDate(user.endUntil!, _validEndFilter!));

      return matchesUserName &&
          matchesUserCode &&
          matchesRoleUser &&
          matchesEmail &&
          matchesStatus &&
          matchesValidStart &&
          matchesValidEnd &&
          matchesEmployeeId &&
          matchesPassword;
    }).toList();
  }

  bool _isSameDate(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String get _statusLabel {
    return switch (_statusFilter) {
      'active' => 'Active',
      'inactive' => 'Inactive',
      _ => 'All Status',
    };
  }

  @override
  void dispose() {
    _userNameFilterController.dispose();
    _userCodeFilterController.dispose();
    _roleUserFilterController.dispose();
    _emailFilterController.dispose();
    _employeeIdFilterController.dispose();
    _passwordFilterController.dispose();
    super.dispose();
  }

  Future<void> _openAddUserForm() async {
    final newUser = await context.push<MasterUserData>(
      RoutePaths.masterUserAdd,
    );

    if (!mounted || newUser == null) return;
    setState(() => _upsertUser(newUser));
  }

  Future<void> _openUserDetail(MasterUserData user) async {
    final updatedUser = await context.push<MasterUserData>(
      RoutePaths.masterUserDetail,
      extra: user,
    );

    if (!mounted || updatedUser == null) return;
    setState(() => _upsertUser(updatedUser));
  }

  void _upsertUser(MasterUserData user) {
    final index = _users.indexWhere((item) => item.id == user.id);
    if (index >= 0) {
      _users[index] = user;
      return;
    }

    _users.insert(0, user);
  }

  Future<void> _pickValidStart() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _validStartFilter ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null) return;
    setState(() => _validStartFilter = selectedDate);
  }

  Future<void> _pickValidEnd() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _validEndFilter ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null) return;
    setState(() => _validEndFilter = selectedDate);
  }

  void _clearValidStart() {
    setState(() => _validStartFilter = null);
  }

  void _clearValidEnd() {
    setState(() => _validEndFilter = null);
  }

  Future<void> _pickStatus() async {
    final current = _statusFilter;
    final result = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text('Filter by Status', style: AppTextStyles.titleMedium),
              const SizedBox(height: 8),
              ListTile(
                leading: Icon(
                  Icons.all_inclusive_rounded,
                  color: current == 'all'
                      ? AppColors.darkBlue
                      : AppColors.textHint,
                ),
                title: const Text('All Status'),
                selected: current == 'all',
                onTap: () => Navigator.pop(sheetContext, 'all'),
              ),
              ListTile(
                leading: Icon(
                  Icons.check_circle_rounded,
                  color: current == 'active'
                      ? AppColors.darkBlue
                      : AppColors.textHint,
                ),
                title: const Text('Active'),
                selected: current == 'active',
                onTap: () => Navigator.pop(sheetContext, 'active'),
              ),
              ListTile(
                leading: Icon(
                  Icons.cancel_rounded,
                  color: current == 'inactive'
                      ? AppColors.darkBlue
                      : AppColors.textHint,
                ),
                title: const Text('Inactive'),
                selected: current == 'inactive',
                onTap: () => Navigator.pop(sheetContext, 'inactive'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (!mounted || result == null) return;
    setState(() => _statusFilter = result);
  }

  void _resetFilters() {
    _userNameFilterController.clear();
    _userCodeFilterController.clear();
    _roleUserFilterController.clear();
    _emailFilterController.clear();
    _employeeIdFilterController.clear();
    _passwordFilterController.clear();
    setState(() {
      _statusFilter = 'all';
      _validStartFilter = null;
      _validEndFilter = null;
      _isFilterExpanded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = _filteredUsers;

    return Scaffold(
      appBar: AppBar(title: const Text('Master User')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        children: [
          ElevatedButton.icon(
            onPressed: _openAddUserForm,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add User'),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Filter',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (_activeFilterCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentBlue.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '$_activeFilterCount aktif',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.accentBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    TextButton.icon(
                      onPressed: _hasActiveFilters ? _resetFilters : null,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Reset Filter'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        minimumSize: Size.zero,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _isFilterExpanded = !_isFilterExpanded;
                        });
                      },
                      tooltip: _isFilterExpanded
                          ? 'Sembunyikan filter'
                          : 'Tampilkan filter',
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        _isFilterExpanded
                            ? Icons.expand_less_rounded
                            : Icons.expand_more_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 220),
                  firstCurve: Curves.easeOut,
                  secondCurve: Curves.easeIn,
                  crossFadeState: _isFilterExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: _hasActiveFilters
                        ? Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _activeFilterSummaries
                                .map(
                                  (summary) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: AppColors.divider,
                                      ),
                                    ),
                                    child: Text(
                                      summary,
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          )
                        : Text(
                            'Filter disembunyikan. Tekan tombol panah untuk menampilkan.',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                  ),
                  secondChild: Column(
                    children: [
                      _FilterTextField(
                        controller: _userNameFilterController,
                        label: 'User Name',
                        hintText: 'Search user name',
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 10),
                      _FilterTextField(
                        controller: _userCodeFilterController,
                        label: 'User Code',
                        hintText: 'Search user code',
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 10),
                      _FilterTextField(
                        controller: _roleUserFilterController,
                        label: 'Role User',
                        hintText: 'Search role user',
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 10),
                      _FilterTextField(
                        controller: _emailFilterController,
                        label: 'Email',
                        hintText: 'Search email',
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 10),
                      _FilterTextField(
                        controller: _employeeIdFilterController,
                        label: 'Employee ID',
                        hintText: 'Search employee id',
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 10),
                      _FilterTextField(
                        controller: _passwordFilterController,
                        label: 'Password',
                        hintText: 'Search password',
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 10),
                      _FilterChipField(
                        icon: Icons.toggle_on_rounded,
                        label: _statusLabel,
                        onTap: _pickStatus,
                      ),
                      const SizedBox(height: 10),
                      _FilterChipField(
                        icon: Icons.event_available_rounded,
                        label: _validStartFilter == null
                            ? 'Valid Start'
                            : 'Valid Start: ${_formatDate(_validStartFilter!)}',
                        onTap: _pickValidStart,
                        onClear: _validStartFilter == null
                            ? null
                            : _clearValidStart,
                      ),
                      const SizedBox(height: 10),
                      _FilterChipField(
                        icon: Icons.event_busy_rounded,
                        label: _validEndFilter == null
                            ? 'Valid End'
                            : 'Valid End: ${_formatDate(_validEndFilter!)}',
                        onTap: _pickValidEnd,
                        onClear: _validEndFilter == null
                            ? null
                            : _clearValidEnd,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (filteredUsers.isEmpty)
            const _EmptyUserState()
          else
            ...filteredUsers.map(
              (user) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _UserCard(
                  user: user,
                  onTap: () => _openUserDetail(user),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterTextField extends StatelessWidget {
  const _FilterTextField({
    required this.controller,
    required this.label,
    required this.hintText,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }
}

class _FilterChipField extends StatelessWidget {
  const _FilterChipField({
    required this.icon,
    required this.label,
    required this.onTap,
    this.onClear,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.accentBlue),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.labelMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: const Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({required this.user, required this.onTap});

  final MasterUserData user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = user.isActive ? AppColors.success : AppColors.error;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
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
              child: const Icon(
                Icons.person_rounded,
                color: AppColors.accentBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.userCode,
                          style: AppTextStyles.titleSmall,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          user.statusLabel,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(user.userName, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 2),
                  Text(
                    '${user.roleUser} • ${user.email}',
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
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

class _EmptyUserState extends StatelessWidget {
  const _EmptyUserState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'Data user tidak ditemukan',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
