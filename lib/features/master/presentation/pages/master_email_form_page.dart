import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/master_email_data.dart';

class MasterEmailFormPage extends StatefulWidget {
  const MasterEmailFormPage({super.key, this.initialData});

  final MasterEmailData? initialData;

  @override
  State<MasterEmailFormPage> createState() => _MasterEmailFormPageState();
}

class _MasterEmailFormPageState extends State<MasterEmailFormPage> {
  static const List<String> _statusOptions = ['Active', 'Inactive'];
  static const List<String> _fontOptions = [
    'Arial',
    'Georgia',
    'Times New Roman',
    'Verdana',
  ];
  static const List<int> _fontSizeOptions = [12, 14, 16, 18, 20, 24];

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _codeController;
  late final TextEditingController _titleController;
  late final TextEditingController _subjectController;
  late final TextEditingController _contentController;

  late String _selectedStatus;
  late String _selectedFont;
  late int _selectedFontSize;
  DateTime? _effectiveStartDate;
  DateTime? _effectiveEndDate;
  bool _isExpired = false;

  bool get _isEditMode => widget.initialData != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialData;

    _codeController = TextEditingController(
      text: initial?.code ?? _generateCode(),
    );
    _titleController = TextEditingController(text: initial?.emailTitle ?? '');
    _subjectController = TextEditingController(
      text: initial?.emailSubject ?? '',
    );
    _contentController = TextEditingController(
      text: initial?.emailContent ?? '',
    );

    _selectedStatus = initial?.status ?? 'Active';
    _selectedFont = _fontOptions.first;
    _selectedFontSize = 14;
    _effectiveStartDate = initial?.effectiveStartDate ?? DateTime.now();
    _isExpired = initial?.isExpired ?? false;
    _effectiveEndDate = initial?.effectiveEndDate;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _titleController.dispose();
    _subjectController.dispose();
    _contentController.dispose();
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

    final payload = MasterEmailData(
      id:
          widget.initialData?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      code: _codeController.text.trim(),
      emailTitle: _titleController.text.trim(),
      emailSubject: _subjectController.text.trim(),
      emailContent: _contentController.text.trim(),
      effectiveStartDate: _effectiveStartDate!,
      isExpired: _isExpired,
      effectiveEndDate: _isExpired ? _effectiveEndDate : null,
      status: _selectedStatus,
    );

