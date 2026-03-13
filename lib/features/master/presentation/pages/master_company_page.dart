import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/master_company_data.dart';

class MasterCompanyPage extends StatefulWidget {
  const MasterCompanyPage({super.key});

  @override
  State<MasterCompanyPage> createState() => _MasterCompanyPageState();
}

class _MasterCompanyPageState extends State<MasterCompanyPage> {
  final TextEditingController _searchController = TextEditingController();
  static const String _allCompanyCodeLabel = 'All Company Code';
  static const String _allCityLabel = 'All City';

  final List<MasterCompanyData> _companies = [
    MasterCompanyData(
      id: 'cmp-001',
      companyCode: 'MSI-HQ',
      companyName: 'MSI Headquarter',
      companyDesc: 'Main business operation center',
      city: 'Jakarta',
      street: 'Jl. Jend. Sudirman No. 10',
      postalCode: '10220',
      vatRegistrationNo: 'VAT-01-001',
      telephone: '+62 21 555-8899',
      effectiveStartDate: DateTime(2023, 1, 1),
    ),
    MasterCompanyData(
      id: 'cmp-002',
      companyCode: 'MSI-SBY',
      companyName: 'MSI Surabaya Branch',
      companyDesc: 'East Java operational office',
      city: 'Surabaya',
      street: 'Jl. Basuki Rahmat No. 21',
      postalCode: '60271',
      vatRegistrationNo: 'VAT-01-002',
      telephone: '+62 31 712-4455',
      effectiveStartDate: DateTime(2022, 6, 1),
    ),
    MasterCompanyData(
      id: 'cmp-003',
      companyCode: 'MSI-BDG',
      companyName: 'MSI Bandung Branch',
      companyDesc: 'West Java branch office',
      city: 'Bandung',
      street: 'Jl. Asia Afrika No. 85',
      postalCode: '40111',
      vatRegistrationNo: 'VAT-01-003',
      telephone: '+62 22 330-2244',
      effectiveStartDate: DateTime(2021, 3, 12),
      effectiveEndDate: DateTime(2024, 12, 31),
    ),
  ];

  String _companyCodeFilter = _allCompanyCodeLabel;
  String _cityFilter = _allCityLabel;
  String _statusFilter = 'all';

  bool get _hasActiveFilters {
    return _companyCodeFilter != _allCompanyCodeLabel ||
        _cityFilter != _allCityLabel ||
        _statusFilter != 'all' ||
        _searchController.text.trim().isNotEmpty;
  }

  List<String> get _companyCodeOptions {
    final values = _companies.map((company) => company.companyCode).toSet();
    final options = values.toList()..sort();
    return [_allCompanyCodeLabel, ...options];
  }

  List<String> get _cityOptions {
    final values = _companies.map((company) => company.city).toSet();
    final options = values.toList()..sort();
    return [_allCityLabel, ...options];
  }

  List<MasterCompanyData> get _filteredCompanies {
    final searchQuery = _searchController.text.trim().toLowerCase();

    return _companies.where((company) {
      final matchesCode =
          _companyCodeFilter == _allCompanyCodeLabel ||
          company.companyCode == _companyCodeFilter;
      final matchesCity =
          _cityFilter == _allCityLabel || company.city == _cityFilter;
      final matchesSearch =
          searchQuery.isEmpty ||
          company.companyName.toLowerCase().contains(searchQuery) ||
          company.companyCode.toLowerCase().contains(searchQuery) ||
          company.city.toLowerCase().contains(searchQuery);

      final matchesStatus = switch (_statusFilter) {
        'active' => company.isActive,
        'inactive' => !company.isActive,
        _ => true,
      };

      return matchesCode && matchesCity && matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openAddCompanyForm() async {
    final newCompany = await context.push<MasterCompanyData>(
      RoutePaths.masterCompanyAdd,
    );

    if (!mounted || newCompany == null) return;
    setState(() => _upsertCompany(newCompany));
  }

  Future<void> _openCompanyDetail(MasterCompanyData company) async {
    final updatedCompany = await context.push<MasterCompanyData>(
      RoutePaths.masterCompanyDetail,
      extra: company,
    );

    if (!mounted || updatedCompany == null) return;
    setState(() => _upsertCompany(updatedCompany));
  }

  void _upsertCompany(MasterCompanyData company) {
    final index = _companies.indexWhere((item) => item.id == company.id);
    if (index >= 0) {
      _companies[index] = company;
      return;
    }

    _companies.insert(0, company);
  }

  Future<void> _pickCompanyCode() async {
    final result = await _openOptionFilterSheet(
      title: 'Filter Company Code',
      options: _companyCodeOptions,
      selectedValue: _companyCodeFilter,
    );

    if (!mounted || result == null) return;
    setState(() => _companyCodeFilter = result);
  }

  Future<void> _pickCity() async {
    final result = await _openOptionFilterSheet(
      title: 'Filter City',
      options: _cityOptions,
      selectedValue: _cityFilter,
    );

    if (!mounted || result == null) return;
    setState(() => _cityFilter = result);
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

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _companyCodeFilter = _allCompanyCodeLabel;
      _cityFilter = _allCityLabel;
      _statusFilter = 'all';
    });
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

  String get _statusLabel {
    return switch (_statusFilter) {
      'active' => 'Active',
      'inactive' => 'Inactive',
      _ => 'All Status',
    };
  }

  @override
  Widget build(BuildContext context) {
    final filteredCompanies = _filteredCompanies;

    return Scaffold(
      appBar: AppBar(title: const Text('Master Company')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _openAddCompanyForm,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add Company'),
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
                      child: _CompanyFilterChip(
                        icon: Icons.qr_code_rounded,
                        label: _companyCodeFilter,
                        onTap: _pickCompanyCode,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _CompanyFilterChip(
                        icon: Icons.location_city_rounded,
                        label: _cityFilter,
                        onTap: _pickCity,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _CompanyFilterChip(
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
                hintText: 'Search company name, code, city... ',
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
            child: filteredCompanies.isEmpty
                ? const _EmptyCompanyState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    itemCount: filteredCompanies.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, index) {
                      final company = filteredCompanies[index];
                      return _CompanyCard(
                        company: company,
                        onTap: () => _openCompanyDetail(company),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _CompanyFilterChip extends StatelessWidget {
  const _CompanyFilterChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

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

class _CompanyCard extends StatelessWidget {
  const _CompanyCard({required this.company, required this.onTap});

  final MasterCompanyData company;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = company.isActive ? AppColors.success : AppColors.error;

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
                Icons.apartment_rounded,
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
                          company.companyCode,
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
                          company.statusLabel,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(company.companyName, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 2),
                  Text(
                    '${company.city} • ${company.telephone}',
                    style: AppTextStyles.bodySmall,
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

class _EmptyCompanyState extends StatelessWidget {
  const _EmptyCompanyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Data company tidak ditemukan',
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}
