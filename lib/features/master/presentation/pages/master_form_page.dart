import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/master_form_data.dart';

class MasterFormPage extends StatefulWidget {
  const MasterFormPage({super.key});

  @override
  State<MasterFormPage> createState() => _MasterFormPageState();
}

class _MasterFormPageState extends State<MasterFormPage> {
  final TextEditingController _moduleNameFilterController =
      TextEditingController();
  final TextEditingController _formNameFilterController =
      TextEditingController();

  final List<MasterFormData> _forms = [
    MasterFormData(
      id: 'frm-001',
      moduleName: 'Attendance',
      formCode: 'FORM-ATD-01',
      formName: 'Check In Form',
      formDesc: 'Form untuk check in karyawan',
      formTitle: 'Check In',
      formLink: '/attendance/check-in',
      formIcon: 'login_rounded',
      formOrder: 1,
      roleName: 'Employee',
      effectiveStartDate: DateTime(2024, 1, 10),
      status: 'Active',
    ),
    MasterFormData(
      id: 'frm-002',
      moduleName: 'Leave',
      formCode: 'FORM-LVE-02',
      formName: 'Leave Request',
      formDesc: 'Form pengajuan cuti',
      formTitle: 'Leave Request',
      formLink: '/leave/request',
      formIcon: 'event_note_rounded',
      formOrder: 2,
      roleName: 'Employee',
      effectiveStartDate: DateTime(2023, 8, 1),
      status: 'Active',
    ),
    MasterFormData(
      id: 'frm-003',
      moduleName: 'Reimbursement',
      formCode: 'FORM-RMB-03',
      formName: 'Reimbursement Form',
      formDesc: 'Form klaim reimbursement',
      formTitle: 'Reimbursement',
      formLink: '/reimbursement/add',
      formIcon: 'payments_rounded',
      formOrder: 3,
      roleName: 'HR Admin',
      effectiveStartDate: DateTime(2022, 3, 10),
      effectiveEndDate: DateTime(2024, 12, 31),
      status: 'Inactive',
    ),
  ];

  bool get _hasActiveFilters {
    return _moduleNameFilterController.text.trim().isNotEmpty ||
        _formNameFilterController.text.trim().isNotEmpty;
  }

  List<MasterFormData> get _filteredForms {
    final moduleNameQuery = _moduleNameFilterController.text
        .trim()
        .toLowerCase();
    final formNameQuery = _formNameFilterController.text.trim().toLowerCase();

    return _forms.where((formData) {
      final matchesModuleName =
          moduleNameQuery.isEmpty ||
          formData.moduleName.toLowerCase().contains(moduleNameQuery);
      final matchesFormName =
          formNameQuery.isEmpty ||
          formData.formName.toLowerCase().contains(formNameQuery);

      return matchesModuleName && matchesFormName;
    }).toList();
  }

  @override
  void dispose() {
    _moduleNameFilterController.dispose();
    _formNameFilterController.dispose();
    super.dispose();
  }

  Future<void> _openAddForm() async {
    final newFormData = await context.push<MasterFormData>(
      RoutePaths.masterFormAdd,
    );

    if (!mounted || newFormData == null) return;
    setState(() => _upsertForm(newFormData));
  }

  Future<void> _openFormDetail(MasterFormData formData) async {
    final updatedData = await context.push<MasterFormData>(
      RoutePaths.masterFormDetail,
      extra: formData,
    );

    if (!mounted || updatedData == null) return;
    setState(() => _upsertForm(updatedData));
  }

  void _upsertForm(MasterFormData formData) {
    final index = _forms.indexWhere((item) => item.id == formData.id);
    if (index >= 0) {
      _forms[index] = formData;
      return;
    }

    _forms.insert(0, formData);
  }

  void _resetFilters() {
    _moduleNameFilterController.clear();
    _formNameFilterController.clear();
    setState(() {});
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final filteredForms = _filteredForms;

    return Scaffold(
      appBar: AppBar(title: const Text('Master Form')),
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
                  controller: _moduleNameFilterController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Module Name',
                    hintText: 'Search module name',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _formNameFilterController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Form Name',
                    hintText: 'Search form name',
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
          if (filteredForms.isEmpty)
            const _EmptyFormState()
          else
            ...filteredForms.map(
              (formData) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _FormCard(
                  formData: formData,
                  onTap: () => _openFormDetail(formData),
                  dateLabel: _formatDate(formData.effectiveStartDate),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.formData,
    required this.onTap,
    required this.dateLabel,
  });

  final MasterFormData formData;
  final VoidCallback onTap;
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    final statusColor = formData.isActive ? AppColors.success : AppColors.error;

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
                Icons.dynamic_form_rounded,
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
                          formData.formCode,
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
                          formData.status,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(formData.formName, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 2),
                  Text(
                    '${formData.moduleName} • ${formData.roleName} • $dateLabel',
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

class _EmptyFormState extends StatelessWidget {
  const _EmptyFormState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'Data form tidak ditemukan',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
