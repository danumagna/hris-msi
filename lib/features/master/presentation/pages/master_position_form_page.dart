import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/master_position_data.dart';

class MasterPositionFormPage extends StatefulWidget {
  const MasterPositionFormPage({super.key, this.initialData});

  final MasterPositionData? initialData;

  @override
  State<MasterPositionFormPage> createState() => _MasterPositionFormPageState();
}

class _MasterPositionFormPageState extends State<MasterPositionFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _positionCodeController;
  late final TextEditingController _positionNameController;
  late final TextEditingController _positionDescController;
  late final TextEditingController _positionLevelController;
  late final TextEditingController _jobSpecController;
  late final TextEditingController _manSpecController;
  late final TextEditingController _majorController;

  late List<String> _majors;

  DateTime? _validStartDate;
  DateTime? _validEndDate;

  bool get _isEditMode => widget.initialData != null;

  bool get _isActivePreview {
    if (_validEndDate == null) return true;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final endDate = DateTime(
      _validEndDate!.year,
      _validEndDate!.month,
      _validEndDate!.day,
    );

    return !endDate.isBefore(today);
  }

  @override
  void initState() {
    super.initState();
    final initial = widget.initialData;

    _positionCodeController = TextEditingController(
      text: initial?.positionCode ?? '',
    );
    _positionNameController = TextEditingController(
      text: initial?.positionName ?? '',
    );
    _positionDescController = TextEditingController(
      text: initial?.positionDesc ?? '',
    );
    _positionLevelController = TextEditingController(
      text: initial?.positionLevel ?? '',
    );
    _jobSpecController = TextEditingController(text: initial?.jobSpec ?? '');
    _manSpecController = TextEditingController(text: initial?.manSpec ?? '');
    _majorController = TextEditingController();
    _majors = [...?initial?.majors];

    _validStartDate = initial?.validStartDate ?? DateTime.now();
    _validEndDate = initial?.validEndDate;
  }

  @override
  void dispose() {
    _positionCodeController.dispose();
    _positionNameController.dispose();
    _positionDescController.dispose();
    _positionLevelController.dispose();
    _jobSpecController.dispose();
    _manSpecController.dispose();
    _majorController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _validStartDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null) return;
    setState(() => _validStartDate = selectedDate);
  }

  Future<void> _pickEndDate() async {
    final initialDate = _validEndDate ?? _validStartDate;
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null) return;
    setState(() => _validEndDate = selectedDate);
  }

  void _clearEndDate() {
    setState(() => _validEndDate = null);
  }

  void _addMajor() {
    final raw = _majorController.text.trim();
    if (raw.isEmpty) return;

    final parsedMajors = raw
        .split(',')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();

    if (parsedMajors.isEmpty) return;

    setState(() {
      for (final major in parsedMajors) {
        if (_majors.contains(major)) continue;
        _majors.add(major);
      }
      _majorController.clear();
    });
  }

  void _removeMajor(String major) {
    setState(() => _majors.remove(major));
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;
    if (_validStartDate == null) return;

    if (_majors.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Major minimal 1 data')));
      return;
    }

    if (_validEndDate != null && _validEndDate!.isBefore(_validStartDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End Date tidak boleh sebelum Start Date'),
        ),
      );
      return;
    }

    final data = MasterPositionData(
      id:
          widget.initialData?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      positionCode: _positionCodeController.text.trim(),
      positionName: _positionNameController.text.trim(),
      positionDesc: _positionDescController.text.trim(),
      positionLevel: _positionLevelController.text.trim(),
      jobSpec: _jobSpecController.text.trim(),
      manSpec: _manSpecController.text.trim(),
      validStartDate: _validStartDate!,
      validEndDate: _validEndDate,
      majors: [..._majors],
    );

    context.pop(data);
  }

  @override
  Widget build(BuildContext context) {
    final statusText = _isActivePreview ? 'Active' : 'Inactive';
    final statusColor = _isActivePreview ? AppColors.success : AppColors.error;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Position' : 'Add Position'),
      ),
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
              controller: _positionCodeController,
              label: 'Position Code',
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            _FormTextField(
              controller: _positionNameController,
              label: 'Position Name',
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            _FormTextField(
              controller: _positionDescController,
              label: 'Position Desc',
              maxLines: 3,
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            _FormTextField(
              controller: _positionLevelController,
              label: 'Position Level',
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            _FormTextField(
              controller: _jobSpecController,
              label: 'Job Spec',
              maxLines: 3,
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            _FormTextField(
              controller: _manSpecController,
              label: 'Man Spec',
              maxLines: 3,
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            _DateField(
              label: 'Valid Start Date',
              value: _validStartDate,
              onTap: _pickStartDate,
            ),
            const SizedBox(height: 12),
            _DateField(
              label: 'Valid End Date',
              value: _validEndDate,
              onTap: _pickEndDate,
              onClear: _validEndDate == null ? null : _clearEndDate,
            ),
            const SizedBox(height: 12),
            Text('Major', style: AppTextStyles.labelMedium),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _majorController,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _addMajor(),
                          decoration: const InputDecoration(
                            hintText: 'Input major (bisa lebih dari 1)',
                            isDense: true,
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _addMajor,
                        icon: const Icon(
                          Icons.add_circle_rounded,
                          color: AppColors.accentBlue,
                        ),
                        tooltip: 'Add Major',
                      ),
                    ],
                  ),
                  if (_majors.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _majors
                          .map(
                            (major) => InputChip(
                              label: Text(major),
                              onDeleted: () => _removeMajor(major),
                            ),
                          )
                          .toList(),
                    ),
                  ] else
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Belum ada major',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _submitForm,
              icon: const Icon(Icons.save_rounded),
              label: Text(_isEditMode ? 'Save Changes' : 'Save Position'),
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
