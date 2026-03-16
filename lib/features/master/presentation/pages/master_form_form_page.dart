import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/master_form_data.dart';

class MasterFormFormPage extends StatefulWidget {
  const MasterFormFormPage({super.key, this.initialData});

  final MasterFormData? initialData;

  @override
  State<MasterFormFormPage> createState() => _MasterFormFormPageState();
}

class _MasterFormFormPageState extends State<MasterFormFormPage> {
  static const List<String> _statusOptions = ['Active', 'Inactive'];

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _moduleNameController;
  late final TextEditingController _formCodeController;
  late final TextEditingController _formNameController;
  late final TextEditingController _formDescController;
  late final TextEditingController _formTitleController;
  late final TextEditingController _formLinkController;
  late final TextEditingController _formIconController;
  late final TextEditingController _formOrderController;
  late final TextEditingController _roleNameController;

  late String _selectedStatus;
  DateTime? _effectiveStartDate;
  DateTime? _effectiveEndDate;

  bool get _isEditMode => widget.initialData != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialData;

    _moduleNameController = TextEditingController(
      text: initial?.moduleName ?? '',
    );
    _formCodeController = TextEditingController(text: initial?.formCode ?? '');
    _formNameController = TextEditingController(text: initial?.formName ?? '');
    _formDescController = TextEditingController(text: initial?.formDesc ?? '');
    _formTitleController = TextEditingController(
      text: initial?.formTitle ?? '',
    );
    _formLinkController = TextEditingController(text: initial?.formLink ?? '');
    _formIconController = TextEditingController(text: initial?.formIcon ?? '');
    _formOrderController = TextEditingController(
      text: initial?.formOrder.toString() ?? '',
    );
    _roleNameController = TextEditingController(text: initial?.roleName ?? '');

    _selectedStatus = initial?.status ?? 'Active';
    _effectiveStartDate = initial?.effectiveStartDate ?? DateTime.now();
    _effectiveEndDate = initial?.effectiveEndDate;
  }

  @override
  void dispose() {
    _moduleNameController.dispose();
    _formCodeController.dispose();
    _formNameController.dispose();
    _formDescController.dispose();
    _formTitleController.dispose();
    _formLinkController.dispose();
    _formIconController.dispose();
    _formOrderController.dispose();
    _roleNameController.dispose();
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

  void _clearEffectiveEndDate() {
    setState(() => _effectiveEndDate = null);
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;
    if (_effectiveStartDate == null) return;

    if (_effectiveEndDate != null &&
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

    final formOrder = int.tryParse(_formOrderController.text.trim());
    if (formOrder == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form Order harus berupa angka')),
      );
      return;
    }

    final data = MasterFormData(
      id:
          widget.initialData?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      moduleName: _moduleNameController.text.trim(),
      formCode: _formCodeController.text.trim(),
      formName: _formNameController.text.trim(),
      formDesc: _formDescController.text.trim(),
      formTitle: _formTitleController.text.trim(),
      formLink: _formLinkController.text.trim(),
      formIcon: _formIconController.text.trim(),
      formOrder: formOrder,
      roleName: _roleNameController.text.trim(),
      effectiveStartDate: _effectiveStartDate!,
      effectiveEndDate: _effectiveEndDate,
      status: _isEditMode ? _selectedStatus : 'Active',
    );

    context.pop(data);
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Wajib diisi';
    return null;
  }

  String? _numberValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Wajib diisi';
    if (int.tryParse(value.trim()) == null) return 'Harus berupa angka';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditMode ? 'Edit Form' : 'Add Form')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _FormTextField(
              controller: _moduleNameController,
              label: 'Module Name',
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            _FormTextField(
              controller: _formCodeController,
              label: 'Form Code',
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            _FormTextField(
              controller: _formNameController,
              label: 'Form Name',
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            _FormTextField(
              controller: _formDescController,
              label: 'Form Desc',
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            _FormTextField(
              controller: _formTitleController,
              label: 'Form Title',
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            _FormTextField(
              controller: _formLinkController,
              label: 'Form Link',
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            _FormTextField(
              controller: _formIconController,
              label: 'Form Icon',
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            _FormTextField(
              controller: _formOrderController,
              label: 'Form Order',
              keyboardType: TextInputType.number,
              validator: _numberValidator,
            ),
            const SizedBox(height: 12),
            _FormTextField(
              controller: _roleNameController,
              label: 'Role Name',
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            _DateField(
              label: 'Effective Start Date',
              value: _effectiveStartDate,
              onTap: _pickEffectiveStartDate,
            ),
            const SizedBox(height: 12),
            _DateField(
              label: 'Effective End Date',
              value: _effectiveEndDate,
              onTap: _pickEffectiveEndDate,
              onClear: _effectiveEndDate == null
                  ? null
                  : _clearEffectiveEndDate,
            ),
            if (_isEditMode) ...[
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
            ],
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
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
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
          .map((option) => DropdownMenuItem(value: option, child: Text(option)))
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
    this.onClear,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final text = value == null
        ? '-'
        : '${value!.day.toString().padLeft(2, '0')}/'
              '${value!.month.toString().padLeft(2, '0')}/'
              '${value!.year}';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_month_rounded,
              color: AppColors.accentBlue,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.labelMedium),
                  const SizedBox(height: 2),
                  Text(text, style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
            if (onClear != null)
              IconButton(
                onPressed: onClear,
                icon: const Icon(
                  Icons.close_rounded,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
