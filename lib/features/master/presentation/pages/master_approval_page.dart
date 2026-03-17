import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/master_approval_data.dart';

class MasterApprovalPage extends StatefulWidget {
  const MasterApprovalPage({super.key});

  @override
  State<MasterApprovalPage> createState() => _MasterApprovalPageState();
}

class _MasterApprovalPageState extends State<MasterApprovalPage> {
  static const List<String> _allOption = ['All'];
  static const List<String> _transactionOptions = [
    'Leave Request',
    'Overtime Request',
    'Reimbursement',
    'Transfer Request',
  ];
  static const List<String> _actionOptions = ['Approve', 'Review', 'Verify'];
  static const List<String> _statusOptions = ['Active', 'Inactive'];
  static const List<String> _companyCodeOptions = ['MSI', 'MEDU', 'MCORP'];

  final TextEditingController _organizationFilterController =
      TextEditingController();

  String _selectedTransactionFilter = 'All';
  String _selectedActionFilter = 'All';
  String _selectedStatusFilter = 'All';
  String _selectedCompanyCodeFilter = 'All';

  final List<MasterApprovalData> _approvals = [
    MasterApprovalData(
      id: 'apr-001',
      code: 'APR-0001',
      companyCode: 'MSI',
      companyName: 'Magna Solusi Indonesia',
      transaction: 'Leave Request',
      plant: 'Plant A',
      organization: 'Human Resource',
      organizationLevel: 'Level 2',
      action: 'Approve',
      employee: 'superadmin',
      approvalMax: 2,
      effectiveStartDate: DateTime(2024, 1, 1),
      expired: false,
      status: 'Active',
      flows: [
        const MasterApprovalFlowData(
          approvalLevel: 'Level 1',
          employee: 'hr.reviewer',
          positionCode: 'POS-HR-01',
          mandatory: true,
          value: '1',
        ),
        const MasterApprovalFlowData(
          approvalLevel: 'Level 2',
          employee: 'hr.manager',
          positionCode: 'POS-HR-02',
          mandatory: true,
          value: '2',
        ),
      ],
    ),
    MasterApprovalData(
      id: 'apr-002',
      code: 'APR-0002',
      companyCode: 'MEDU',
      companyName: 'Magna Edu',
      transaction: 'Overtime Request',
      plant: 'Plant B',
      organization: 'Operations',
      organizationLevel: 'Level 3',
      action: 'Review',
      employee: 'ops.admin',
      approvalMax: 1,
      effectiveStartDate: DateTime(2023, 8, 1),
      expired: false,
      status: 'Active',
      flows: const [
        MasterApprovalFlowData(
          approvalLevel: 'Level 1',
          employee: 'ops.supervisor',
          positionCode: 'POS-OPS-01',
          mandatory: true,
          value: '1',
        ),
      ],
    ),
    MasterApprovalData(
      id: 'apr-003',
      code: 'APR-0003',
      companyCode: 'MCORP',
      companyName: 'Magna Corp',
      transaction: 'Reimbursement',
      plant: 'Plant C',
      organization: 'Finance',
      organizationLevel: 'Level 1',
      action: 'Verify',
      employee: 'finance.admin',
      approvalMax: 1,
      effectiveStartDate: DateTime(2022, 5, 1),
      expired: true,
      effectiveEndDate: DateTime(2024, 12, 31),
      status: 'Inactive',
      flows: const [
        MasterApprovalFlowData(
          approvalLevel: 'Level 1',
          employee: 'finance.manager',
          positionCode: 'POS-FIN-01',
          mandatory: false,
          value: '1',
        ),
      ],
    ),
  ];

  bool get _hasActiveFilters {
    return _selectedTransactionFilter != 'All' ||
        _selectedActionFilter != 'All' ||
        _selectedStatusFilter != 'All' ||
        _selectedCompanyCodeFilter != 'All' ||
        _organizationFilterController.text.trim().isNotEmpty;
  }

