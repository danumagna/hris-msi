import 'package:flutter/material.dart';

/// UI-only company data model for Master Company module.
@immutable
class MasterCompanyData {
  const MasterCompanyData({
    required this.id,
    required this.companyCode,
    required this.companyName,
    required this.companyDesc,
    required this.city,
    required this.street,
    required this.postalCode,
    required this.vatRegistrationNo,
    required this.telephone,
    required this.effectiveStartDate,
    this.effectiveEndDate,
  });

  final String id;
  final String companyCode;
  final String companyName;
  final String companyDesc;
  final String city;
  final String street;
  final String postalCode;
  final String vatRegistrationNo;
  final String telephone;
  final DateTime effectiveStartDate;
  final DateTime? effectiveEndDate;

  bool get isActive {
    if (effectiveEndDate == null) return true;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final endDate = DateTime(
      effectiveEndDate!.year,
      effectiveEndDate!.month,
      effectiveEndDate!.day,
    );

    return !endDate.isBefore(today);
  }

  String get statusLabel => isActive ? 'Active' : 'Inactive';

  MasterCompanyData copyWith({
    String? id,
    String? companyCode,
    String? companyName,
    String? companyDesc,
    String? city,
    String? street,
    String? postalCode,
    String? vatRegistrationNo,
    String? telephone,
    DateTime? effectiveStartDate,
    DateTime? effectiveEndDate,
    bool clearEffectiveEndDate = false,
  }) {
    return MasterCompanyData(
      id: id ?? this.id,
      companyCode: companyCode ?? this.companyCode,
      companyName: companyName ?? this.companyName,
      companyDesc: companyDesc ?? this.companyDesc,
      city: city ?? this.city,
      street: street ?? this.street,
      postalCode: postalCode ?? this.postalCode,
      vatRegistrationNo: vatRegistrationNo ?? this.vatRegistrationNo,
      telephone: telephone ?? this.telephone,
      effectiveStartDate: effectiveStartDate ?? this.effectiveStartDate,
      effectiveEndDate: clearEffectiveEndDate
          ? null
          : (effectiveEndDate ?? this.effectiveEndDate),
    );
  }
}
