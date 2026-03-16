import 'package:flutter/material.dart';

/// UI-only action data model for Master Action module.
@immutable
class MasterActionData {
  const MasterActionData({
    required this.id,
    required this.actionCode,
    required this.actionName,
    required this.actionRole,
    required this.validAction,
    required this.actionUser,
    required this.email,
    required this.status,
    this.endUntil,
    this.modifiedBy,
    this.modifiedDate,
  });

  final String id;
  final String actionCode;
  final String actionName;
  final String actionRole;
  final DateTime validAction;
  final DateTime? endUntil;
  final String actionUser;
  final String email;
  final String status;
  final String? modifiedBy;
  final DateTime? modifiedDate;

  bool get isActive => status.toLowerCase() == 'active';

  MasterActionData copyWith({
    String? id,
    String? actionCode,
    String? actionName,
    String? actionRole,
    DateTime? validAction,
    DateTime? endUntil,
    String? actionUser,
    String? email,
    String? status,
    String? modifiedBy,
    DateTime? modifiedDate,
    bool clearEndUntil = false,
    bool clearModifiedBy = false,
    bool clearModifiedDate = false,
  }) {
    return MasterActionData(
      id: id ?? this.id,
      actionCode: actionCode ?? this.actionCode,
      actionName: actionName ?? this.actionName,
      actionRole: actionRole ?? this.actionRole,
      validAction: validAction ?? this.validAction,
      endUntil: clearEndUntil ? null : (endUntil ?? this.endUntil),
      actionUser: actionUser ?? this.actionUser,
      email: email ?? this.email,
      status: status ?? this.status,
      modifiedBy: clearModifiedBy ? null : (modifiedBy ?? this.modifiedBy),
      modifiedDate: clearModifiedDate
          ? null
          : (modifiedDate ?? this.modifiedDate),
    );
  }
}
