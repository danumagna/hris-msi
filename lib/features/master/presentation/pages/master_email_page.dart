import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/master_email_data.dart';

class MasterEmailPage extends StatefulWidget {
  const MasterEmailPage({super.key});

  @override
  State<MasterEmailPage> createState() => _MasterEmailPageState();
}

class _MasterEmailPageState extends State<MasterEmailPage> {
  static const List<String> _statusOptions = ['All', 'Active', 'Inactive'];

  final TextEditingController _codeFilterController = TextEditingController();
  final TextEditingController _subjectFilterController =
      TextEditingController();
  final TextEditingController _titleFilterController = TextEditingController();

  String _selectedStatusFilter = 'All';

  final List<MasterEmailData> _emails = [
    MasterEmailData(
      id: 'email-001',
      code: 'EML-0001',
      emailTitle: 'Welcome New Employee',
      emailSubject: 'Welcome to HRIS MSI',
      emailContent:
          'Hello Team,\n\n<b>Welcome</b> to HRIS MSI and please complete your profile.',
      effectiveStartDate: DateTime(2024, 1, 1),
      isExpired: false,
      status: 'Active',
    ),
    MasterEmailData(
      id: 'email-002',
      code: 'EML-0002',
      emailTitle: 'Leave Approval Notification',
      emailSubject: 'Your leave request has been approved',
      emailContent:
          'Dear Employee,\n\n<i>Your leave request</i> has been approved.',
      effectiveStartDate: DateTime(2023, 9, 1),
      isExpired: false,
      status: 'Active',
    ),
    MasterEmailData(
      id: 'email-003',
      code: 'EML-0003',
      emailTitle: 'Legacy Overtime Template',
      emailSubject: 'Legacy overtime notification',
      emailContent: 'Template lama untuk notifikasi lembur.',
      effectiveStartDate: DateTime(2022, 2, 1),
      isExpired: true,
      effectiveEndDate: DateTime(2024, 12, 31),
      status: 'Inactive',
    ),
  ];

  bool get _hasActiveFilters {
    return _codeFilterController.text.trim().isNotEmpty ||
        _subjectFilterController.text.trim().isNotEmpty ||
        _titleFilterController.text.trim().isNotEmpty ||
        _selectedStatusFilter != 'All';
  }

  List<MasterEmailData> get _filteredEmails {
    final codeQuery = _codeFilterController.text.trim().toLowerCase();
    final subjectQuery = _subjectFilterController.text.trim().toLowerCase();
    final titleQuery = _titleFilterController.text.trim().toLowerCase();

    return _emails.where((item) {
      final matchesCode =
          codeQuery.isEmpty || item.code.toLowerCase().contains(codeQuery);
      final matchesSubject =
          subjectQuery.isEmpty ||
          item.emailSubject.toLowerCase().contains(subjectQuery);
      final matchesTitle =
          titleQuery.isEmpty ||
          item.emailTitle.toLowerCase().contains(titleQuery);
      final matchesStatus =
          _selectedStatusFilter == 'All' ||
          item.status == _selectedStatusFilter;

      return matchesCode && matchesSubject && matchesTitle && matchesStatus;
    }).toList();
  }

  @override
  void dispose() {
    _codeFilterController.dispose();
    _subjectFilterController.dispose();
    _titleFilterController.dispose();
    super.dispose();
  }

  Future<void> _openAddForm() async {
    final newData = await context.push<MasterEmailData>(
      RoutePaths.masterEmailAdd,
    );

    if (!mounted || newData == null) return;
    setState(() => _upsertEmail(newData));
  }

  Future<void> _openDetail(MasterEmailData item) async {
    final updatedData = await context.push<MasterEmailData>(
      RoutePaths.masterEmailDetail,
      extra: item,
    );

    if (!mounted || updatedData == null) return;
    setState(() => _upsertEmail(updatedData));
  }

  void _upsertEmail(MasterEmailData item) {
    final index = _emails.indexWhere((existing) => existing.id == item.id);
    if (index >= 0) {
      _emails[index] = item;
      return;
    }

    _emails.insert(0, item);
  }

  void _resetFilters() {
    _codeFilterController.clear();
    _subjectFilterController.clear();
    _titleFilterController.clear();
    _selectedStatusFilter = 'All';
    setState(() {});
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _toSnippet(String text) {
    final withoutTags = text.replaceAll(RegExp(r'<[^>]*>'), '');
    if (withoutTags.length <= 68) return withoutTags;
    return '${withoutTags.substring(0, 68)}...';
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _filteredEmails;

    return Scaffold(
      appBar: AppBar(title: const Text('Master Email')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        children: [
          ElevatedButton.icon(
            onPressed: _openAddForm,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add Form'),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    TextButton.icon(
                      onPressed: _hasActiveFilters ? _resetFilters : null,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Reset Filter'),
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
                const SizedBox(height: 10),
                TextField(
                  controller: _codeFilterController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Code',
                    hintText: 'Search code',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _subjectFilterController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Email Subject',
                    hintText: 'Search email subject',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _titleFilterController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Email Title',
                    hintText: 'Search email title',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: _selectedStatusFilter,
                  items: _statusOptions
                      .map(
                        (option) => DropdownMenuItem(
                          value: option,
                          child: Text(option),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedStatusFilter = value);
                  },
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (filteredItems.isEmpty)
            const _EmptyEmailState()
          else
            ...filteredItems.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _EmailCard(
                  data: item,
                  onTap: () => _openDetail(item),
                  dateLabel: _formatDate(item.effectiveStartDate),
                  contentSnippet: _toSnippet(item.emailContent),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmailCard extends StatelessWidget {
  const _EmailCard({
    required this.data,
    required this.onTap,
    required this.dateLabel,
    required this.contentSnippet,
  });

  final MasterEmailData data;
  final VoidCallback onTap;
  final String dateLabel;
  final String contentSnippet;

  @override
  Widget build(BuildContext context) {
    final statusColor = data.isActive ? AppColors.success : AppColors.error;

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
                Icons.email_rounded,
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
                        child: Text(data.code, style: AppTextStyles.titleSmall),
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
                          data.status,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(data.emailTitle, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 2),
                  Text(
                    '${data.emailSubject} • $dateLabel',
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    contentSnippet,
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

class _EmptyEmailState extends StatelessWidget {
  const _EmptyEmailState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'Data email tidak ditemukan',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
