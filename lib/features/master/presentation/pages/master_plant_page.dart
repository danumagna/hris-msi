import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/master_plant_data.dart';

class MasterPlantPage extends StatefulWidget {
  const MasterPlantPage({super.key});

  @override
  State<MasterPlantPage> createState() => _MasterPlantPageState();
}

class _MasterPlantPageState extends State<MasterPlantPage> {
  final TextEditingController _searchController = TextEditingController();
  static const String _allCompanyNameLabel = 'All Company';
  static const String _allCityLabel = 'All City';

  final List<MasterPlantData> _plants = [
    MasterPlantData(
      id: 'plt-001',
      companyName: 'MSI Headquarter',
      plantCode: 'PLT-JKT-01',
      plantName: 'Jakarta Main Plant',
      plantDesc: 'Main manufacturing plant area',
      city: 'Jakarta',
      street: 'Jl. Industri Raya No. 1',
      postalCode: '10220',
      effectiveStartDate: DateTime(2023, 1, 1),
    ),
    MasterPlantData(
      id: 'plt-002',
      companyName: 'MSI Surabaya Branch',
      plantCode: 'PLT-SBY-01',
      plantName: 'Surabaya Plant',
      plantDesc: 'Branch plant East Java',
      city: 'Surabaya',
      street: 'Jl. Industri Timur No. 10',
      postalCode: '60271',
      effectiveStartDate: DateTime(2022, 6, 1),
    ),
    MasterPlantData(
      id: 'plt-003',
      companyName: 'MSI Bandung Branch',
      plantCode: 'PLT-BDG-01',
      plantName: 'Bandung Pilot Plant',
      plantDesc: 'Pilot production and RnD plant',
      city: 'Bandung',
      street: 'Jl. Teknologi No. 8',
      postalCode: '40111',
      effectiveStartDate: DateTime(2021, 3, 12),
      effectiveEndDate: DateTime(2024, 12, 31),
    ),
  ];

  String _companyNameFilter = _allCompanyNameLabel;
  String _cityFilter = _allCityLabel;
  String _statusFilter = 'all';

  bool get _hasActiveFilters {
    return _companyNameFilter != _allCompanyNameLabel ||
        _cityFilter != _allCityLabel ||
        _statusFilter != 'all' ||
        _searchController.text.trim().isNotEmpty;
  }

  List<String> get _companyNameOptions {
    final values = _plants.map((plant) => plant.companyName).toSet();
    final options = values.toList()..sort();
    return [_allCompanyNameLabel, ...options];
  }

  List<String> get _cityOptions {
    final values = _plants.map((plant) => plant.city).toSet();
    final options = values.toList()..sort();
    return [_allCityLabel, ...options];
  }

  List<MasterPlantData> get _filteredPlants {
    final searchQuery = _searchController.text.trim().toLowerCase();

    return _plants.where((plant) {
      final matchesCompany =
          _companyNameFilter == _allCompanyNameLabel ||
          plant.companyName == _companyNameFilter;
      final matchesCity =
          _cityFilter == _allCityLabel || plant.city == _cityFilter;
      final matchesSearch =
          searchQuery.isEmpty ||
          plant.plantName.toLowerCase().contains(searchQuery) ||
          plant.plantCode.toLowerCase().contains(searchQuery) ||
          plant.companyName.toLowerCase().contains(searchQuery) ||
          plant.city.toLowerCase().contains(searchQuery);

      final matchesStatus = switch (_statusFilter) {
        'active' => plant.isActive,
        'inactive' => !plant.isActive,
        _ => true,
      };

      return matchesCompany && matchesCity && matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openAddPlantForm() async {
    final newPlant = await context.push<MasterPlantData>(
      RoutePaths.masterPlantAdd,
    );

    if (!mounted || newPlant == null) return;
    setState(() => _upsertPlant(newPlant));
  }

  Future<void> _openPlantDetail(MasterPlantData plant) async {
    final updatedPlant = await context.push<MasterPlantData>(
      RoutePaths.masterPlantDetail,
      extra: plant,
    );

    if (!mounted || updatedPlant == null) return;
    setState(() => _upsertPlant(updatedPlant));
  }

  void _upsertPlant(MasterPlantData plant) {
    final index = _plants.indexWhere((item) => item.id == plant.id);
    if (index >= 0) {
      _plants[index] = plant;
      return;
    }

    _plants.insert(0, plant);
  }

  Future<void> _pickCompanyName() async {
    final result = await _openOptionFilterSheet(
      title: 'Filter Company Name',
      options: _companyNameOptions,
      selectedValue: _companyNameFilter,
    );

    if (!mounted || result == null) return;
    setState(() => _companyNameFilter = result);
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
      _companyNameFilter = _allCompanyNameLabel;
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
    final filteredPlants = _filteredPlants;

    return Scaffold(
      appBar: AppBar(title: const Text('Master Plant')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _openAddPlantForm,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add Plant'),
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
                      child: _PlantFilterChip(
                        icon: Icons.business_rounded,
                        label: _companyNameFilter,
                        onTap: _pickCompanyName,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _PlantFilterChip(
                        icon: Icons.location_city_rounded,
                        label: _cityFilter,
                        onTap: _pickCity,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _PlantFilterChip(
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
                hintText: 'Search plant name, code, company, city...',
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
            child: filteredPlants.isEmpty
                ? const _EmptyPlantState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    itemCount: filteredPlants.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, index) {
                      final plant = filteredPlants[index];
                      return _PlantCard(
                        plant: plant,
                        onTap: () => _openPlantDetail(plant),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _PlantFilterChip extends StatelessWidget {
  const _PlantFilterChip({
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

class _PlantCard extends StatelessWidget {
  const _PlantCard({required this.plant, required this.onTap});

  final MasterPlantData plant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = plant.isActive ? AppColors.success : AppColors.error;

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
                Icons.factory_rounded,
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
                          plant.plantCode,
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
                          plant.statusLabel,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(plant.plantName, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 2),
                  Text(
                    '${plant.companyName} • ${plant.city}',
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

class _EmptyPlantState extends StatelessWidget {
  const _EmptyPlantState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Data plant tidak ditemukan',
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}
