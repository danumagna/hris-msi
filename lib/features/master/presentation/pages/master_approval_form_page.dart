import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/master_approval_data.dart';

class MasterApprovalFormPage extends StatefulWidget {
  const MasterApprovalFormPage({super.key, this.initialData});

  final MasterApprovalData? initialData;

  @override
  State<MasterApprovalFormPage> createState() => _MasterApprovalFormPageState();
}

class _MasterApprovalFormPageState extends State<MasterApprovalFormPage> {
  static const List<_CompanyOption> _companyOptions = [
    _CompanyOption(code: 'MSI', name: 'Magna Solusi Indonesia'),
    _CompanyOption(code: 'MEDU', name: 'Magna Edu'),
    _CompanyOption(code: 'MCORP', name: 'Magna Corp'),
  ];

  static const List<String> _transactionOptions = [
    'Leave Request',
    'Overtime Request',
    'Reimbursement',
    'Transfer Request',
  ];

  static const List<String> _statusOptions = ['Active', 'Inactive'];

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _plantController;
  late final TextEditingController _organizationController;
  late final TextEditingController _organizationLevelController;
  late final TextEditingController _actionController;
  late final TextEditingController _employeeController;
  late final TextEditingController _approvalMaxController;

  late String _selectedCompanyCode;
  late String _selectedTransaction;
  late String _selectedStatus;
  DateTime? _effectiveStartDate;
  DateTime? _effectiveEndDate;
  bool _expired = false;

  late final List<_FlowDraft> _flows;

  bool get _isEditMode => widget.initialData != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialData;

    _plantController = TextEditingController(text: initial?.plant ?? '');
    _organizationController = TextEditingController(
      text: initial?.organization ?? '',
    );
    _organizationLevelController = TextEditingController(
      text: initial?.organizationLevel ?? '',
    );
    _actionController = TextEditingController(text: initial?.action ?? '');
    _employeeController = TextEditingController(text: initial?.employee ?? '');
    _approvalMaxController = TextEditingController(
      text: initial?.approvalMax.toString() ?? '',
    );

    _selectedCompanyCode = initial?.companyCode ?? _companyOptions.first.code;
    _selectedTransaction = initial?.transaction ?? _transactionOptions.first;
    _selectedStatus = initial?.status ?? 'Active';
    _effectiveStartDate = initial?.effectiveStartDate ?? DateTime.now();
    _expired = initial?.expired ?? false;
    _effectiveEndDate = initial?.effectiveEndDate;

