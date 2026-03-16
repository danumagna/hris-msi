import 'package:flutter/material.dart';

/// UI-only position data model for Master Position module.
@immutable
class MasterPositionData {
  const MasterPositionData({
    required this.id,
    required this.positionCode,
    required this.positionName,
    required this.positionDesc,
    required this.positionLevel,
    required this.jobSpec,
    required this.manSpec,
    required this.validStartDate,
    required this.majors,
    this.validEndDate,
  });

  final String id;
  final String positionCode;
  final String positionName;
  final String positionDesc;
  final String positionLevel;
  final String jobSpec;
  final String manSpec;
  final DateTime validStartDate;
  final DateTime? validEndDate;
  final List<String> majors;

  bool get isActive {
    if (validEndDate == null) return true;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final endDate = DateTime(
      validEndDate!.year,
      validEndDate!.month,
      validEndDate!.day,
    );

    return !endDate.isBefore(today);
  }

  String get statusLabel => isActive ? 'Active' : 'Inactive';

  MasterPositionData copyWith({
    String? id,
    String? positionCode,
    String? positionName,
    String? positionDesc,
    String? positionLevel,
    String? jobSpec,
    String? manSpec,
    DateTime? validStartDate,
    DateTime? validEndDate,
    List<String>? majors,
    bool clearValidEndDate = false,
  }) {
    return MasterPositionData(
      id: id ?? this.id,
      positionCode: positionCode ?? this.positionCode,
      positionName: positionName ?? this.positionName,
      positionDesc: positionDesc ?? this.positionDesc,
      positionLevel: positionLevel ?? this.positionLevel,
      jobSpec: jobSpec ?? this.jobSpec,
      manSpec: manSpec ?? this.manSpec,
      validStartDate: validStartDate ?? this.validStartDate,
      validEndDate: clearValidEndDate
          ? null
          : (validEndDate ?? this.validEndDate),
      majors: majors ?? this.majors,
    );
  }
}
