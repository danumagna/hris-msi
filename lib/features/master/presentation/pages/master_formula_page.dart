import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/master_formula_data.dart';

class MasterFormulaPage extends StatefulWidget {
  const MasterFormulaPage({super.key});

  @override
  State<MasterFormulaPage> createState() => _MasterFormulaPageState();
}

class _MasterFormulaPageState extends State<MasterFormulaPage> {
  static const List<String> _statusOptions = ['All', 'Active', 'Inactive'];

  final TextEditingController _nameFilterController = TextEditingController();
  final TextEditingController _codeFilterController = TextEditingController();

  String _selectedStatusFilter = 'All';

  final List<MasterFormulaData> _formulas = [
    MasterFormulaData(
      id: 'fml-001',
      company: 'Magna Solusi Indonesia',
      code: 'FRM-0001',
      name: 'Overtime Basic Formula',
      description: 'Calculate overtime amount based on attendance.',
      effectiveDate: DateTime(2024, 1, 1),
      isExpired: false,
      type: 'Payroll',
      tableName: 'tbl_overtime',
      status: 'Active',
    ),
    MasterFormulaData(
      id: 'fml-002',
      company: 'Magna Edu',
      code: 'FRM-0002',
      name: 'Leave Quota Formula',
      description: 'Formula for annual leave quota accrual.',
      effectiveDate: DateTime(2023, 7, 1),
      isExpired: false,
      type: 'HR',
      tableName: 'tbl_leave',
      status: 'Active',
    ),
    MasterFormulaData(
      id: 'fml-003',
      company: 'Magna Corp',
      code: 'FRM-0003',
      name: 'Legacy Incentive Formula',
      description: 'Legacy formula for incentive simulation.',
      effectiveDate: DateTime(2021, 5, 15),
      isExpired: true,
      expirationDate: DateTime(2024, 12, 31),
      type: 'Finance',
      tableName: 'tbl_incentive',
      status: 'Inactive',
    ),
  ];

  bool get _hasActiveFilters {
    return _nameFilterController.text.trim().isNotEmpty ||
        _codeFilterController.text.trim().isNotEmpty ||
        _selectedStatusFilter != 'All';
  }

  List<MasterFormulaData> get _filteredFormulas {
    final nameQuery = _nameFilterController.text.trim().toLowerCase();
    final codeQuery = _codeFilterController.text.trim().toLowerCase();

    return _formulas.where((item) {
      final matchesName =
          nameQuery.isEmpty || item.name.toLowerCase().contains(nameQuery);
      final matchesCode =
          codeQuery.isEmpty || item.code.toLowerCase().contains(codeQuery);
      final matchesStatus =
          _selectedStatusFilter == 'All' ||
          item.status == _selectedStatusFilter;

      return matchesName && matchesCode && matchesStatus;
    }).toList();
  }

  @override
  void dispose() {
    _nameFilterController.dispose();
    _codeFilterController.dispose();
    super.dispose();
  }

  Future<void> _openAddForm() async {
    final newData = await context.push<MasterFormulaData>(
      RoutePaths.masterFormulaAdd,
    );

    if (!mounted || newData == null) return;
    setState(() => _upsertFormula(newData));
  }

  Future<void> _openDetail(MasterFormulaData item) async {
    final updatedData = await context.push<MasterFormulaData>(
      RoutePaths.masterFormulaDetail,
      extra: item,
    );

    if (!mounted || updatedData == null) return;
    setState(() => _upsertFormula(updatedData));
  }

  void _upsertFormula(MasterFormulaData item) {
    final index = _formulas.indexWhere((existing) => existing.id == item.id);
    if (index >= 0) {
      _formulas[index] = item;
      return;
    }

    _formulas.insert(0, item);
  }

  void _resetFilters() {
    _nameFilterController.clear();
    _codeFilterController.clear();
    _selectedStatusFilter = 'All';
    setState(() {});
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _filteredFormulas;

    return Scaffold(
      appBar: AppBar(title: const Text('Master Formula')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        children: [
          ElevatedButton.icon(
            onPressed: _openAddForm,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add Form'),
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
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _nameFilterController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'Search name',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _codeFilterController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Code',
                    hintText: 'Search code',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: _selectedStatusFilter,
                  items: _statusOptions
                      .map(
                        (option) => DropdownMenuItem(
                          value: option,
                          child: Text(option),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedStatusFilter = value);
                  },
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (filteredItems.isEmpty)
            const _EmptyFormulaState()
          else
            ...filteredItems.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _FormulaCard(
                  data: item,
                  onTap: () => _openDetail(item),
                  dateLabel: _formatDate(item.effectiveDate),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FormulaCard extends StatelessWidget {
  const _FormulaCard({
    required this.data,
    required this.onTap,
    required this.dateLabel,
  });

  final MasterFormulaData data;
  final VoidCallback onTap;
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    final statusColor = data.isActive ? AppColors.success : AppColors.error;

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
                Icons.functions_rounded,
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
                        child: Text(data.code, style: AppTextStyles.titleSmall),
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
                          data.status,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(data.name, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 2),
                  Text(
                    '${data.company} • ${data.type} • $dateLabel',
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

class _EmptyFormulaState extends StatelessWidget {
  const _EmptyFormulaState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'Data formula tidak ditemukan',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
