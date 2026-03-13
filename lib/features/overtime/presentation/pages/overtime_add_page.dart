import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/overtime_request.dart';
import '../providers/overtime_provider.dart';

/// Form page for creating a new overtime request.
class OvertimeAddPage extends ConsumerStatefulWidget {
  const OvertimeAddPage({super.key});

  @override
  ConsumerState<OvertimeAddPage> createState() => _OvertimeAddPageState();
}

class _OvertimeAddPageState extends ConsumerState<OvertimeAddPage> {
  final _formKey = GlobalKey<FormState>();

  OvertimeType? _selectedType = OvertimeType.workday;
  DateTime? _overtimeDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  final List<String> _evidenceFiles = [];

  @override
  Widget build(BuildContext context) {
    final durationHours = _calculateDurationHours();

    return Scaffold(
      appBar: AppBar(title: const Text('Create Overtime')),
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
                      _buildLabel('Overtime NO'),
                      const SizedBox(height: 6),
                      _buildStaticInfoField(
                        icon: Icons.confirmation_number_rounded,
                        value: 'Auto Generate',
                        helper: 'Will be generated after submit',
                      ),
                      const SizedBox(height: 16),

                      _buildLabel('Overtime Type'),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: _pickOvertimeType,
                        borderRadius: BorderRadius.circular(12),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            hintText: 'Search overtime type',
                            suffixIcon: Icon(Icons.search_rounded, size: 20),
                          ),
                          child: Text(
                            _selectedType?.label ?? 'Tap to select type',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: _selectedType == null
                                  ? AppColors.textHint
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildTypeHint(),
                      const SizedBox(height: 16),

                      _buildLabel('Overtime Date'),
                      const SizedBox(height: 6),
                      _DatePickerField(
                        value: _overtimeDate,
                        hint: 'Pick overtime date',
                        onPicked: (value) {
                          setState(() => _overtimeDate = value);
                        },
                      ),
                      const SizedBox(height: 16),

                      _buildLabel('Working Schedule'),
                      const SizedBox(height: 6),
                      _buildWorkingScheduleCard(),
                      const SizedBox(height: 16),

                      _buildLabel('Overtime Start & End'),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: _TimePickerField(
                              value: _startTime,
                              hint: 'Start time',
                              onPicked: (value) {
                                setState(() => _startTime = value);
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _TimePickerField(
                              value: _endTime,
                              hint: 'End time',
                              onPicked: (value) {
                                setState(() => _endTime = value);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _buildLabel('Duration'),
                      const SizedBox(height: 6),
                      _buildDurationInfo(durationHours),
                      const SizedBox(height: 16),

                      _buildLabel('Upload Section'),
                      const SizedBox(height: 6),
                      _buildUploadSection(),
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

  Widget _buildTypeHint() {
    final selectedType = _selectedType;
    final hint = selectedType != null ? overtimeTypeHints[selectedType] : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 16, color: AppColors.info),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              hint ?? '-',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticInfoField({
    required IconData icon,
    required String value,
    required String helper,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            helper,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkingScheduleCard() {
    final scheduleDate = _overtimeDate ?? DateTime(2026, 3, 9);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.darkBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.schedule_rounded,
                  color: AppColors.darkBlue,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Working Schedule (Read-only)',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.darkBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _scheduleRow('Tanggal', _formatDate(scheduleDate)),
          const SizedBox(height: 4),
          _scheduleRow('Shift', 'Shift 1'),
          const SizedBox(height: 4),
          _scheduleRow('Jam', '08.00 - 17.00 WIB'),
        ],
      ),
    );
  }

  Widget _scheduleRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationInfo(double durationHours) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.darkBlue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.timelapse_rounded,
              color: AppColors.darkBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _formatDuration(durationHours),
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.darkBlue,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          onPressed: _simulateUpload,
          icon: const Icon(Icons.upload_file_rounded, size: 18),
          label: const Text('Upload Evidence'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 46),
          ),
        ),
        if (_evidenceFiles.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _evidenceFiles
                .map(
                  (file) => Chip(
                    label: Text(
                      file,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onDeleted: () {
                      setState(() => _evidenceFiles.remove(file));
                    },
                    deleteIcon: const Icon(Icons.close_rounded, size: 16),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }

  double _calculateDurationHours() {
    final startTime = _startTime;
    final endTime = _endTime;

    if (startTime == null || endTime == null) {
      return 2;
    }

    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;

    if (endMinutes <= startMinutes) {
      return 0;
    }

    final diff = endMinutes - startMinutes;
    return diff / 60.0;
  }

  Future<void> _pickOvertimeType() async {
    final selected = await showModalBottomSheet<OvertimeType>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text('Lookup Overtime Type', style: AppTextStyles.titleMedium),
            const SizedBox(height: 8),
            ...OvertimeType.values.map(
              (type) => ListTile(
                leading: Icon(_typeIcon(type), color: AppColors.darkBlue),
                title: Text(type.label),
                subtitle: Text(overtimeTypeHints[type] ?? '-'),
                onTap: () => Navigator.pop(context, type),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );

    if (!mounted || selected == null) return;
    setState(() => _selectedType = selected);
  }

  Future<void> _simulateUpload() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text('Upload Evidence', style: AppTextStyles.titleMedium),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(context, 'photo'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Pick from Gallery'),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.description_rounded),
              title: const Text('Upload Document'),
              onTap: () => Navigator.pop(context, 'doc'),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );

    if (!mounted || selected == null) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final fileName = switch (selected) {
      'photo' => 'Photo_$now.jpg',
      'gallery' => 'Gallery_$now.jpg',
      _ => 'Document_$now.pdf',
    };

    setState(() => _evidenceFiles.add(fileName));
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select overtime type')),
      );
      return;
    }

    if (_overtimeDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick overtime date')),
      );
      return;
    }

    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please pick overtime start and end time'),
        ),
      );
      return;
    }

    final startAt = DateTime(
      _overtimeDate!.year,
      _overtimeDate!.month,
      _overtimeDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );
    final endAt = DateTime(
      _overtimeDate!.year,
      _overtimeDate!.month,
      _overtimeDate!.day,
      _endTime!.hour,
      _endTime!.minute,
    );

    if (!endAt.isAfter(startAt)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time')),
      );
      return;
    }