  List<MasterApprovalData> get _filteredApprovals {
    final organizationQuery = _organizationFilterController.text
        .trim()
        .toLowerCase();

    return _approvals.where((item) {
      final matchesTransaction =
          _selectedTransactionFilter == 'All' ||
          item.transaction == _selectedTransactionFilter;
      final matchesAction =
          _selectedActionFilter == 'All' ||
          item.action == _selectedActionFilter;
      final matchesStatus =
          _selectedStatusFilter == 'All' ||
          item.status == _selectedStatusFilter;
      final matchesCompany =
          _selectedCompanyCodeFilter == 'All' ||
          item.companyCode == _selectedCompanyCodeFilter;
      final matchesOrganization =
          organizationQuery.isEmpty ||
          item.organization.toLowerCase().contains(organizationQuery);

      return matchesTransaction &&
          matchesAction &&
          matchesStatus &&
          matchesCompany &&
          matchesOrganization;
    }).toList();
  }

  @override
  void dispose() {
    _organizationFilterController.dispose();
    super.dispose();
  }

  Future<void> _openAddForm() async {
    final newData = await context.push<MasterApprovalData>(
      RoutePaths.masterApprovalAdd,
    );

    if (!mounted || newData == null) return;
    setState(() => _upsertApproval(newData));
  }

  Future<void> _openViewApproval() async {
    await context.push(RoutePaths.masterApprovalView);
  }

  Future<void> _openDetail(MasterApprovalData item) async {
    final updatedData = await context.push<MasterApprovalData>(
      RoutePaths.masterApprovalDetail,
      extra: item,
    );

    if (!mounted || updatedData == null) return;
    setState(() => _upsertApproval(updatedData));
  }

  void _upsertApproval(MasterApprovalData item) {
    final index = _approvals.indexWhere((existing) => existing.id == item.id);
    if (index >= 0) {
      _approvals[index] = item;
      return;
    }

    _approvals.insert(0, item);
  }

  void _resetFilters() {
    _selectedTransactionFilter = 'All';
    _selectedActionFilter = 'All';
    _selectedStatusFilter = 'All';
    _selectedCompanyCodeFilter = 'All';
    _organizationFilterController.clear();
    setState(() {});
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _filteredApprovals;

    return Scaffold(
      appBar: AppBar(title: const Text('Master Approval')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        children: [
          ElevatedButton.icon(
            onPressed: _openAddForm,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add Form'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _openViewApproval,
            icon: const Icon(Icons.visibility_rounded, size: 18),
            label: const Text('View Approval'),
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
                _FilterDropdown(
                  label: 'Transaction',
                  value: _selectedTransactionFilter,
                  options: [..._allOption, ..._transactionOptions],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedTransactionFilter = value);
                  },
                ),
                const SizedBox(height: 10),
                _FilterDropdown(
                  label: 'Action',
                  value: _selectedActionFilter,
                  options: [..._allOption, ..._actionOptions],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedActionFilter = value);
                  },
                ),
                const SizedBox(height: 10),
                _FilterDropdown(
                  label: 'Status',
                  value: _selectedStatusFilter,
                  options: [..._allOption, ..._statusOptions],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedStatusFilter = value);
                  },
                ),
                const SizedBox(height: 10),
                _FilterDropdown(
                  label: 'Company Code',
                  value: _selectedCompanyCodeFilter,
                  options: [..._allOption, ..._companyCodeOptions],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedCompanyCodeFilter = value);
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _organizationFilterController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Organization',
                    hintText: 'Search organization',
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
            const _EmptyApprovalState()
          else
            ...filteredItems.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ApprovalCard(
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

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: options
          .map((option) => DropdownMenuItem(value: option, child: Text(option)))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accentBlue),
        ),
      ),
    );
  }
}

class _ApprovalCard extends StatelessWidget {
  const _ApprovalCard({
    required this.data,
    required this.onTap,
    required this.dateLabel,
  });

  final MasterApprovalData data;
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
                Icons.approval_rounded,
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
                  Text(data.transaction, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 2),
                  Text(
                    '${data.companyCode} • ${data.action} • ${data.organization} • $dateLabel',
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

class _EmptyApprovalState extends StatelessWidget {
  const _EmptyApprovalState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'Data approval tidak ditemukan',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
