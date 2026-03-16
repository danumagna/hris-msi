import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/master_action_data.dart';

class MasterActionFormPage extends StatefulWidget {
  const MasterActionFormPage({super.key, this.initialData});

  final MasterActionData? initialData;

  @override
  State<MasterActionFormPage> createState() => _MasterActionFormPageState();
}

class _MasterActionFormPageState extends State<MasterActionFormPage> {
  static const List<String> _roleOptions = [
    'Super Admin',
    'HR Admin',
    'Manager',
    'Employee',
  ];

  static const Map<String, _ActionUserProfile> _roleProfiles = {
    'Super Admin': _ActionUserProfile(
      actionUser: 'Super Administrator',
      email: 'super.admin@msi.com',
    ),
    'HR Admin': _ActionUserProfile(
      actionUser: 'HR Administrator',
      email: 'hr.admin@msi.com',
    ),
    'Manager': _ActionUserProfile(
      actionUser: 'Department Manager',
      email: 'manager@msi.com',
    ),
    'Employee': _ActionUserProfile(
      actionUser: 'Employee User',
      email: 'employee@msi.com',
    ),
  };

  static const List<String> _statusOptions = ['Active', 'Inactive'];

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _actionNameController;
  late final TextEditingController _modifiedByController;

  late String _selectedRole;
  late String _selectedStatus;

  DateTime? _validAction;
  DateTime? _endUntil;
  DateTime? _modifiedDate;

  bool get _isEditMode => widget.initialData != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialData;

    _actionNameController = TextEditingController(
      text: initial?.actionName ?? '',
    );
    _modifiedByController = TextEditingController(
      text: initial?.modifiedBy ?? '',
    );

    _selectedRole = initial?.actionRole ?? _roleOptions.first;
    _selectedStatus = initial?.status ?? 'Active';
    _validAction = initial?.validAction ?? DateTime.now();
    _endUntil = initial?.endUntil;
    _modifiedDate = initial?.modifiedDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _actionNameController.dispose();
    _modifiedByController.dispose();
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

  Future<void> _pickModifiedDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _modifiedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null) return;
    setState(() => _modifiedDate = selectedDate);
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

    final actionName = _actionNameController.text.trim();
    final actionCode =
        widget.initialData?.actionCode ?? _generateActionCode(actionName);

    final profile =
        _roleProfiles[_selectedRole] ??
        const _ActionUserProfile(
          actionUser: 'System User',
          email: 'system.user@msi.com',
        );

    final status = _isEditMode ? _selectedStatus : _deriveStatusFromEndUntil();

    final data = MasterActionData(
      id:
          widget.initialData?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      actionCode: actionCode,
      actionName: actionName,
      actionRole: _selectedRole,
      validAction: _validAction!,
      endUntil: _endUntil,
      actionUser: profile.actionUser,
      email: profile.email,
      status: status,
      modifiedBy: _isEditMode ? _modifiedByController.text.trim() : null,
      modifiedDate: _isEditMode ? _modifiedDate : null,
    );

    context.pop(data);
  }

  String _deriveStatusFromEndUntil() {
    if (_endUntil == null) return 'Active';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final endDate = DateTime(_endUntil!.year, _endUntil!.month, _endUntil!.day);

    return endDate.isBefore(today) ? 'Inactive' : 'Active';
  }

  String _generateActionCode(String actionName) {
    final cleaned = actionName
        .replaceAll(RegExp(r'[^A-Za-z0-9]'), '')
        .toUpperCase();
    final head = cleaned.isEmpty
        ? 'ACTION'
        : cleaned.substring(0, cleaned.length.clamp(0, 6)).padRight(6, 'X');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditMode ? 'Edit Action' : 'Add Action')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _FormTextField(
              controller: _actionNameController,
              label: 'Action Name',
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            _DropdownField(
              label: 'Action Role',
              value: _selectedRole,
              options: _roleOptions,
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedRole = value);
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
              const SizedBox(height: 12),
              _FormTextField(
                controller: _modifiedByController,
                label: 'Modified By',
                validator: _requiredValidator,
              ),
              const SizedBox(height: 12),
              _DateField(
                label: 'Modified Date',
                value: _modifiedDate,
                onTap: _pickModifiedDate,
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _submitForm,
              icon: const Icon(Icons.save_rounded),
              label: Text(_isEditMode ? 'Save Changes' : 'Save Action'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionUserProfile {
  const _ActionUserProfile({required this.actionUser, required this.email});

  final String actionUser;
  final String email;
}

class _FormTextField extends StatelessWidget {
  const _FormTextField({
    required this.controller,
    required this.label,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
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
