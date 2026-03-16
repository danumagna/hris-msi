import 'package:flutter/material.dart';

/// UI-only form data model for Master Form module.
@immutable
class MasterFormData {
  const MasterFormData({
    required this.id,
    required this.moduleName,
    required this.formCode,
    required this.formName,
    required this.formDesc,
    required this.formTitle,
    required this.formLink,
    required this.formIcon,
    required this.formOrder,
    required this.roleName,
    required this.effectiveStartDate,
    this.effectiveEndDate,
    this.status = 'Active',
  });

  final String id;
  final String moduleName;
  final String formCode;
  final String formName;
  final String formDesc;
  final String formTitle;
  final String formLink;
  final String formIcon;
  final int formOrder;
  final String roleName;
  final DateTime effectiveStartDate;
  final DateTime? effectiveEndDate;
  final String status;

  bool get isActive => status.toLowerCase() == 'active';

  MasterFormData copyWith({
    String? id,
    String? moduleName,
    String? formCode,
    String? formName,
    String? formDesc,
    String? formTitle,
    String? formLink,
    String? formIcon,
    int? formOrder,
    String? roleName,
    DateTime? effectiveStartDate,
    DateTime? effectiveEndDate,
    String? status,
    bool clearEffectiveEndDate = false,
  }) {
    return MasterFormData(
      id: id ?? this.id,
      moduleName: moduleName ?? this.moduleName,
      formCode: formCode ?? this.formCode,
      formName: formName ?? this.formName,
      formDesc: formDesc ?? this.formDesc,
      formTitle: formTitle ?? this.formTitle,
      formLink: formLink ?? this.formLink,
      formIcon: formIcon ?? this.formIcon,
      formOrder: formOrder ?? this.formOrder,
      roleName: roleName ?? this.roleName,
      effectiveStartDate: effectiveStartDate ?? this.effectiveStartDate,
      effectiveEndDate: clearEffectiveEndDate
          ? null
          : (effectiveEndDate ?? this.effectiveEndDate),
      status: status ?? this.status,
    );
  }
}