    final overtime = OvertimeRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      overtimeNo: _generateOvertimeNo(),
      type: _selectedType!,
      overtimeDate: _overtimeDate!,
      scheduleShift: 'Shift 1',
      scheduleHours: '08.00 - 17.00 WIB',
      startAt: startAt,
      endAt: endAt,
      durationHours: endAt.difference(startAt).inMinutes / 60.0,
      evidenceFiles: [..._evidenceFiles],
      entryTime: DateTime.now(),
      status: 'Waiting for approval',
    );

    ref.read(overtimeProvider.notifier).add(overtime);

    if (context.mounted) {
      context.pop();
    }
  }

  String _generateOvertimeNo() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    final h = now.hour.toString().padLeft(2, '0');
    final min = now.minute.toString().padLeft(2, '0');
    return 'OT-$y$m$d-$h$min';
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
            ? Text(_formatDate(value!), style: AppTextStyles.bodyMedium)
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

class _TimePickerField extends StatelessWidget {
  const _TimePickerField({
    required this.value,
    required this.hint,
    required this.onPicked,
  });

  final TimeOfDay? value;
  final String hint;
  final ValueChanged<TimeOfDay> onPicked;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: value ?? const TimeOfDay(hour: 18, minute: 0),
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
          suffixIcon: const Icon(Icons.access_time_rounded, size: 18),
        ),
        child: value != null
            ? Text(_formatTimeOfDay(value!), style: AppTextStyles.bodyMedium)
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

IconData _typeIcon(OvertimeType type) {
  return switch (type) {
    OvertimeType.workday => Icons.business_center_rounded,
    OvertimeType.weekend => Icons.weekend_rounded,
    OvertimeType.holiday => Icons.celebration_rounded,
  };
}

String _formatDate(DateTime date) {
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

  final day = date.day.toString().padLeft(2, '0');
  return '$day ${months[date.month - 1]} ${date.year}';
}

String _formatTimeOfDay(TimeOfDay value) {
  final h = value.hour.toString().padLeft(2, '0');
  final m = value.minute.toString().padLeft(2, '0');
  return '$h.$m WIB';
}

String _formatDuration(double hours) {
  if (hours == hours.toInt()) {
    final h = hours.toInt();
    return '$h ${h == 1 ? 'Hour' : 'Hours'}';
  }
  return '${hours.toStringAsFixed(1)} Hours';
}
