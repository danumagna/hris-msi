import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class MasterApprovalViewPage extends StatefulWidget {
  const MasterApprovalViewPage({super.key});

  @override
  State<MasterApprovalViewPage> createState() => _MasterApprovalViewPageState();
}

class _MasterApprovalViewPageState extends State<MasterApprovalViewPage> {
  static const List<String> _companyCodeOptions = ['MSI', 'MEDU', 'MCORP'];

  static const List<String> _transactionOptions = [
    'Leave Request',
    'Overtime Request',
    'Reimbursement',
    'Transfer Request',
  ];

  final TextEditingController _positionCodeController = TextEditingController();

  String _selectedCompanyCode = _companyCodeOptions.first;
  String _selectedTransaction = _transactionOptions.first;

  @override
  void dispose() {
    _positionCodeController.dispose();
    super.dispose();
  }

  void _viewApproval() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('View Approval berhasil (dummy UI).')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('View Approval')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
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
                Text('Search Criteria', style: AppTextStyles.titleSmall),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCompanyCode,
                  items: _companyCodeOptions
                      .map(
                        (option) => DropdownMenuItem(
                          value: option,
                          child: Text(option),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedCompanyCode = value);
                  },
                  decoration: const InputDecoration(
                    labelText: 'Company Code',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _positionCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Position Code',
                    hintText: 'Search position code',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: _selectedTransaction,
                  items: _transactionOptions
                      .map(
                        (option) => DropdownMenuItem(
                          value: option,
                          child: Text(option),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedTransaction = value);
                  },
                  decoration: const InputDecoration(
                    labelText: 'Transaction',
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
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _viewApproval,
            icon: const Icon(Icons.visibility_rounded),
            label: const Text('View Approval'),
          ),
        ],
      ),
    );
  }
}
