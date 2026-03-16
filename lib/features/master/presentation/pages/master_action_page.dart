import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/master_action_data.dart';

class MasterActionPage extends StatefulWidget {
  const MasterActionPage({super.key});

  @override
  State<MasterActionPage> createState() => _MasterActionPageState();
}

class _MasterActionPageState extends State<MasterActionPage> {
  final TextEditingController _actionNameFilterController =
      TextEditingController();
  final TextEditingController _actionCodeFilterController =
      TextEditingController();
  final TextEditingController _actionUserFilterController =
      TextEditingController();
  final TextEditingController _emailFilterController = TextEditingController();

  final List<MasterActionData> _actions = [
    MasterActionData(
      id: 'act-001',
      actionCode: 'LEAVEA-1001',
      actionName: 'Leave Approval',
      actionRole: 'Manager',
      validAction: DateTime(2024, 1, 10),
      actionUser: 'Department Manager',
      email: 'manager@msi.com',
      status: 'Active',
    ),
    MasterActionData(
      id: 'act-002',
      actionCode: 'REIMBU-1002',
      actionName: 'Reimbursement Review',
      actionRole: 'HR Admin',
      validAction: DateTime(2023, 7, 1),
      actionUser: 'HR Administrator',
      email: 'hr.admin@msi.com',
      status: 'Active',
      modifiedBy: 'Nadia Putri',
      modifiedDate: DateTime(2025, 2, 1),
    ),
    MasterActionData(
      id: 'act-003',
      actionCode: 'OTREQX-1003',
      actionName: 'Overtime Request',
      actionRole: 'Employee',
      validAction: DateTime(2022, 5, 12),
      endUntil: DateTime(2024, 12, 31),
      actionUser: 'Employee User',
      email: 'employee@msi.com',
      status: 'Inactive',
    ),
  ];

  String _statusFilter = 'all';
  DateTime? _validStartFilter;
  DateTime? _validEndFilter;
  bool _isFilterExpanded = false;

  bool get _hasActiveFilters {
    return _actionNameFilterController.text.trim().isNotEmpty ||
        _actionCodeFilterController.text.trim().isNotEmpty ||
        _actionUserFilterController.text.trim().isNotEmpty ||
        _emailFilterController.text.trim().isNotEmpty ||
        _statusFilter != 'all' ||
        _validStartFilter != null ||
        _validEndFilter != null;
  }

  int get _activeFilterCount {
    var count = 0;

    if (_actionNameFilterController.text.trim().isNotEmpty) count++;
    if (_actionCodeFilterController.text.trim().isNotEmpty) count++;
    if (_actionUserFilterController.text.trim().isNotEmpty) count++;
    if (_emailFilterController.text.trim().isNotEmpty) count++;
    if (_statusFilter != 'all') count++;
    if (_validStartFilter != null) count++;
    if (_validEndFilter != null) count++;

    return count;
  }

