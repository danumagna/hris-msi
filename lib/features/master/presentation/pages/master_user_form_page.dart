import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/master_user_data.dart';

class MasterUserFormPage extends StatefulWidget {
  const MasterUserFormPage({super.key, this.initialData});

  final MasterUserData? initialData;

  @override
  State<MasterUserFormPage> createState() => _MasterUserFormPageState();
}

class _MasterUserFormPageState extends State<MasterUserFormPage> {
  static const List<String> _roleOptions = [
    'Super Admin',
    'HR Admin',
    'Manager',
    'Employee',
  ];

  static const List<String> _employeeIdOptions = [
    'EMP-1001',
    'EMP-1002',
    'EMP-1003',
    'EMP-1004',
  ];

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _userNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  late String _selectedRoleUser;
  late String _selectedEmployeeId;

  DateTime? _validAction;
  DateTime? _endUntil;

  bool get _isEditMode => widget.initialData != null;

  bool get _isActivePreview {
    if (_endUntil == null) return true;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final endDate = DateTime(_endUntil!.year, _endUntil!.month, _endUntil!.day);

    return !endDate.isBefore(today);
  }

  @override
  void initState() {
    super.initState();
    final initial = widget.initialData;

    _userNameController = TextEditingController(text: initial?.userName ?? '');
    _emailController = TextEditingController(text: initial?.email ?? '');
    _passwordController = TextEditingController(text: initial?.password ?? '');

    _selectedRoleUser = initial?.roleUser ?? _roleOptions.first;
    _selectedEmployeeId = initial?.employeeId ?? _employeeIdOptions.first;
    _validAction = initial?.validAction ?? DateTime.now();
    _endUntil = initial?.endUntil;
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickValidActionDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _validAction ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null) return;
    setState(() => _validAction = selectedDate);
  }

  Future<void> _pickEndUntilDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _endUntil ?? _validAction ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null) return;
    setState(() => _endUntil = selectedDate);
  }

  void _clearEndUntil() {
    setState(() => _endUntil = null);
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;
    if (_validAction == null) return;

    if (_endUntil != null && _endUntil!.isBefore(_validAction!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End Until tidak boleh sebelum Valid Action'),
        ),
      );
      return;
    }

    final userName = _userNameController.text.trim();
    final userCode =
        widget.initialData?.userCode ?? _generateUserCode(userName);

    final data = MasterUserData(
      id:
          widget.initialData?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      userCode: userCode,
      userName: userName,
      email: _emailController.text.trim(),
      roleUser: _selectedRoleUser,
      validAction: _validAction!,
      endUntil: _endUntil,
      employeeId: _selectedEmployeeId,
      password: _passwordController.text,
    );

    context.pop(data);
  }

  String _generateUserCode(String userName) {
    final cleaned = userName
        .replaceAll(RegExp(r'[^A-Za-z0-9]'), '')
        .toUpperCase();
    final head = cleaned.isEmpty
        ? 'USER'
        : cleaned.substring(0, cleaned.length.clamp(0, 5)).padRight(5, 'X');
    final suffix = (DateTime.now().millisecondsSinceEpoch % 10000)
        .toString()
        .padLeft(4, '0');
    return '$head-$suffix';
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
    final statusText = _isActivePreview ? 'Active' : 'Inactive';
    final statusColor = _isActivePreview ? AppColors.success : AppColors.error;

    return Scaffold(
      appBar: AppBar(title: Text(_isEditMode ? 'Edit User' : 'Add User')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                Text('Status:', style: AppTextStyles.bodyMedium),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    statusText,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _FormTextField(
              controller: _userNameController,
              label: 'User Name',
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            _FormTextField(
              controller: _emailController,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
              validator: _emailValidator,
            ),
            const SizedBox(height: 12),
            _DropdownField(
              label: 'Role User',
              value: _selectedRoleUser,
              options: _roleOptions,
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedRoleUser = value);
              },
            ),
            const SizedBox(height: 12),
            _DateField(
              label: 'Valid Action',
              value: _validAction,
              onTap: _pickValidActionDate,
            ),
            const SizedBox(height: 12),
            _DateField(
              label: 'End Until',
              value: _endUntil,
              onTap: _pickEndUntilDate,
              onClear: _endUntil == null ? null : _clearEndUntil,
            ),
            const SizedBox(height: 12),
            _DropdownField(
              label: 'Employee ID',
              value: _selectedEmployeeId,
              options: _employeeIdOptions,
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedEmployeeId = value);
              },
            ),
            const SizedBox(height: 12),
            _FormTextField(
              controller: _passwordController,
              label: 'Password',
              validator: _requiredValidator,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _submitForm,
              icon: const Icon(Icons.save_rounded),
              label: Text(_isEditMode ? 'Save Changes' : 'Save User'),
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
