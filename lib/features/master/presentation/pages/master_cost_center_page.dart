import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/master_cost_center_data.dart';

class MasterCostCenterPage extends StatefulWidget {
  const MasterCostCenterPage({super.key});

  @override
  State<MasterCostCenterPage> createState() => _MasterCostCenterPageState();
}

class _MasterCostCenterPageState extends State<MasterCostCenterPage> {
  static const List<String> _statusOptions = ['All', 'Active', 'Inactive'];

  final TextEditingController _companyFilterController =
      TextEditingController();
  final TextEditingController _nameFilterController = TextEditingController();
  final TextEditingController _codeFilterController = TextEditingController();

  String _selectedStatusFilter = 'All';

  final List<MasterCostCenterData> _costCenters = [
    MasterCostCenterData(
      id: 'cc-001',
      company: 'Magna Solusi Indonesia',
      code: 'CC-0001',
      name: 'Production Operations',
      description: 'Operational cost center for production line',
      effectiveDate: DateTime(2024, 1, 1),
      isExpired: false,
      status: 'Active',
    ),
    MasterCostCenterData(
      id: 'cc-002',
      company: 'Magna Solusi Indonesia',
      code: 'CC-0002',
      name: 'Human Capital',
      description: 'Cost center for HR and people development',
      effectiveDate: DateTime(2023, 6, 1),
      isExpired: false,
      status: 'Active',
    ),
    MasterCostCenterData(
      id: 'cc-003',
      company: 'Magna Edu',
      code: 'CC-0003',
      name: 'Legacy Project Team',
      description: 'Legacy cost center for completed project',
      effectiveDate: DateTime(2021, 1, 1),
      isExpired: true,
      expirationDate: DateTime(2024, 12, 31),
      status: 'Inactive',
    ),
  ];

  bool get _hasActiveFilters {
    return _companyFilterController.text.trim().isNotEmpty ||
        _nameFilterController.text.trim().isNotEmpty ||
        _codeFilterController.text.trim().isNotEmpty ||
        _selectedStatusFilter != 'All';
  }

  List<MasterCostCenterData> get _filteredCostCenters {
    final companyQuery = _companyFilterController.text.trim().toLowerCase();
    final nameQuery = _nameFilterController.text.trim().toLowerCase();
    final codeQuery = _codeFilterController.text.trim().toLowerCase();

    return _costCenters.where((item) {
      final matchesCompany =
          companyQuery.isEmpty ||
          item.company.toLowerCase().contains(companyQuery);
      final matchesName =
          nameQuery.isEmpty || item.name.toLowerCase().contains(nameQuery);
      final matchesCode =
          codeQuery.isEmpty || item.code.toLowerCase().contains(codeQuery);
      final matchesStatus =
          _selectedStatusFilter == 'All' ||
          item.status == _selectedStatusFilter;

      return matchesCompany && matchesName && matchesCode && matchesStatus;
    }).toList();
  }

  @override
  void dispose() {
    _companyFilterController.dispose();
    _nameFilterController.dispose();
    _codeFilterController.dispose();
    super.dispose();
  }

  Future<void> _openAddForm() async {
    final newData = await context.push<MasterCostCenterData>(
      RoutePaths.masterCostCenterAdd,
    );

    if (!mounted || newData == null) return;
    setState(() => _upsertCostCenter(newData));
  }

  Future<void> _openDetail(MasterCostCenterData item) async {
    final updatedData = await context.push<MasterCostCenterData>(
      RoutePaths.masterCostCenterDetail,
      extra: item,
    );

    if (!mounted || updatedData == null) return;
    setState(() => _upsertCostCenter(updatedData));
  }

  void _upsertCostCenter(MasterCostCenterData item) {
    final index = _costCenters.indexWhere((existing) => existing.id == item.id);
    if (index >= 0) {
      _costCenters[index] = item;
      return;
    }

    _costCenters.insert(0, item);
  }

  void _resetFilters() {
    _companyFilterController.clear();
    _nameFilterController.clear();
    _codeFilterController.clear();
    _selectedStatusFilter = 'All';
    setState(() {});
  }

  void _exportToExcel() {
    final totalRows = _filteredCostCenters.length;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Export to Excel berhasil (dummy UI). $totalRows data.'),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _filteredCostCenters;

    return Scaffold(
      appBar: AppBar(title: const Text('Master Cost Center')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        children: [
          ElevatedButton.icon(
            onPressed: _openAddForm,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add Form'),
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
                  controller: _companyFilterController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Company',
                    hintText: 'Search company',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
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
            const _EmptyCostCenterState()
          else
            ...filteredItems.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _CostCenterCard(
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

class _CostCenterCard extends StatelessWidget {
  const _CostCenterCard({
    required this.data,
    required this.onTap,
    required this.dateLabel,
  });

  final MasterCostCenterData data;
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
                Icons.account_balance_wallet_rounded,
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
                    '${data.company} • $dateLabel',
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

class _EmptyCostCenterState extends StatelessWidget {
  const _EmptyCostCenterState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'Data cost center tidak ditemukan',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
