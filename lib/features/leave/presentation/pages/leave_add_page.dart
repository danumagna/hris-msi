import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/leave_request.dart';
import '../providers/leave_provider.dart';

/// Form page for creating a new leave request.
class LeaveAddPage extends ConsumerStatefulWidget {
  const LeaveAddPage({super.key});

  @override
  ConsumerState<LeaveAddPage> createState() => _LeaveAddPageState();
}

class _LeaveAddPageState extends ConsumerState<LeaveAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  LeaveType? _selectedType;
  LeaveDayMode _selectedDayMode = LeaveDayMode.fullDay;
  DateTime? _startDate;
  DateTime? _endDate;
  _SubstituteEmployee? _selectedSubstitute;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final leaveDays = _calculateLeaveDays();

    return Scaffold(
      appBar: AppBar(title: const Text('Add New Leave Request')),
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
                      _buildLabel('Leave No'),
                      const SizedBox(height: 6),
                      _buildStaticInfoField(
                        icon: Icons.confirmation_number_rounded,
                        value: 'Auto Generate',
                        helper: 'Will be generated after submit',
                      ),
                      const SizedBox(height: 16),

                      _buildLabel('Leave Type'),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<LeaveType>(
                        initialValue: _selectedType,
                        decoration: const InputDecoration(
                          hintText: 'Select leave type',
                        ),
                        items: LeaveType.values
                            .map(
                              (type) => DropdownMenuItem<LeaveType>(
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
                      const SizedBox(height: 8),
                      _buildBalanceInfo(),
                      const SizedBox(height: 16),

                      _buildLabel('Day Mode'),
                      const SizedBox(height: 6),
                      Row(
                        children: LeaveDayMode.values.map((mode) {
                          final selected = _selectedDayMode == mode;
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: mode == LeaveDayMode.fullDay ? 6 : 0,
                                left: mode == LeaveDayMode.halfDay ? 6 : 0,
                              ),
                              child: InkWell(
                                onTap: () {
                                  setState(() => _selectedDayMode = mode);
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? AppColors.darkBlue.withValues(
                                            alpha: 0.08,
                                          )
                                        : AppColors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: selected
                                          ? AppColors.darkBlue
                                          : AppColors.border,
                                      width: selected ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        mode == LeaveDayMode.fullDay
                                            ? Icons.wb_sunny_rounded
                                            : Icons.brightness_3_rounded,
                                        size: 16,
                                        color: selected
                                            ? AppColors.darkBlue
                                            : AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        mode.label,
                                        style: AppTextStyles.labelLarge
                                            .copyWith(
                                              color: selected
                                                  ? AppColors.darkBlue
                                                  : AppColors.textSecondary,
                                              fontWeight: selected
                                                  ? FontWeight.w600
                                                  : FontWeight.w500,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      _buildLabel('Leave Period'),
                      const SizedBox(height: 6),
                      _DatePickerField(
                        value: _startDate,
                        hint: 'Pick start date',
                        onPicked: (value) => setState(() => _startDate = value),
                      ),
                      const SizedBox(height: 10),
                      _DatePickerField(
                        value: _endDate,
                        hint: 'Pick end date',
                        onPicked: (value) => setState(() => _endDate = value),
                      ),
                      const SizedBox(height: 16),

                      _buildLabel('Leave Days'),
                      const SizedBox(height: 6),
                      _buildLeaveDaysInfo(leaveDays),
                      const SizedBox(height: 20),

                      Text(
                        'Substitute Section',
                        style: AppTextStyles.titleSmall.copyWith(
                          color: AppColors.darkBlue,
                        ),
                      ),
                      const SizedBox(height: 10),

                      _buildLabel('Substitute Id'),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: _pickSubstitute,
                        borderRadius: BorderRadius.circular(12),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            hintText: 'Search substitute id',
                            suffixIcon: Icon(Icons.search_rounded, size: 20),
                          ),
                          child: Text(
                            _selectedSubstitute?.id ?? 'Tap to search/lookup',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: _selectedSubstitute == null
                                  ? AppColors.textHint
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      _buildLabel('Substitute Name'),
                      const SizedBox(height: 6),
                      _buildStaticInfoField(
                        icon: Icons.person_rounded,
                        value: _selectedSubstitute?.name ?? 'Budi Santoso',
                        helper: 'Auto-filled from substitute lookup',
                      ),
                      const SizedBox(height: 10),

                      _buildLabel('Substitute Position'),
                      const SizedBox(height: 6),
                      _buildStaticInfoField(
                        icon: Icons.badge_rounded,
                        value:
                            _selectedSubstitute?.position ?? 'Senior Analyst',
                        helper: 'Auto-filled from substitute lookup',
                      ),
                      const SizedBox(height: 16),

                      _buildLabel('Leave Notes'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Add additional notes',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
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

  Widget _buildBalanceInfo() {
    final selectedType = _selectedType;
    final balance = selectedType != null
        ? leaveTypeBalances[selectedType] ?? '-'
        : '-';

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
          Text(
            'Leave Balance: $balance',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
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

  Widget _buildLeaveDaysInfo(double leaveDays) {
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
              Icons.date_range_rounded,
              color: AppColors.darkBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatLeaveDays(leaveDays),
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.darkBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text('Count days - holiday', style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _calculateLeaveDays() {
    final startDate = _startDate;
    final endDate = _endDate;

    if (startDate == null || endDate == null) {
      return 3;
    }

    if (endDate.isBefore(startDate)) {
      return 0;
    }

    var days = 0;
    var cursor = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);

    while (!cursor.isAfter(end)) {
      final isWeekend =
          cursor.weekday == DateTime.saturday ||
          cursor.weekday == DateTime.sunday;
      if (!isWeekend) {
        days += 1;
      }
      cursor = cursor.add(const Duration(days: 1));
    }

    if (_selectedDayMode == LeaveDayMode.halfDay) {
      return days * 0.5;
    }
    return days.toDouble();
  }

  String _generateLeaveNo() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    final h = now.hour.toString().padLeft(2, '0');
    final min = now.minute.toString().padLeft(2, '0');
    return 'LV-$y$m$d-$h$min';
  }

  Future<void> _pickSubstitute() async {
    final selected = await showModalBottomSheet<_SubstituteEmployee>(
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
            Text('Select Substitute', style: AppTextStyles.titleMedium),
            const SizedBox(height: 8),
            ..._dummySubstitutes.map(
              (employee) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.darkBlue.withValues(alpha: 0.1),
                  child: const Icon(
                    Icons.person_rounded,
                    size: 18,
                    color: AppColors.darkBlue,
                  ),
                ),
                title: Text('${employee.id} • ${employee.name}'),
                subtitle: Text(employee.position),
                onTap: () => Navigator.pop(context, employee),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );

    if (!mounted || selected == null) return;
    setState(() => _selectedSubstitute = selected);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedType == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select leave type')));
      return;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick start and end date')),
      );
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date cannot be before start date')),
      );
      return;
    }

    final substitute = _selectedSubstitute ?? _dummySubstitutes.first;

    final leaveRequest = LeaveRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      leaveNo: _generateLeaveNo(),
      type: _selectedType!,
      dayMode: _selectedDayMode,
      startDate: _startDate!,
      endDate: _endDate!,
      leaveDays: _calculateLeaveDays(),
      substituteId: substitute.id,
      substituteName: substitute.name,
      substitutePosition: substitute.position,
      notes: _notesController.text.trim(),
      entryTime: DateTime.now(),
      status: 'Waiting for approval',
    );

    ref.read(leaveProvider.notifier).add(leaveRequest);

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

String _formatLeaveDays(double value) {
  if (value == value.toInt()) {
    final intValue = value.toInt();
    return '$intValue ${intValue == 1 ? 'Day' : 'Days'}';
  }
  return '${value.toStringAsFixed(1)} Days';
}

class _SubstituteEmployee {
  final String id;
  final String name;
  final String position;

  const _SubstituteEmployee({
    required this.id,
    required this.name,
    required this.position,
  });
}

const List<_SubstituteEmployee> _dummySubstitutes = [
  _SubstituteEmployee(
    id: 'EMP-1008',
    name: 'Tryadi Christianto',
    position: 'Fullstack Developer',
  ),
  _SubstituteEmployee(
    id: 'EMP-1015',
    name: 'Anggie Tamara',
    position: 'Fullstack Developer',
  ),
  _SubstituteEmployee(
    id: 'EMP-1019',
    name: 'Gerald Nathaniel S',
    position: 'Fullstack Developer',
  ),
];
