import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/master_plant_data.dart';

class MasterPlantFormPage extends StatefulWidget {
  const MasterPlantFormPage({super.key, this.initialData});

  final MasterPlantData? initialData;

  @override
  State<MasterPlantFormPage> createState() => _MasterPlantFormPageState();
}

class _MasterPlantFormPageState extends State<MasterPlantFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _companyNameController;
  late final TextEditingController _plantCodeController;
  late final TextEditingController _plantNameController;
  late final TextEditingController _plantDescController;
  late final TextEditingController _cityController;
  late final TextEditingController _streetController;
  late final TextEditingController _postalCodeController;

  DateTime? _effectiveStartDate;
  DateTime? _effectiveEndDate;

  bool get _isEditMode => widget.initialData != null;

  bool get _isActivePreview {
    if (_effectiveEndDate == null) return true;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final endDate = DateTime(
      _effectiveEndDate!.year,
      _effectiveEndDate!.month,
      _effectiveEndDate!.day,
    );

    return !endDate.isBefore(today);
  }

  @override
  void initState() {
    super.initState();
    final initial = widget.initialData;

    _companyNameController = TextEditingController(
      text: initial?.companyName ?? '',
    );
    _plantCodeController = TextEditingController(
      text: initial?.plantCode ?? '',
    );
    _plantNameController = TextEditingController(
      text: initial?.plantName ?? '',
    );
    _plantDescController = TextEditingController(
      text: initial?.plantDesc ?? '',
    );
    _cityController = TextEditingController(text: initial?.city ?? '');
    _streetController = TextEditingController(text: initial?.street ?? '');
    _postalCodeController = TextEditingController(
      text: initial?.postalCode ?? '',
    );

    _effectiveStartDate = initial?.effectiveStartDate ?? DateTime.now();
    _effectiveEndDate = initial?.effectiveEndDate;
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _plantCodeController.dispose();
    _plantNameController.dispose();
    _plantDescController.dispose();
    _cityController.dispose();
    _streetController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _effectiveStartDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null) return;
    setState(() => _effectiveStartDate = selectedDate);
  }

  Future<void> _pickEndDate() async {
    final initialDate = _effectiveEndDate ?? _effectiveStartDate;
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null) return;
    setState(() => _effectiveEndDate = selectedDate);
  }

  void _clearEndDate() {
    setState(() => _effectiveEndDate = null);
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;
    if (_effectiveStartDate == null) return;

    if (_effectiveEndDate != null &&
        _effectiveEndDate!.isBefore(_effectiveStartDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Effective End Date tidak boleh sebelum Start Date'),
        ),
      );
      return;
    }

    final data = MasterPlantData(
      id:
          widget.initialData?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      companyName: _companyNameController.text.trim(),
      plantCode: _plantCodeController.text.trim(),
      plantName: _plantNameController.text.trim(),
      plantDesc: _plantDescController.text.trim(),
      city: _cityController.text.trim(),
      street: _streetController.text.trim(),
      postalCode: _postalCodeController.text.trim(),
      effectiveStartDate: _effectiveStartDate!,
      effectiveEndDate: _effectiveEndDate,
    );

    context.pop(data);
  }

  @override
  Widget build(BuildContext context) {
    final statusText = _isActivePreview ? 'Active' : 'Inactive';
    final statusColor = _isActivePreview ? AppColors.success : AppColors.error;

    return Scaffold(
      appBar: AppBar(title: Text(_isEditMode ? 'Edit Plant' : 'Add Plant')),
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
              controller: _companyNameController,
              label: 'Company Name',
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            _FormTextField(
              controller: _plantCodeController,
              label: 'Plant Code',
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            _FormTextField(
              controller: _plantNameController,
              label: 'Plant Name',
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            _FormTextField(
              controller: _plantDescController,
              label: 'Plant Desc',
              maxLines: 3,
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            _FormTextField(
              controller: _cityController,
              label: 'City',
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            _FormTextField(
              controller: _streetController,
              label: 'Street',
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            _FormTextField(
              controller: _postalCodeController,
              label: 'Postal Code',
              keyboardType: TextInputType.number,
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            _DateField(
              label: 'Effective Start Date',
              value: _effectiveStartDate,
              onTap: _pickStartDate,
            ),
            const SizedBox(height: 12),
            _DateField(
              label: 'Effective End Date',
              value: _effectiveEndDate,
              onTap: _pickEndDate,
              onClear: _effectiveEndDate == null ? null : _clearEndDate,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _submitForm,
              icon: const Icon(Icons.save_rounded),
              label: Text(_isEditMode ? 'Save Changes' : 'Save Plant'),
            ),
          ],
        ),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Wajib diisi';
    }
    return null;
  }
}

class _FormTextField extends StatelessWidget {
  const _FormTextField({
    required this.controller,
    required this.label,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
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
