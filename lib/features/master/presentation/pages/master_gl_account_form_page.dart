import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/master_gl_account_data.dart';

class MasterGlAccountFormPage extends StatefulWidget {
  const MasterGlAccountFormPage({super.key, this.initialData});

  final MasterGlAccountData? initialData;

  @override
  State<MasterGlAccountFormPage> createState() =>
      _MasterGlAccountFormPageState();
}

class _MasterGlAccountFormPageState extends State<MasterGlAccountFormPage> {
  static const List<_CompanyOption> _companyOptions = [
    _CompanyOption(code: 'MSI', name: 'Magna Solusi Indonesia'),
    _CompanyOption(code: 'MEDU', name: 'Magna Edu'),
    _CompanyOption(code: 'MCORP', name: 'Magna Corp'),
  ];

  static const List<String> _statusOptions = ['Active', 'Inactive'];

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _companyController;
  late final TextEditingController _chartOfAccountController;
  late final TextEditingController _glAccountNumberController;
  late final TextEditingController _glAccountTextController;
  late final TextEditingController _glAccountGroupController;
  late final TextEditingController _integrationController;
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  late String _selectedCompanyCode;
  late String _selectedStatus;
  DateTime? _effectiveStartDate;
  DateTime? _effectiveEndDate;
  bool _isExpired = false;

  bool get _isEditMode => widget.initialData != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialData;

    _selectedCompanyCode = initial?.companyCode ?? _companyOptions.first.code;
    _companyController = TextEditingController(
      text: initial?.company ?? _companyOptions.first.name,
    );
    _chartOfAccountController = TextEditingController(
      text: initial?.chartOfAccount ?? '',
    );
    _glAccountNumberController = TextEditingController(
      text: initial?.glAccountNumber ?? '',
    );
    _glAccountTextController = TextEditingController(
      text: initial?.glAccountText ?? '',
    );
    _glAccountGroupController = TextEditingController(
      text: initial?.glAccountGroup ?? '',
    );
    _integrationController = TextEditingController(
      text: initial?.integration ?? '',
    );
    _nameController = TextEditingController(text: initial?.name ?? '');
    _descriptionController = TextEditingController(
      text: initial?.description ?? '',
    );

    _selectedStatus = initial?.status ?? 'Active';
    _effectiveStartDate = initial?.effectiveStartDate ?? DateTime.now();
    _isExpired = initial?.isExpired ?? false;
    _effectiveEndDate = initial?.effectiveEndDate;
  }

  @override
  void dispose() {
    _companyController.dispose();
    _chartOfAccountController.dispose();
    _glAccountNumberController.dispose();
    _glAccountTextController.dispose();
    _glAccountGroupController.dispose();
    _integrationController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickEffectiveStartDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _effectiveStartDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null) return;
    setState(() => _effectiveStartDate = selectedDate);
  }

  Future<void> _pickEffectiveEndDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _effectiveEndDate ?? _effectiveStartDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null) return;
    setState(() => _effectiveEndDate = selectedDate);
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;
    if (_effectiveStartDate == null) return;

    if (_isExpired && _effectiveEndDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Effective End Date wajib diisi')),
      );
      return;
    }

    if (_isExpired &&
        _effectiveEndDate != null &&
        _effectiveEndDate!.isBefore(_effectiveStartDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Effective End Date tidak boleh sebelum Effective Start Date',
          ),
        ),
      );
      return;
    }

    final payload = MasterGlAccountData(
      id:
          widget.initialData?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      companyCode: _selectedCompanyCode,
      company: _companyController.text.trim(),
      chartOfAccount: _chartOfAccountController.text.trim(),
      glAccountNumber: _glAccountNumberController.text.trim(),
      glAccountText: _glAccountTextController.text.trim(),
      glAccountGroup: _glAccountGroupController.text.trim(),
      integration: _integrationController.text.trim(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      effectiveStartDate: _effectiveStartDate!,
      isExpired: _isExpired,
      effectiveEndDate: _isExpired ? _effectiveEndDate : null,
      status: _selectedStatus,
    );

    context.pop(payload);
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Wajib diisi';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit GL Account Form' : 'Add Form'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedCompanyCode,
              items: _companyOptions
                  .map(
                    (company) => DropdownMenuItem(
                      value: company.code,
                      child: Text('${company.code} - ${company.name}'),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                final selected = _companyOptions.firstWhere(
                  (item) => item.code == value,
                  orElse: () => _companyOptions.first,
                );

                setState(() {
                  _selectedCompanyCode = value;
                  _companyController.text = selected.name;
                });
              },
              decoration: const InputDecoration(labelText: 'Company'),
            ),
            const SizedBox(height: 12),
            _FormTextField(
              controller: _companyController,
              label: 'Company',
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            _FormTextField(
              controller: _chartOfAccountController,
              label: 'Chart of Account',
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            _FormTextField(
              controller: _glAccountNumberController,
              label: 'GL Account Number',
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            _FormTextField(
              controller: _glAccountTextController,
              label: 'GL Account Text',
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            _FormTextField(
              controller: _glAccountGroupController,
              label: 'GL Account Group',
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            _FormTextField(
              controller: _integrationController,
              label: 'Integration',
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            _FormTextField(
              controller: _nameController,
              label: 'Name',
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            _FormTextField(
              controller: _descriptionController,
              label: 'Description',
              maxLines: 3,
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            _DateField(
              label: 'Effective Start Date',
              value: _effectiveStartDate,
              onTap: _pickEffectiveStartDate,
            ),
            const SizedBox(height: 12),
            _ExpiredSwitch(
              value: _isExpired,
              onChanged: (value) {
                setState(() {
                  _isExpired = value;
                  if (!value) _effectiveEndDate = null;
                });
              },
            ),
            const SizedBox(height: 12),
            _DateField(
              label: 'Effective End Date',
              value: _effectiveEndDate,
              onTap: _isExpired ? _pickEffectiveEndDate : null,
            ),
            const SizedBox(height: 12),
            _DropdownField(
              label: 'Status',
              value: _selectedStatus,
              options: _statusOptions,
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedStatus = value);
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _submitForm,
              icon: const Icon(Icons.save_rounded),
              label: Text(_isEditMode ? 'Save Changes' : 'Save Form'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompanyOption {
  const _CompanyOption({required this.code, required this.name});

  final String code;
  final String name;
}

class _FormTextField extends StatelessWidget {
  const _FormTextField({
    required this.controller,
    required this.label,
    this.maxLines = 1,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final int maxLines;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.white,
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

class _DropdownField extends StatelessWidget {
  const _DropdownField({
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
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.white,
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

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime? value;
  final VoidCallback? onTap;

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: onTap == null
              ? AppColors.divider.withValues(alpha: 0.15)
              : AppColors.white,
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
        child: Row(
          children: [
            Expanded(
              child: Text(
                value == null ? '-' : _formatDate(value!),
                style: AppTextStyles.bodyMedium,
              ),
            ),
            Icon(
              Icons.calendar_today_rounded,
              size: 18,
              color: onTap == null ? AppColors.textHint : AppColors.accentBlue,
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpiredSwitch extends StatelessWidget {
  const _ExpiredSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Expanded(child: Text('Is Expired', style: AppTextStyles.bodyMedium)),
          Text(
            value ? 'Yes' : 'No',
            style: AppTextStyles.bodySmall.copyWith(
              color: value ? AppColors.error : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