    _flows = initial == null || initial.flows.isEmpty
        ? <_FlowDraft>[_FlowDraft.empty()]
        : initial.flows.map(_FlowDraft.fromData).toList();
  }

  @override
  void dispose() {
    _plantController.dispose();
    _organizationController.dispose();
    _organizationLevelController.dispose();
    _actionController.dispose();
    _employeeController.dispose();
    _approvalMaxController.dispose();
    for (final flow in _flows) {
      flow.dispose();
    }
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

  void _addFlow() {
    setState(() => _flows.add(_FlowDraft.empty()));
  }

  void _removeFlow(int index) {
    if (_flows.length <= 1) return;
    final removed = _flows.removeAt(index);
    removed.dispose();
    setState(() {});
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;
    if (_effectiveStartDate == null) return;

    if (_expired && _effectiveEndDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Effective End Date wajib diisi')),
      );
      return;
    }

    if (_expired &&
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

    final approvalMax = int.tryParse(_approvalMaxController.text.trim());
    if (approvalMax == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Approval Max harus berupa angka')),
      );
      return;
    }

    final company = _companyOptions.firstWhere(
      (item) => item.code == _selectedCompanyCode,
      orElse: () => _companyOptions.first,
    );

    final payload = MasterApprovalData(
      id:
          widget.initialData?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      code: widget.initialData?.code ?? _generateCode(),
      companyCode: _selectedCompanyCode,
      companyName: company.name,
      transaction: _selectedTransaction,
      plant: _plantController.text.trim(),
      organization: _organizationController.text.trim(),
      organizationLevel: _organizationLevelController.text.trim(),
      action: _actionController.text.trim(),
      employee: _employeeController.text.trim(),
      approvalMax: approvalMax,
      effectiveStartDate: _effectiveStartDate!,
      expired: _expired,
      effectiveEndDate: _expired ? _effectiveEndDate : null,
      status: _selectedStatus,
      flows: _flows.map((flow) => flow.toData()).toList(),
    );

    context.pop(payload);
  }

  String _generateCode() {
    final suffix = DateTime.now().microsecondsSinceEpoch.toString().substring(
      9,
      13,
    );
    return 'APR-$suffix';
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Wajib diisi';
    return null;
  }

  String? _numberValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Wajib diisi';
    if (int.tryParse(value.trim()) == null) return 'Harus berupa angka';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Approval Form' : 'Add Form'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedCompanyCode,
              items: _companyOptions
                  .map(
                    (company) => DropdownMenuItem(
                      value: company.code,
                      child: Text('${company.code} - ${company.name}'),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedCompanyCode = value);
              },
              decoration: const InputDecoration(labelText: 'Company'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedTransaction,
              items: _transactionOptions
                  .map(
                    (option) =>
                        DropdownMenuItem(value: option, child: Text(option)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedTransaction = value);
              },
              decoration: const InputDecoration(labelText: 'Transaction'),
            ),
            const SizedBox(height: 12),
            _FormTextField(
              controller: _plantController,
              label: 'Plant',
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            _FormTextField(
              controller: _organizationController,
              label: 'Organization',
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            _FormTextField(
              controller: _organizationLevelController,
              label: 'Organization Level',
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            _FormTextField(
              controller: _actionController,
              label: 'Action',
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            _FormTextField(
              controller: _employeeController,
              label: 'Employee',
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            _FormTextField(
              controller: _approvalMaxController,
              label: 'Approval Max',
              keyboardType: TextInputType.number,
              validator: _numberValidator,
            ),
            const SizedBox(height: 12),
            _DateField(
              label: 'Effective Start Date',
              value: _effectiveStartDate,
              onTap: _pickEffectiveStartDate,
            ),
            const SizedBox(height: 12),
            _SwitchField(
              label: 'Expired',
              value: _expired,
              onChanged: (value) {
                setState(() {
                  _expired = value;
                  if (!value) _effectiveEndDate = null;
                });
              },
            ),
            const SizedBox(height: 12),
            _DateField(
              label: 'Effective End Date',
              value: _effectiveEndDate,
              onTap: _expired ? _pickEffectiveEndDate : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedStatus,
              items: _statusOptions
                  .map(
                    (option) =>
                        DropdownMenuItem(value: option, child: Text(option)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedStatus = value);
              },
              decoration: const InputDecoration(labelText: 'Status'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Add Approval Flow',
                    style: AppTextStyles.titleSmall,
                  ),
                ),
                TextButton.icon(
                  onPressed: _addFlow,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add Row'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...List<Widget>.generate(_flows.length, (index) {
              final flow = _flows[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _FlowCard(
                  index: index,
                  canRemove: _flows.length > 1,
                  flow: flow,
                  onRemove: () => _removeFlow(index),
                  onMandatoryChanged: (value) {
                    setState(() => flow.mandatory = value);
                  },
                  requiredValidator: _requiredValidator,
                ),
              );
            }),
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

class _FlowCard extends StatelessWidget {
  const _FlowCard({
    required this.index,
    required this.canRemove,
    required this.flow,
    required this.onRemove,
    required this.onMandatoryChanged,
    required this.requiredValidator,
  });

  final int index;
  final bool canRemove;
  final _FlowDraft flow;
  final VoidCallback onRemove;
  final ValueChanged<bool> onMandatoryChanged;
  final String? Function(String?) requiredValidator;

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              Text('Flow ${index + 1}', style: AppTextStyles.labelMedium),
              const Spacer(),
              if (canRemove)
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline_rounded),
                  color: AppColors.error,
                  tooltip: 'Remove Flow',
                ),
            ],
          ),
          _FormTextField(
            controller: flow.approvalLevelController,
            label: 'Approval Level',
            validator: requiredValidator,
          ),
          const SizedBox(height: 10),
          _FormTextField(
            controller: flow.employeeController,
            label: 'Employee (Search)',
            validator: requiredValidator,
          ),
          const SizedBox(height: 10),
          _FormTextField(
            controller: flow.positionCodeController,
            label: 'Position Code',
            validator: requiredValidator,
          ),
          const SizedBox(height: 10),
          _SwitchField(
            label: 'Mandatory',
            value: flow.mandatory,
            onChanged: onMandatoryChanged,
          ),
          const SizedBox(height: 10),
          _FormTextField(
            controller: flow.valueController,
            label: 'Value',
            validator: requiredValidator,
          ),
        ],
      ),
    );
  }
}

class _FormTextField extends StatelessWidget {
  const _FormTextField({
    required this.controller,
    required this.label,
    this.validator,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
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

class _SwitchField extends StatelessWidget {
  const _SwitchField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
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
          Expanded(child: Text(label, style: AppTextStyles.bodyMedium)),
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

class _CompanyOption {
  const _CompanyOption({required this.code, required this.name});

  final String code;
  final String name;
}

class _FlowDraft {
  _FlowDraft({
    required this.approvalLevelController,
    required this.employeeController,
    required this.positionCodeController,
    required this.valueController,
    required this.mandatory,
  });

  factory _FlowDraft.empty() {
    return _FlowDraft(
      approvalLevelController: TextEditingController(),
      employeeController: TextEditingController(),
      positionCodeController: TextEditingController(),
      valueController: TextEditingController(),
      mandatory: false,
    );
  }

  factory _FlowDraft.fromData(MasterApprovalFlowData data) {
    return _FlowDraft(
      approvalLevelController: TextEditingController(text: data.approvalLevel),
      employeeController: TextEditingController(text: data.employee),
      positionCodeController: TextEditingController(text: data.positionCode),
      valueController: TextEditingController(text: data.value),
      mandatory: data.mandatory,
    );
  }

  final TextEditingController approvalLevelController;
  final TextEditingController employeeController;
  final TextEditingController positionCodeController;
  final TextEditingController valueController;
  bool mandatory;

  MasterApprovalFlowData toData() {
    return MasterApprovalFlowData(
      approvalLevel: approvalLevelController.text.trim(),
      employee: employeeController.text.trim(),
      positionCode: positionCodeController.text.trim(),
      mandatory: mandatory,
      value: valueController.text.trim(),
    );
  }

  void dispose() {
    approvalLevelController.dispose();
    employeeController.dispose();
    positionCodeController.dispose();
    valueController.dispose();
  }
}
