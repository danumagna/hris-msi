import 'package:flutter/material.dart';

/// UI-only employee data model for Master Employee module.
@immutable
class MasterEmployeeData {
  const MasterEmployeeData({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.gender,
    required this.email,
    required this.createdBy,
    required this.createdDate,
    required this.status,
  });

  final String id;
  final String employeeId;
  final String employeeName;
  final String gender;
  final String email;
  final String createdBy;
  final DateTime createdDate;
  final String status;

  bool get isActive => status.toLowerCase() == 'active';

  MasterEmployeeData copyWith({
    String? id,
    String? employeeId,
    String? employeeName,
    String? gender,
    String? email,
    String? createdBy,
    DateTime? createdDate,
    String? status,
  }) {
    return MasterEmployeeData(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      gender: gender ?? this.gender,
      email: email ?? this.email,
      createdBy: createdBy ?? this.createdBy,
      createdDate: createdDate ?? this.createdDate,
      status: status ?? this.status,
    );
  }
}
