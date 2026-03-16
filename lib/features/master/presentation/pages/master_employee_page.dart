import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/master_employee_data.dart';

class MasterEmployeePage extends StatefulWidget {
  const MasterEmployeePage({super.key});

  @override
  State<MasterEmployeePage> createState() => _MasterEmployeePageState();
}

class _MasterEmployeePageState extends State<MasterEmployeePage> {
  final TextEditingController _searchFilterController = TextEditingController();

  final List<MasterEmployeeData> _employees = [
    MasterEmployeeData(
      id: 'emp-001',
      employeeId: 'EMP-1001',
      employeeName: 'Alifi Ramadhan',
      gender: 'Male',
      email: 'alifi.ramadhan@msi.com',
      createdBy: 'HR Admin',
      createdDate: DateTime(2024, 2, 10),
      status: 'Active',
    ),
    MasterEmployeeData(
      id: 'emp-002',
      employeeId: 'EMP-1002',
      employeeName: 'Dewi Kartika',
      gender: 'Female',
      email: 'dewi.kartika@msi.com',
      createdBy: 'Super Admin',
      createdDate: DateTime(2023, 9, 15),
      status: 'Active',
    ),
    MasterEmployeeData(
      id: 'emp-003',
      employeeId: 'EMP-1003',
      employeeName: 'Rizky Saputra',
      gender: 'Male',
      email: 'rizky.saputra@msi.com',
      createdBy: 'HR Admin',
      createdDate: DateTime(2022, 4, 21),
      status: 'Inactive',
    ),
  ];

  bool get _hasActiveFilters => _searchFilterController.text.trim().isNotEmpty;

  List<MasterEmployeeData> get _filteredEmployees {
    final query = _searchFilterController.text.trim().toLowerCase();

    if (query.isEmpty) return _employees;

    return _employees.where((employee) {
      return employee.employeeId.toLowerCase().contains(query) ||
          employee.employeeName.toLowerCase().contains(query) ||
          employee.gender.toLowerCase().contains(query) ||
          employee.email.toLowerCase().contains(query) ||
          employee.createdBy.toLowerCase().contains(query) ||
          employee.status.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchFilterController.dispose();
    super.dispose();
  }

  Future<void> _openAddEmployeeForm() async {
    final newEmployee = await context.push<MasterEmployeeData>(
      RoutePaths.masterEmployeeAdd,
    );

    if (!mounted || newEmployee == null) return;
    setState(() => _upsertEmployee(newEmployee));
  }

  Future<void> _openEmployeeDetail(MasterEmployeeData employee) async {
    final updatedEmployee = await context.push<MasterEmployeeData>(
      RoutePaths.masterEmployeeDetail,
      extra: employee,
    );

    if (!mounted || updatedEmployee == null) return;
    setState(() => _upsertEmployee(updatedEmployee));
  }

  void _upsertEmployee(MasterEmployeeData employee) {
    final index = _employees.indexWhere((item) => item.id == employee.id);
    if (index >= 0) {
      _employees[index] = employee;
      return;
    }

    _employees.insert(0, employee);
  }

  void _resetFilters() {
    _searchFilterController.clear();
    setState(() {});
  }

  void _exportToExcel() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export to Excel berhasil (dummy UI).')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredEmployees = _filteredEmployees;

    return Scaffold(
      appBar: AppBar(title: const Text('Master Employee')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        children: [
          ElevatedButton.icon(
            onPressed: _openAddEmployeeForm,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add Employee'),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _exportToExcel,
            icon: const Icon(Icons.table_view_rounded, size: 18),
            label: const Text('Export to Excel'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: AppColors.white,
            ),
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
                  controller: _searchFilterController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Search',
                    hintText: 'Search employee data',
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
          if (filteredEmployees.isEmpty)
            const _EmptyEmployeeState()
          else
            ...filteredEmployees.map(
              (employee) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _EmployeeCard(
                  employee: employee,
                  onTap: () => _openEmployeeDetail(employee),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmployeeCard extends StatelessWidget {
  const _EmployeeCard({required this.employee, required this.onTap});

  final MasterEmployeeData employee;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = employee.isActive ? AppColors.success : AppColors.error;

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
                Icons.people_alt_rounded,
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
                          employee.employeeId,
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
                          employee.status,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(employee.employeeName, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 2),
                  Text(
                    '${employee.gender} • ${employee.email}',
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

class _EmptyEmployeeState extends StatelessWidget {
  const _EmptyEmployeeState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'Data employee tidak ditemukan',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
