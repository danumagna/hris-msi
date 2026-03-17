import 'package:flutter/material.dart';

@immutable
class MasterApprovalFlowData {
  const MasterApprovalFlowData({
    required this.approvalLevel,
    required this.employee,
    required this.positionCode,
    required this.mandatory,
    required this.value,
  });

  final String approvalLevel;
  final String employee;
  final String positionCode;
  final bool mandatory;
  final String value;
}

/// UI-only data model for Master Approval module.
@immutable
class MasterApprovalData {
  const MasterApprovalData({
    required this.id,
    required this.code,
    required this.companyCode,
    required this.companyName,
    required this.transaction,
    required this.plant,
    required this.organization,
    required this.organizationLevel,
    required this.action,
    required this.employee,
    required this.approvalMax,
    required this.effectiveStartDate,
    required this.expired,
    required this.status,
    required this.flows,
    this.effectiveEndDate,
  });

  final String id;
  final String code;
  final String companyCode;
  final String companyName;
  final String transaction;
  final String plant;
  final String organization;
  final String organizationLevel;
  final String action;
  final String employee;
  final int approvalMax;
  final DateTime effectiveStartDate;
  final bool expired;
  final DateTime? effectiveEndDate;
  final String status;
  final List<MasterApprovalFlowData> flows;

  bool get isActive => status.toLowerCase() == 'active';
}
