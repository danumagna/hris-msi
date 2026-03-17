import 'package:flutter/material.dart';

/// UI-only data model for Master GL Account module.
@immutable
class MasterGlAccountData {
  const MasterGlAccountData({
    required this.id,
    required this.companyCode,
    required this.company,
    required this.chartOfAccount,
    required this.glAccountNumber,
    required this.glAccountText,
    required this.glAccountGroup,
    required this.integration,
    required this.name,
    required this.description,
    required this.effectiveStartDate,
    required this.isExpired,
    this.effectiveEndDate,
    this.status = 'Active',
  });

  final String id;
  final String companyCode;
  final String company;
  final String chartOfAccount;
  final String glAccountNumber;
  final String glAccountText;
  final String glAccountGroup;
  final String integration;
  final String name;
  final String description;
  final DateTime effectiveStartDate;
  final bool isExpired;
  final DateTime? effectiveEndDate;
  final String status;

  bool get isActive => status.toLowerCase() == 'active';
}
