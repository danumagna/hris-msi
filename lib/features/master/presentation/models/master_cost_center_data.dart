import 'package:flutter/material.dart';

/// UI-only data model for Master Cost Center module.
@immutable
class MasterCostCenterData {
  const MasterCostCenterData({
    required this.id,
    required this.company,
    required this.code,
    required this.name,
    required this.description,
    required this.effectiveDate,
    required this.isExpired,
    this.expirationDate,
    this.status = 'Active',
  });

  final String id;
  final String company;
  final String code;
  final String name;
  final String description;
  final DateTime effectiveDate;
  final bool isExpired;
  final DateTime? expirationDate;
  final String status;

  bool get isActive => status.toLowerCase() == 'active';

  MasterCostCenterData copyWith({
    String? id,
    String? company,
    String? code,
    String? name,
    String? description,
    DateTime? effectiveDate,
    bool? isExpired,
    DateTime? expirationDate,
    String? status,
    bool clearExpirationDate = false,
  }) {
    return MasterCostCenterData(
      id: id ?? this.id,
      company: company ?? this.company,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      isExpired: isExpired ?? this.isExpired,
      expirationDate: clearExpirationDate
          ? null
          : (expirationDate ?? this.expirationDate),
      status: status ?? this.status,
    );
  }
}
