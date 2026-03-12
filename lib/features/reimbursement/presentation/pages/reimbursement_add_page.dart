import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/reimbursement.dart';
import '../providers/reimbursement_provider.dart';

/// Form page for creating a new reimbursement claim.
class ReimbursementAddPage extends ConsumerStatefulWidget {
  const ReimbursementAddPage({super.key});

  @override
  ConsumerState<ReimbursementAddPage> createState() =>
      _ReimbursementAddPageState();
}

class _ReimbursementAddPageState extends ConsumerState<ReimbursementAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  ReimburseType? _selectedType;
  String? _selectedSubType;
  DateTime? _startDate;
  DateTime? _endDate;
  final List<XFile> _files = [];

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subTypes = _selectedType != null
        ? reimburseSubTypes[_selectedType!] ?? []
        : <String>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Add Reimbursement')),
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
                      // ── Type ───────────────────────
                      _buildLabel('Type Reimburse'),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<ReimburseType>(
                        initialValue: _selectedType,
                        decoration: const InputDecoration(
                          hintText: 'Select type',
                        ),
                        items: ReimburseType.values
                            .map(
                              (t) => DropdownMenuItem<ReimburseType>(
                                value: t,
                                child: Text(t.label),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() {
                          _selectedType = v;
                          _selectedSubType = null;
                        }),
                        validator: (v) => v == null ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),

                      // ── Sub Type ──────────────────
                      _buildLabel('Sub Type'),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedSubType,
                        decoration: const InputDecoration(
                          hintText: 'Select sub type',
                        ),
                        items: subTypes
                            .map(
                              (s) => DropdownMenuItem<String>(
                                value: s,
                                child: Text(s),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _selectedSubType = v),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),

                      // ── Title ─────────────────────
                      _buildLabel('Title'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          hintText: 'Enter title',
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),

                      // ── Transaction Date ──────────
                      _buildLabel('Transaction Date'),
                      const SizedBox(height: 6),
                      _DatePickerField(
                        value: _startDate,
                        hint: 'Pick start date',
                        onPicked: (d) => setState(() => _startDate = d),
                      ),
                      const SizedBox(height: 16),

                      // ── End Date ──────────────────
                      _buildLabel('End Date'),
                      const SizedBox(height: 6),
                      _DatePickerField(
                        value: _endDate,
                        hint: 'Pick end date',
                        onPicked: (d) => setState(() => _endDate = d),
                      ),
                      const SizedBox(height: 16),

                      // ── Amount ────────────────────
                      _buildLabel('Amount'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          _RupiahInputFormatter(),
                        ],
                        decoration: const InputDecoration(prefixText: 'Rp '),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Required';
                          }
                          final raw = v.replaceAll('.', '');
                          if (int.tryParse(raw) == null) {
                            return 'Invalid amount';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // ── Description ───────────────
                      _buildLabel('Description'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Enter description',
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),

                      // ── File Upload ───────────────
                      _buildLabel('Reimburse File'),
                      const SizedBox(height: 6),
                      _buildFileSection(),
                    ],
                  ),
                ),
              ),
            ),

            // ── Action Buttons ──────────────────
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

  // ── Label helper ────────────────────────────

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
    );
  }

  // ── File upload section ─────────────────────

  Widget _buildFileSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thumbnails
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

        // Add buttons
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
    } else {
      final picked = await picker.pickImage(source: source);
      if (picked != null) {
        setState(() => _files.add(picked));
      }
    }
  }

  // ── Submit ──────────────────────────────────

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please pick both dates')));
      return;
    }

    final rawAmount = _amountController.text.replaceAll('.', '');
    final amount = double.tryParse(rawAmount) ?? 0;

    final item = Reimbursement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      type: _selectedType!,
      subType: _selectedSubType!,
      transactionStartDate: _startDate!,
      transactionEndDate: _endDate!,
      description: _descriptionController.text.trim(),
      entryTime: DateTime.now(),
      amount: amount,
      filePaths: _files.map((f) => f.path).toList(),
      status: 'Waiting for approval',
    );

    ref.read(reimbursementProvider.notifier).add(item);

    if (context.mounted) {
      context.pop();
    }
  }
}

// ── Date Picker Field ───────────────────────────

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
        if (picked != null) onPicked(picked);
      },
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          hintText: hint,
          suffixIcon: const Icon(Icons.calendar_today_rounded, size: 18),
        ),
        child: value != null
            ? Text(
                '${value!.day} ${months[value!.month - 1]} '
                '${value!.year}',
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

// ── Rupiah Input Formatter ──────────────────────

class _RupiahInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll('.', '');
    if (digits.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
