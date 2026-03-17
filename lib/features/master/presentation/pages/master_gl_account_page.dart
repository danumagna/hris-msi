import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/master_gl_account_data.dart';

class MasterGlAccountPage extends StatefulWidget {
  const MasterGlAccountPage({super.key});

  @override
  State<MasterGlAccountPage> createState() => _MasterGlAccountPageState();
}

class _MasterGlAccountPageState extends State<MasterGlAccountPage> {
  static const List<String> _statusOptions = ['All', 'Active', 'Inactive'];

  final TextEditingController _companyFilterController =
      TextEditingController();
  final TextEditingController _chartOfAccountFilterController =
      TextEditingController();
  final TextEditingController _glAccountNumberFilterController =
      TextEditingController();

  String _selectedStatusFilter = 'All';

  final List<MasterGlAccountData> _glAccounts = [
    MasterGlAccountData(
      id: 'gl-001',
      companyCode: 'MSI',
      company: 'Magna Solusi Indonesia',
      chartOfAccount: 'COA-MSI-2026',
      glAccountNumber: '110100',
      glAccountText: 'Cash on Hand',
      glAccountGroup: 'Asset',
      integration: 'Payroll',
      name: 'Cash Main Account',
      description: 'Akun kas utama operasional perusahaan',
      effectiveStartDate: DateTime(2024, 1, 1),
      isExpired: false,
      status: 'Active',
    ),
    MasterGlAccountData(
      id: 'gl-002',
      companyCode: 'MEDU',
      company: 'Magna Edu',
      chartOfAccount: 'COA-MEDU-2026',
      glAccountNumber: '210200',
      glAccountText: 'Accrued Expense',
      glAccountGroup: 'Liability',
      integration: 'Reimbursement',
      name: 'Expense Accrual',
      description: 'Akun untuk biaya akrual reimbursement',
      effectiveStartDate: DateTime(2023, 8, 1),
      isExpired: false,
      status: 'Active',
    ),
    MasterGlAccountData(
      id: 'gl-003',
      companyCode: 'MCORP',
      company: 'Magna Corp',
      chartOfAccount: 'COA-MCORP-2022',
      glAccountNumber: '510900',
      glAccountText: 'Legacy Misc Expense',
      glAccountGroup: 'Expense',
      integration: 'Legacy',
      name: 'Legacy Misc',
      description: 'Akun lama untuk biaya miscellaneous',
      effectiveStartDate: DateTime(2022, 1, 1),
      isExpired: true,
      effectiveEndDate: DateTime(2024, 12, 31),
      status: 'Inactive',
    ),
  ];

  bool get _hasActiveFilters {
    return _companyFilterController.text.trim().isNotEmpty ||
        _chartOfAccountFilterController.text.trim().isNotEmpty ||
        _glAccountNumberFilterController.text.trim().isNotEmpty ||
        _selectedStatusFilter != 'All';
  }

  List<MasterGlAccountData> get _filteredGlAccounts {
    final companyQuery = _companyFilterController.text.trim().toLowerCase();
    final chartOfAccountQuery = _chartOfAccountFilterController.text
        .trim()
        .toLowerCase();
    final glAccountNumberQuery = _glAccountNumberFilterController.text
        .trim()
        .toLowerCase();

    return _glAccounts.where((item) {
      final matchesCompany =
          companyQuery.isEmpty ||
          item.company.toLowerCase().contains(companyQuery);
      final matchesChartOfAccount =
          chartOfAccountQuery.isEmpty ||
          item.chartOfAccount.toLowerCase().contains(chartOfAccountQuery);
      final matchesGlAccountNumber =
          glAccountNumberQuery.isEmpty ||
          item.glAccountNumber.toLowerCase().contains(glAccountNumberQuery);
      final matchesStatus =
          _selectedStatusFilter == 'All' ||
          item.status == _selectedStatusFilter;

      return matchesCompany &&
          matchesChartOfAccount &&
          matchesGlAccountNumber &&
          matchesStatus;
    }).toList();
  }

  @override
  void dispose() {
    _companyFilterController.dispose();
    _chartOfAccountFilterController.dispose();
    _glAccountNumberFilterController.dispose();
    super.dispose();
  }

  Future<void> _openAddForm() async {
    final newData = await context.push<MasterGlAccountData>(
      RoutePaths.masterGlAccountAdd,
    );

    if (!mounted || newData == null) return;
    setState(() => _upsertGlAccount(newData));
  }

  Future<void> _openDetail(MasterGlAccountData item) async {
    final updatedData = await context.push<MasterGlAccountData>(
      RoutePaths.masterGlAccountDetail,
      extra: item,
    );

    if (!mounted || updatedData == null) return;
    setState(() => _upsertGlAccount(updatedData));
  }

  void _upsertGlAccount(MasterGlAccountData item) {
    final index = _glAccounts.indexWhere((existing) => existing.id == item.id);
    if (index >= 0) {
      _glAccounts[index] = item;
      return;
    }

    _glAccounts.insert(0, item);
  }

  void _resetFilters() {
    _companyFilterController.clear();
    _chartOfAccountFilterController.clear();
    _glAccountNumberFilterController.clear();
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
    final filteredItems = _filteredGlAccounts;

    return Scaffold(
      appBar: AppBar(title: const Text('Master GL Account')),
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
                  controller: _chartOfAccountFilterController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Chart of Account',
                    hintText: 'Search chart of account',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _glAccountNumberFilterController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Enter GL Account Number',
                    hintText: 'Search GL account number',
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
            const _EmptyGlAccountState()
          else
            ...filteredItems.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _GlAccountCard(
                  data: item,
                  onTap: () => _openDetail(item),
                  dateLabel: _formatDate(item.effectiveStartDate),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GlAccountCard extends StatelessWidget {
  const _GlAccountCard({
    required this.data,
    required this.onTap,
    required this.dateLabel,
  });

  final MasterGlAccountData data;
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
                Icons.account_balance_rounded,
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
                          data.glAccountNumber,
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
                  Text(data.glAccountText, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 2),
                  Text(
                    '${data.companyCode} • ${data.chartOfAccount} • $dateLabel',
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

class _EmptyGlAccountState extends StatelessWidget {
  const _EmptyGlAccountState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'Data GL account tidak ditemukan',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
