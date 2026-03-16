import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/master_position_data.dart';

class MasterPositionPage extends StatefulWidget {
  const MasterPositionPage({super.key});

  @override
  State<MasterPositionPage> createState() => _MasterPositionPageState();
}

class _MasterPositionPageState extends State<MasterPositionPage> {
  final TextEditingController _searchController = TextEditingController();

  static const String _allPositionCodeLabel = 'All Position Code';

  final List<MasterPositionData> _positions = [
    MasterPositionData(
      id: 'pos-001',
      positionCode: 'POS-HR-001',
      positionName: 'HR Specialist',
      positionDesc: 'Support HR operation and employee administration',
      positionLevel: 'Staff',
      jobSpec: 'Recruitment, onboarding, HRIS administration',
      manSpec: 'Minimum 2 years experience in HR field',
      validStartDate: DateTime(2024, 1, 1),
      majors: ['Psychology', 'Management'],
    ),
    MasterPositionData(
      id: 'pos-002',
      positionCode: 'POS-OPS-002',
      positionName: 'Production Supervisor',
      positionDesc: 'Lead production team and monitor daily output',
      positionLevel: 'Supervisor',
      jobSpec: 'Plan shift, monitor KPI, ensure safety compliance',
      manSpec: 'Strong leadership and process improvement mindset',
      validStartDate: DateTime(2023, 6, 1),
      majors: ['Industrial Engineering'],
    ),
    MasterPositionData(
      id: 'pos-003',
      positionCode: 'POS-IT-003',
      positionName: 'Legacy System Analyst',
      positionDesc: 'Maintain old internal systems and support migration',
      positionLevel: 'Senior Staff',
      jobSpec: 'Analyze system issues and create migration documentation',
      manSpec: 'Experienced in legacy ERP and SQL optimization',
      validStartDate: DateTime(2022, 1, 1),
      validEndDate: DateTime(2024, 12, 31),
      majors: ['Information System', 'Computer Science'],
    ),
  ];

  String _positionCodeFilter = _allPositionCodeLabel;
  DateTimeRange? _validDateRangeFilter;
  String _statusFilter = 'all';

  bool get _hasActiveFilters {
    return _positionCodeFilter != _allPositionCodeLabel ||
        _validDateRangeFilter != null ||
        _statusFilter != 'all' ||
        _searchController.text.trim().isNotEmpty;
  }

  List<String> get _positionCodeOptions {
    final values = _positions.map((position) => position.positionCode).toSet();
    final options = values.toList()..sort();
    return [_allPositionCodeLabel, ...options];
  }

  List<MasterPositionData> get _filteredPositions {
    final searchQuery = _searchController.text.trim().toLowerCase();

    return _positions.where((position) {
      final matchesCode =
          _positionCodeFilter == _allPositionCodeLabel ||
          position.positionCode == _positionCodeFilter;
      final matchesSearch =
          searchQuery.isEmpty ||
          position.positionName.toLowerCase().contains(searchQuery);

      final matchesStatus = switch (_statusFilter) {
        'active' => position.isActive,
        'inactive' => !position.isActive,
        _ => true,
      };

      final matchesDateRange = _matchValidDateRange(position);

      return matchesCode && matchesSearch && matchesStatus && matchesDateRange;
    }).toList();
  }

  bool _matchValidDateRange(MasterPositionData position) {
    final range = _validDateRangeFilter;
    if (range == null) return true;

    final recordStart = _dateOnly(position.validStartDate);
    final recordEnd = _dateOnly(
      position.validEndDate ?? DateTime(2100, 12, 31),
    );
    final filterStart = _dateOnly(range.start);
    final filterEnd = _dateOnly(range.end);

    return !recordEnd.isBefore(filterStart) && !recordStart.isAfter(filterEnd);
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openAddPositionForm() async {
    final newPosition = await context.push<MasterPositionData>(
      RoutePaths.masterPositionAdd,
    );

    if (!mounted || newPosition == null) return;
    setState(() => _upsertPosition(newPosition));
  }

  Future<void> _openPositionDetail(MasterPositionData position) async {
    final updatedPosition = await context.push<MasterPositionData>(
      RoutePaths.masterPositionDetail,
      extra: position,
    );

    if (!mounted || updatedPosition == null) return;
    setState(() => _upsertPosition(updatedPosition));
  }

  void _upsertPosition(MasterPositionData position) {
    final index = _positions.indexWhere((item) => item.id == position.id);
    if (index >= 0) {
      _positions[index] = position;
      return;
    }

    _positions.insert(0, position);
  }

  Future<void> _pickPositionCode() async {
    final result = await _openOptionFilterSheet(
      title: 'Filter Position Code',
      options: _positionCodeOptions,
      selectedValue: _positionCodeFilter,
    );

    if (!mounted || result == null) return;
    setState(() => _positionCodeFilter = result);
  }

  Future<void> _pickValidDateRange() async {
    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: _validDateRangeFilter,
    );

    if (pickedRange == null) return;
    setState(
      () => _validDateRangeFilter = DateTimeRange(
        start: _dateOnly(pickedRange.start),
        end: _dateOnly(pickedRange.end),
      ),
    );
  }

