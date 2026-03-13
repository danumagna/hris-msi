import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/absent_request.dart';
import '../providers/absent_provider.dart';

/// Form page for creating a new absent request.
class AbsentAddPage extends ConsumerStatefulWidget {
  const AbsentAddPage({super.key});

  @override
  ConsumerState<AbsentAddPage> createState() => _AbsentAddPageState();
}

class _AbsentAddPageState extends ConsumerState<AbsentAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  AbsentType? _selectedType;
  DateTime? _startDate;
  DateTime? _endDate;
  final List<XFile> _files = [];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Absent')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Absent Type'),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<AbsentType>(
                        initialValue: _selectedType,
                        decoration: const InputDecoration(
                          hintText: 'Select absent type',
                        ),
                        items: AbsentType.values
                            .map(
                              (type) => DropdownMenuItem<AbsentType>(
                                value: type,
                                child: Text(type.label),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() => _selectedType = value);
                        },
                        validator: (value) => value == null ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),

                      _buildLabel('Start Date'),
                      const SizedBox(height: 6),
                      _DatePickerField(
                        value: _startDate,
                        hint: 'Pick start date',
                        onPicked: (value) {
                          setState(() => _startDate = value);
                        },
                      ),
                      const SizedBox(height: 16),

                      _buildLabel('End Date'),
                      const SizedBox(height: 6),
                      _DatePickerField(
                        value: _endDate,
                        hint: 'Pick end date',
                        onPicked: (value) {
                          setState(() => _endDate = value);
                        },
                      ),
                      const SizedBox(height: 16),

                      _buildLabel('Description'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Enter description',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      _buildLabel('Absent File'),
                      const SizedBox(height: 6),
                      _buildFileSection(),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
    );
  }

  Widget _buildFileSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_files.isNotEmpty)
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _files.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (_, i) => Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(_files[i].path),
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: GestureDetector(
                      onTap: () => setState(() => _files.removeAt(i)),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 14,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (_files.isNotEmpty) const SizedBox(height: 10),
        Row(
          children: [
            _addFileButton(
              icon: Icons.photo_library_rounded,
              label: 'Gallery',
              source: ImageSource.gallery,
            ),
            const SizedBox(width: 10),
            _addFileButton(
              icon: Icons.camera_alt_rounded,
              label: 'Camera',
              source: ImageSource.camera,
            ),
          ],
        ),
      ],
    );
  }

  Widget _addFileButton({
    required IconData icon,
    required String label,
    required ImageSource source,
  }) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: () => _pickImage(source),
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();

    if (source == ImageSource.gallery) {
      final picked = await picker.pickMultiImage();
      if (picked.isNotEmpty) {
        setState(() => _files.addAll(picked));
      }
      return;
    }

    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() => _files.add(picked));
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick both start and end dates')),
      );
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date cannot be before start date')),
      );
      return;
    }

    final now = DateTime.now();
    final y = now.year;
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    final no = 'ABS-$y$m$d-${now.millisecondsSinceEpoch % 10000}';

    final item = AbsentRequest(
      id: now.millisecondsSinceEpoch.toString(),
      absentNo: no,
      type: _selectedType!,
      startDate: _startDate!,
      endDate: _endDate!,
      description: _descriptionController.text.trim(),
      entryTime: now,
      filePaths: _files.map((f) => f.path).toList(),
      status: 'Waiting for approval',
    );

    ref.read(absentProvider.notifier).add(item);

    if (context.mounted) {
      context.pop();
    }
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.value,
    required this.hint,
    required this.onPicked,
  });

  final DateTime? value;
  final String hint;
  final ValueChanged<DateTime> onPicked;

  @override
  Widget build(BuildContext context) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return InkWell(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? now,
          firstDate: DateTime(2020),
          lastDate: DateTime(now.year + 2),
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(
                context,
              ).colorScheme.copyWith(primary: AppColors.darkBlue),
            ),
            child: child!,
          ),
        );

        if (picked != null) {
          onPicked(picked);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          hintText: hint,
          suffixIcon: const Icon(Icons.calendar_today_rounded, size: 18),
        ),
        child: value != null
            ? Text(
                '${value!.day} ${months[value!.month - 1]} ${value!.year}',
                style: AppTextStyles.bodyMedium,
              )
            : Text(
                hint,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textHint,
                ),
              ),
      ),
    );
  }
}