    context.pop(payload);
  }

  void _wrapSelectedText(String openTag, String closeTag) {
    final value = _contentController.value;
    final text = value.text;
    final selection = value.selection;

    if (!selection.isValid) {
      final inserted = '$openTag$closeTag';
      _contentController.value = TextEditingValue(
        text: '$text$inserted',
        selection: TextSelection.collapsed(
          offset: text.length + openTag.length,
        ),
      );
      return;
    }

    final start = selection.start;
    final end = selection.end;
    final normalizedStart = start < end ? start : end;
    final normalizedEnd = start < end ? end : start;

    if (normalizedStart == normalizedEnd) {
      final replaced = text.replaceRange(
        normalizedStart,
        normalizedEnd,
        '$openTag$closeTag',
      );

      _contentController.value = TextEditingValue(
        text: replaced,
        selection: TextSelection.collapsed(
          offset: normalizedStart + openTag.length,
        ),
      );
      return;
    }

    final selectedText = text.substring(normalizedStart, normalizedEnd);
    final replacement = '$openTag$selectedText$closeTag';
    final replaced = text.replaceRange(
      normalizedStart,
      normalizedEnd,
      replacement,
    );

    _contentController.value = TextEditingValue(
      text: replaced,
      selection: TextSelection.collapsed(
        offset: normalizedStart + replacement.length,
      ),
    );
  }

  void _insertBulletList() {
    final value = _contentController.value;
    final text = value.text;
    final selection = value.selection;

    if (!selection.isValid || selection.start == selection.end) {
      final cursor = selection.isValid && selection.start >= 0
          ? selection.start
          : text.length;
      final replaced = text.replaceRange(cursor, cursor, '- ');
      _contentController.value = TextEditingValue(
        text: replaced,
        selection: TextSelection.collapsed(offset: cursor + 2),
      );
      return;
    }

    final start = selection.start < selection.end
        ? selection.start
        : selection.end;
    final end = selection.start < selection.end
        ? selection.end
        : selection.start;
    final selectedText = text.substring(start, end);
    final lines = selectedText.split('\n');
    final bulleted = lines
        .map((line) => line.trim().isEmpty ? line : '- $line')
        .join('\n');

    final replaced = text.replaceRange(start, end, bulleted);
    _contentController.value = TextEditingValue(
      text: replaced,
      selection: TextSelection.collapsed(offset: start + bulleted.length),
    );
  }

  String _generateCode() {
    final suffix = DateTime.now().microsecondsSinceEpoch.toString().substring(
      9,
      13,
    );
    return 'EML-$suffix';
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Wajib diisi';
    return null;
  }

  String _cleanContentPreview(String text) {
    return text
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditMode ? 'Edit Email Form' : 'Add Form')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _FormTextField(
              controller: _codeController,
              label: 'Code',
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            _FormTextField(
              controller: _titleController,
              label: 'Email Title',
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            _FormTextField(
              controller: _subjectController,
              label: 'Email Subject',
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            Text('Email Content', style: AppTextStyles.labelMedium),
            const SizedBox(height: 8),
            _EditorToolbar(
              selectedFont: _selectedFont,
              selectedFontSize: _selectedFontSize,
              fontOptions: _fontOptions,
              fontSizeOptions: _fontSizeOptions,
              onBold: () => _wrapSelectedText('<b>', '</b>'),
              onItalic: () => _wrapSelectedText('<i>', '</i>'),
              onUnderline: () => _wrapSelectedText('<u>', '</u>'),
              onBulletList: _insertBulletList,
              onFontChanged: (fontName) {
                setState(() => _selectedFont = fontName);
                _wrapSelectedText(
                  '<span style="font-family:$fontName;">',
                  '</span>',
                );
              },
              onFontSizeChanged: (fontSize) {
                setState(() => _selectedFontSize = fontSize);
                _wrapSelectedText(
                  '<span style="font-size:${fontSize}px;">',
                  '</span>',
                );
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _contentController,
              maxLines: 10,
              minLines: 8,
              validator: _requiredValidator,
              decoration: InputDecoration(
                hintText: 'Compose email content...',
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
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _contentController,
              builder: (_, value, _) {
                final content = _cleanContentPreview(value.text);

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Preview', style: AppTextStyles.labelMedium),
                      const SizedBox(height: 6),
                      Text(
                        content.isEmpty ? '-' : content,
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                );
              },
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

class _EditorToolbar extends StatelessWidget {
  const _EditorToolbar({
    required this.selectedFont,
    required this.selectedFontSize,
    required this.fontOptions,
    required this.fontSizeOptions,
    required this.onBold,
    required this.onItalic,
    required this.onUnderline,
    required this.onBulletList,
    required this.onFontChanged,
    required this.onFontSizeChanged,
  });

  final String selectedFont;
  final int selectedFontSize;
  final List<String> fontOptions;
  final List<int> fontSizeOptions;
  final VoidCallback onBold;
  final VoidCallback onItalic;
  final VoidCallback onUnderline;
  final VoidCallback onBulletList;
  final ValueChanged<String> onFontChanged;
  final ValueChanged<int> onFontSizeChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _ToolbarButton(
            tooltip: 'Bold',
            icon: Icons.format_bold_rounded,
            onPressed: onBold,
          ),
          _ToolbarButton(
            tooltip: 'Italic',
            icon: Icons.format_italic_rounded,
            onPressed: onItalic,
          ),
          _ToolbarButton(
            tooltip: 'Underline',
            icon: Icons.format_underline_rounded,
            onPressed: onUnderline,
          ),
          _ToolbarButton(
            tooltip: 'Bullet List',
            icon: Icons.format_list_bulleted_rounded,
            onPressed: onBulletList,
          ),
          PopupMenuButton<String>(
            tooltip: 'Font Family',
            onSelected: onFontChanged,
            itemBuilder: (_) => fontOptions
                .map(
                  (font) =>
                      PopupMenuItem<String>(value: font, child: Text(font)),
                )
                .toList(),
            child: _ToolbarChip(label: 'Font: $selectedFont'),
          ),
          PopupMenuButton<int>(
            tooltip: 'Font Size',
            onSelected: onFontSizeChanged,
            itemBuilder: (_) => fontSizeOptions
                .map(
                  (size) =>
                      PopupMenuItem<int>(value: size, child: Text('${size}px')),
                )
                .toList(),
            child: _ToolbarChip(label: 'Size: ${selectedFontSize}px'),
          ),
        ],
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.accentBlue.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Tooltip(
            message: tooltip,
            child: Icon(icon, size: 18, color: AppColors.accentBlue),
          ),
        ),
      ),
    );
  }
}

class _ToolbarChip extends StatelessWidget {
  const _ToolbarChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.accentBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(color: AppColors.accentBlue),
      ),
    );
  }
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