  void _clearValidDateRange() {
    setState(() => _validDateRangeFilter = null);
  }

  Future<void> _pickStatus() async {
    final current = _statusFilter;
    final result = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
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
              Text('Filter by Status', style: AppTextStyles.titleMedium),
              const SizedBox(height: 8),
              ListTile(
                leading: Icon(
                  Icons.all_inclusive_rounded,
                  color: current == 'all'
                      ? AppColors.darkBlue
                      : AppColors.textHint,
                ),
                title: const Text('All Status'),
                selected: current == 'all',
                onTap: () => Navigator.pop(sheetContext, 'all'),
              ),
              ListTile(
                leading: Icon(
                  Icons.check_circle_rounded,
                  color: current == 'active'
                      ? AppColors.darkBlue
                      : AppColors.textHint,
                ),
                title: const Text('Active'),
                selected: current == 'active',
                onTap: () => Navigator.pop(sheetContext, 'active'),
              ),
              ListTile(
                leading: Icon(
                  Icons.cancel_rounded,
                  color: current == 'inactive'
                      ? AppColors.darkBlue
                      : AppColors.textHint,
                ),
                title: const Text('Inactive'),
                selected: current == 'inactive',
                onTap: () => Navigator.pop(sheetContext, 'inactive'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (!mounted || result == null) return;
    setState(() => _statusFilter = result);
  }

  Future<String?> _openOptionFilterSheet({
    required String title,
    required List<String> options,
    required String selectedValue,
  }) async {
    return showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
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
              Text(title, style: AppTextStyles.titleMedium),
              const SizedBox(height: 8),
              ...options.map(
                (option) => ListTile(
                  leading: Icon(
                    Icons.label_rounded,
                    color: selectedValue == option
                        ? AppColors.darkBlue
                        : AppColors.textHint,
                  ),
                  title: Text(option),
                  selected: selectedValue == option,
                  onTap: () => Navigator.pop(sheetContext, option),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _positionCodeFilter = _allPositionCodeLabel;
      _validDateRangeFilter = null;
      _statusFilter = 'all';
    });
  }

  String get _statusLabel {
    return switch (_statusFilter) {
      'active' => 'Active',
      'inactive' => 'Inactive',
      _ => 'All Status',
    };
  }

  String get _validDateRangeLabel {
    final range = _validDateRangeFilter;
    if (range == null) return 'All Valid Date';

    return '${_formatDate(range.start)} - ${_formatDate(range.end)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final filteredPositions = _filteredPositions;

    return Scaffold(
      appBar: AppBar(title: const Text('Master Position')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _openAddPositionForm,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add Position'),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Filter',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    if (_hasActiveFilters)
                      TextButton.icon(
                        onPressed: _clearFilters,
                        icon: const Icon(
                          Icons.filter_alt_off_rounded,
                          size: 18,
                        ),
                        label: const Text('Clear Filter'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          minimumSize: Size.zero,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _PositionFilterChip(
                        icon: Icons.qr_code_rounded,
                        label: _positionCodeFilter,
                        onTap: _pickPositionCode,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _PositionFilterChip(
                        icon: Icons.date_range_rounded,
                        label: _validDateRangeLabel,
                        onTap: _pickValidDateRange,
                        onClear: _validDateRangeFilter == null
                            ? null
                            : _clearValidDateRange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _PositionFilterChip(
                  icon: Icons.toggle_on_rounded,
                  label: _statusLabel,
                  onTap: _pickStatus,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search position name...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredPositions.isEmpty
                ? const _EmptyPositionState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    itemCount: filteredPositions.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, index) {
                      final position = filteredPositions[index];
                      return _PositionCard(
                        position: position,
                        onTap: () => _openPositionDetail(position),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _PositionFilterChip extends StatelessWidget {
  const _PositionFilterChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.onClear,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.accentBlue),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.labelMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: const Padding(
                  padding: EdgeInsets.only(right: 2),
                  child: Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }
}

class _PositionCard extends StatelessWidget {
  const _PositionCard({required this.position, required this.onTap});

  final MasterPositionData position;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = position.isActive ? AppColors.success : AppColors.error;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.accentBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.badge_rounded,
                color: AppColors.accentBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          position.positionCode,
                          style: AppTextStyles.titleSmall,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          position.statusLabel,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(position.positionName, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 2),
                  Text(
                    '${position.positionLevel} • ${position.majors.join(', ')}',
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}

class _EmptyPositionState extends StatelessWidget {
  const _EmptyPositionState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Data position tidak ditemukan',
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}
