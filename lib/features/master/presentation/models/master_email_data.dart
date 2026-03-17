import 'package:flutter/material.dart';

/// UI-only data model for Master Email module.
@immutable
class MasterEmailData {
  const MasterEmailData({
    required this.id,
    required this.code,
    required this.emailTitle,
    required this.emailSubject,
    required this.emailContent,
    required this.effectiveStartDate,
    required this.isExpired,
    this.effectiveEndDate,
    this.status = 'Active',
  });

  final String id;
  final String code;
  final String emailTitle;
  final String emailSubject;
  final String emailContent;
  final DateTime effectiveStartDate;
  final bool isExpired;
  final DateTime? effectiveEndDate;
  final String status;

  bool get isActive => status.toLowerCase() == 'active';
}
