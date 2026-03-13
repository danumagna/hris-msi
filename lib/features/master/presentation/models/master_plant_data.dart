import 'package:flutter/material.dart';

/// UI-only plant data model for Master Plant module.
@immutable
class MasterPlantData {
  const MasterPlantData({
    required this.id,
    required this.companyName,
    required this.plantCode,
    required this.plantName,
    required this.plantDesc,
    required this.city,
    required this.street,
    required this.postalCode,
    required this.effectiveStartDate,
    this.effectiveEndDate,
  });

  final String id;
  final String companyName;
  final String plantCode;
  final String plantName;
  final String plantDesc;
  final String city;
  final String street;
  final String postalCode;
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
}