  List<String> get _activeFilterSummaries {
    final summaries = <String>[];

    if (_actionNameFilterController.text.trim().isNotEmpty) {
      summaries.add('Action Name');
    }
    if (_actionCodeFilterController.text.trim().isNotEmpty) {
      summaries.add('Action Code');
    }
    if (_actionUserFilterController.text.trim().isNotEmpty) {
      summaries.add('Action User');
    }
    if (_emailFilterController.text.trim().isNotEmpty) {
      summaries.add('Email');
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

  List<MasterActionData> get _filteredActions {
    final actionNameQuery = _actionNameFilterController.text
        .trim()
        .toLowerCase();
    final actionCodeQuery = _actionCodeFilterController.text
        .trim()
        .toLowerCase();
    final actionUserQuery = _actionUserFilterController.text
        .trim()
        .toLowerCase();
    final emailQuery = _emailFilterController.text.trim().toLowerCase();

    return _actions.where((action) {
      final matchesActionName =
          actionNameQuery.isEmpty ||
          action.actionName.toLowerCase().contains(actionNameQuery);
      final matchesActionCode =
          actionCodeQuery.isEmpty ||
          action.actionCode.toLowerCase().contains(actionCodeQuery);
      final matchesActionUser =
          actionUserQuery.isEmpty ||
          action.actionUser.toLowerCase().contains(actionUserQuery);
      final matchesEmail =
          emailQuery.isEmpty || action.email.toLowerCase().contains(emailQuery);

      final matchesStatus = switch (_statusFilter) {
        'active' => action.status.toLowerCase() == 'active',
        'inactive' => action.status.toLowerCase() == 'inactive',
        _ => true,
      };

      final matchesValidStart =
          _validStartFilter == null ||
          _isSameDate(action.validAction, _validStartFilter!);

      final matchesValidEnd =
          _validEndFilter == null ||
          (action.endUntil != null &&
              _isSameDate(action.endUntil!, _validEndFilter!));

      return matchesActionName &&
          matchesActionCode &&
          matchesActionUser &&
          matchesEmail &&
          matchesStatus &&
          matchesValidStart &&
          matchesValidEnd;
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
    _actionNameFilterController.dispose();
    _actionCodeFilterController.dispose();
    _actionUserFilterController.dispose();
    _emailFilterController.dispose();
    super.dispose();
  }

  Future<void> _openAddActionForm() async {
    final newAction = await context.push<MasterActionData>(
      RoutePaths.masterActionAdd,
    );

    if (!mounted || newAction == null) return;
    setState(() => _upsertAction(newAction));
  }

  Future<void> _openActionDetail(MasterActionData action) async {
    final updatedAction = await context.push<MasterActionData>(
      RoutePaths.masterActionDetail,
      extra: action,
    );

    if (!mounted || updatedAction == null) return;
    setState(() => _upsertAction(updatedAction));
  }

  void _upsertAction(MasterActionData action) {
    final index = _actions.indexWhere((item) => item.id == action.id);
    if (index >= 0) {
      _actions[index] = action;
      return;
    }

    _actions.insert(0, action);
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
    _actionNameFilterController.clear();
    _actionCodeFilterController.clear();
    _actionUserFilterController.clear();
    _emailFilterController.clear();
    setState(() {
      _statusFilter = 'all';
      _validStartFilter = null;
      _validEndFilter = null;
      _isFilterExpanded = false;
    });
  }

  void _exportToExcel() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export to Excel berhasil (dummy UI).')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredActions = _filteredActions;

    return Scaffold(
      appBar: AppBar(title: const Text('Master Action')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        children: [
          ElevatedButton.icon(
            onPressed: _openAddActionForm,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add Action'),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _exportToExcel,
            icon: const Icon(Icons.table_view_rounded, size: 18),
            label: const Text('Export to Excel'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: AppColors.white,
            ),
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
                        controller: _actionNameFilterController,
                        label: 'Action Name',
                        hintText: 'Search action name',
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 10),
                      _FilterTextField(
                        controller: _actionCodeFilterController,
                        label: 'Action Code',
                        hintText: 'Search action code',
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 10),
                      _FilterTextField(
                        controller: _actionUserFilterController,
                        label: 'Action User',
                        hintText: 'Search action user',
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
          if (filteredActions.isEmpty)
            const _EmptyActionState()
          else
            ...filteredActions.map(
              (action) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ActionCard(
                  action: action,
                  onTap: () => _openActionDetail(action),
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

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.action, required this.onTap});

  final MasterActionData action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = action.isActive ? AppColors.success : AppColors.error;

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
                Icons.playlist_add_check_circle_rounded,
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
                          action.actionCode,
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
                          action.status,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(action.actionName, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 2),
                  Text(
                    '${action.actionRole} • ${action.actionUser}',
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

class _EmptyActionState extends StatelessWidget {
  const _EmptyActionState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'Data action tidak ditemukan',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
