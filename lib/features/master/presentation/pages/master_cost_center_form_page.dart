import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/master_cost_center_data.dart';

class MasterCostCenterFormPage extends StatefulWidget {
  const MasterCostCenterFormPage({super.key, this.initialData});

  final MasterCostCenterData? initialData;

  @override
  State<MasterCostCenterFormPage> createState() =>
      _MasterCostCenterFormPageState();
}

class _MasterCostCenterFormPageState extends State<MasterCostCenterFormPage> {
  static const List<String> _companyOptions = [
    'Magna Solusi Indonesia',
    'Magna Edu',
    'Magna Corp',
  ];

  static const List<String> _statusOptions = ['Active', 'Inactive'];

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late String _selectedCompany;
  late String _selectedStatus;
  DateTime? _effectiveDate;
  DateTime? _expirationDate;
  bool _isExpired = false;

  bool get _isEditMode => widget.initialData != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialData;

    _nameController = TextEditingController(text: initial?.name ?? '');
    _descriptionController = TextEditingController(
      text: initial?.description ?? '',
    );

    _selectedCompany = initial?.company ?? _companyOptions.first;
    _selectedStatus = initial?.status ?? 'Active';
    _effectiveDate = initial?.effectiveDate ?? DateTime.now();
    _isExpired = initial?.isExpired ?? false;
    _expirationDate = initial?.expirationDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickEffectiveDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _effectiveDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null) return;
    setState(() => _effectiveDate = selectedDate);
  }

  Future<void> _pickExpirationDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _expirationDate ?? _effectiveDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null) return;
    setState(() => _expirationDate = selectedDate);
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;
    if (_effectiveDate == null) return;

    if (_isExpired && _expirationDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expiration Date wajib diisi')),
      );
      return;
    }

    if (_isExpired &&
        _expirationDate != null &&
        _expirationDate!.isBefore(_effectiveDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Expiration Date tidak boleh sebelum Effective Date'),
        ),
      );
      return;
    }

    final payload = MasterCostCenterData(
      id:
          widget.initialData?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      company: _selectedCompany,
      code: widget.initialData?.code ?? _generateCode(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      effectiveDate: _effectiveDate!,
      isExpired: _isExpired,
      expirationDate: _isExpired ? _expirationDate : null,
      status: _selectedStatus,
    );

    context.pop(payload);
  }

  String _generateCode() {
    final suffix = DateTime.now().microsecondsSinceEpoch.toString().substring(
      9,
      13,
    );
    return 'CC-$suffix';
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Wajib diisi';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Cost Center Form' : 'Add Form'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _DropdownField(
              label: 'Company',
              value: _selectedCompany,
              options: _companyOptions,
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedCompany = value);
              },
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
              validator: _requiredValidator,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            _DateField(
              label: 'Effective Date',
              value: _effectiveDate,
              onTap: _pickEffectiveDate,
            ),
            const SizedBox(height: 12),
            _ExpiredSwitch(
              value: _isExpired,
              onChanged: (value) {
                setState(() {
                  _isExpired = value;
                  if (!value) _expirationDate = null;
                });
              },
            ),
            const SizedBox(height: 12),
            _DateField(
              label: 'Expiration Date',
              value: _expirationDate,
              onTap: _isExpired ? _pickExpirationDate : null,
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

class _FormTextField extends StatelessWidget {
  const _FormTextField({
    required this.controller,
    required this.label,
    this.validator,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
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
