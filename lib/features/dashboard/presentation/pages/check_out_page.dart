import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/attendance_provider.dart';

/// Dummy data for dropdowns.
const _companies = [
  'PT Magna Solusi Indonesia',
  'PT Kino Indonesia',
  'Saint John Bungur',
];

const _taskNames = [
  'Development',
  'Testing',
  'Meeting',
  'Documentation',
  'Design',
  'Research',
  'Deployment',
];

const _subTasks = [
  'Bug Fix',
  'Feature Implementation',
  'Code Review',
  'Unit Test',
  'Integration Test',
  'UI Design',
  'API Integration',
  'Database Migration',
];

const _statuses = ['Open', 'On Progress', 'Done'];

/// A single task entry in the checkout form.
class _TaskEntry {
  String? company;
  String? taskName;
  String? subTask;
  TimeOfDay? taskStart;
  TimeOfDay? taskEnd;
  String? status;
  String notes = '';

  _TaskEntry();

  bool get isValid =>
      company != null &&
      taskName != null &&
      subTask != null &&
      taskStart != null &&
      taskEnd != null &&
      status != null;
}

class CheckOutPage extends ConsumerStatefulWidget {
  const CheckOutPage({super.key});

  @override
  ConsumerState<CheckOutPage> createState() => _CheckOutPageState();
}

class _CheckOutPageState extends ConsumerState<CheckOutPage> {
  final List<_TaskEntry> _tasks = [_TaskEntry()];
  final List<_TaskEntry> _otherTasks = [];
  bool _isSubmitting = false;

  bool get _canSubmit =>
      _tasks.every((t) => t.isValid) && !_isSubmitting;

  Future<void> _pickTime({
    required _TaskEntry task,
    required bool isStart,
  }) async {
    final initial = isStart
        ? (task.taskStart ?? TimeOfDay.now())
        : (task.taskEnd ?? TimeOfDay.now());
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          task.taskStart = picked;
        } else {
          task.taskEnd = picked;
        }
      });
    }
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '--:--';
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _isSubmitting = true);

    await Future<void>.delayed(const Duration(milliseconds: 500));

    ref.read(attendanceProvider.notifier).checkOut();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Check-out successful!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check Out'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Task Report', style: AppTextStyles.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Fill in the tasks you worked on today.',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 20),

          // ── Main tasks ──────────────────────────
          ...List.generate(_tasks.length, (i) {
            return _TaskCard(
              entry: _tasks[i],
              index: i + 1,
              canRemove: _tasks.length > 1,
              onRemove: () => setState(() => _tasks.removeAt(i)),
              onChanged: () => setState(() {}),
              onPickStart: () =>
                  _pickTime(task: _tasks[i], isStart: true),
              onPickEnd: () =>
                  _pickTime(task: _tasks[i], isStart: false),
              formatTime: _formatTime,
            );
          }),

          // ── Add task button ─────────────────────
          TextButton.icon(
            onPressed: () =>
                setState(() => _tasks.add(_TaskEntry())),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add Task'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.accentBlue,
            ),
          ),

          const SizedBox(height: 16),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 16),

          // ── Other tasks (optional) ──────────────
          Row(
            children: [
              Expanded(
                child: Text(
                  'Other Tasks (Optional)',
                  style: AppTextStyles.titleSmall,
                ),
              ),
              TextButton.icon(
                onPressed: () =>
                    setState(() => _otherTasks.add(_TaskEntry())),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Add'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.accentBlue,
                ),
              ),
            ],
          ),
          if (_otherTasks.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'No additional tasks added.',
                style: AppTextStyles.bodySmall,
              ),
            ),
          ...List.generate(_otherTasks.length, (i) {
            return _TaskCard(
              entry: _otherTasks[i],
              index: i + 1,
              label: 'Other Task',
              canRemove: true,
              onRemove: () =>
                  setState(() => _otherTasks.removeAt(i)),
              onChanged: () => setState(() {}),
              onPickStart: () =>
                  _pickTime(task: _otherTasks[i], isStart: true),
              onPickEnd: () =>
                  _pickTime(task: _otherTasks[i], isStart: false),
              formatTime: _formatTime,
            );
          }),

          // ── Submit ──────────────────────────────
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _canSubmit ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.white,
                disabledBackgroundColor: AppColors.divider,
                disabledForegroundColor: AppColors.textHint,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.white,
                      ),
                    )
                  : const Text('Submit Check Out'),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ── Task Card Widget ────────────────────────────────────

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.entry,
    required this.index,
    required this.canRemove,
    required this.onRemove,
    required this.onChanged,
    required this.onPickStart,
    required this.onPickEnd,
    required this.formatTime,
    this.label = 'Task',
  });

  final _TaskEntry entry;
  final int index;
  final bool canRemove;
  final VoidCallback onRemove;
  final VoidCallback onChanged;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;
  final String Function(TimeOfDay?) formatTime;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────
          Row(
            children: [
              Text(
                '$label #$index',
                style: AppTextStyles.titleSmall,
              ),
              const Spacer(),
              if (canRemove)
                GestureDetector(
                  onTap: onRemove,
                  child: const Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: AppColors.error,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Company ─────────────────────────────
          _buildDropdown(
            label: 'Company / Project',
            value: entry.company,
            items: _companies,
            onChanged: (v) {
              entry.company = v;
              onChanged();
            },
          ),
          const SizedBox(height: 12),

          // ── Task Name ───────────────────────────
          _buildDropdown(
            label: 'Task Name',
            value: entry.taskName,
            items: _taskNames,
            onChanged: (v) {
              entry.taskName = v;
              onChanged();
            },
          ),
          const SizedBox(height: 12),

          // ── Sub Task ────────────────────────────
          _buildDropdown(
            label: 'Sub Task Description',
            value: entry.subTask,
            items: _subTasks,
            onChanged: (v) {
              entry.subTask = v;
              onChanged();
            },
          ),
          const SizedBox(height: 12),

          // ── Start & End ─────────────────────────
          Row(
            children: [
              Expanded(
                child: _buildTimePicker(
                  label: 'Task Start',
                  value: formatTime(entry.taskStart),
                  onTap: onPickStart,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimePicker(
                  label: 'Task End',
                  value: formatTime(entry.taskEnd),
                  onTap: onPickEnd,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Status ──────────────────────────────
          _buildDropdown(
            label: 'Status',
            value: entry.status,
            items: _statuses,
            onChanged: (v) {
              entry.status = v;
              onChanged();
            },
          ),
          const SizedBox(height: 12),

          // ── Notes ───────────────────────────────
          Text('Notes', style: AppTextStyles.labelMedium),
          const SizedBox(height: 6),
          TextField(
            onChanged: (v) => entry.notes = v,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Additional notes...',
              hintStyle: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textHint,
              ),
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.divider,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.divider,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.accentBlue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMedium),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.divider,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.divider,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.accentBlue,
              ),
            ),
          ),
          hint: Text(
            'Select $label',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textHint,
            ),
          ),
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: AppTextStyles.bodyMedium),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildTimePicker({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMedium),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
