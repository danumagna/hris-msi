import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/master_employee_data.dart';

class MasterEmployeeFormPage extends StatefulWidget {
  const MasterEmployeeFormPage({super.key, this.initialData});

  final MasterEmployeeData? initialData;

  @override
  State<MasterEmployeeFormPage> createState() => _MasterEmployeeFormPageState();
}

class _MasterEmployeeFormPageState extends State<MasterEmployeeFormPage> {
  static const List<String> _genderOptions = ['Male', 'Female'];
  static const List<String> _statusOptions = ['Active', 'Inactive'];

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _employeeIdController;
  late final TextEditingController _employeeNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _createdByController;

  late String _selectedGender;
  late String _selectedStatus;
  DateTime? _createdDate;

  bool get _isEditMode => widget.initialData != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialData;

    _employeeIdController = TextEditingController(
      text: initial?.employeeId ?? '',
    );
    _employeeNameController = TextEditingController(
      text: initial?.employeeName ?? '',
    );
    _emailController = TextEditingController(text: initial?.email ?? '');
    _createdByController = TextEditingController(
      text: initial?.createdBy ?? '',
    );

    _selectedGender = initial?.gender ?? _genderOptions.first;
    _selectedStatus = initial?.status ?? _statusOptions.first;
    _createdDate = initial?.createdDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _employeeIdController.dispose();
    _employeeNameController.dispose();
    _emailController.dispose();
    _createdByController.dispose();
    super.dispose();
  }

  Future<void> _pickCreatedDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _createdDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null) return;
    setState(() => _createdDate = selectedDate);
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;
    if (_createdDate == null) return;

    final data = MasterEmployeeData(
      id:
          widget.initialData?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      employeeId: _employeeIdController.text.trim(),
      employeeName: _employeeNameController.text.trim(),
      gender: _selectedGender,
      email: _emailController.text.trim(),
      createdBy: _createdByController.text.trim(),
      createdDate: _createdDate!,
      status: _selectedStatus,
    );

    context.pop(data);
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Wajib diisi';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Wajib diisi';
    }

    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailPattern.hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Employee' : 'Add Employee'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _FormTextField(
              controller: _employeeIdController,
              label: 'Employee ID',
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            _FormTextField(
              controller: _employeeNameController,
              label: 'Employee Name',
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            _DropdownField(
              label: 'Gender',
              value: _selectedGender,
              options: _genderOptions,
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedGender = value);
              },
            ),
            const SizedBox(height: 12),
            _FormTextField(
              controller: _emailController,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
              validator: _emailValidator,
            ),
            const SizedBox(height: 12),
            _FormTextField(
              controller: _createdByController,
              label: 'Created By',
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            _DateField(
              label: 'Created Date',
              value: _createdDate,
              onTap: _pickCreatedDate,
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
              label: Text(_isEditMode ? 'Save Changes' : 'Save Employee'),
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
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;

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
          ],
        ),
      ),
    );
  }
}
