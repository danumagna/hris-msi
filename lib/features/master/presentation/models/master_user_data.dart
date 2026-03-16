import 'package:flutter/material.dart';

/// UI-only user data model for Master User module.
@immutable
class MasterUserData {
  const MasterUserData({
    required this.id,
    required this.userCode,
    required this.userName,
    required this.email,
    required this.roleUser,
    required this.validAction,
    required this.employeeId,
    required this.password,
    this.endUntil,
  });

  final String id;
  final String userCode;
  final String userName;
  final String email;
  final String roleUser;
  final DateTime validAction;
  final DateTime? endUntil;
  final String employeeId;
  final String password;

  bool get isActive {
    if (endUntil == null) return true;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final endDate = DateTime(endUntil!.year, endUntil!.month, endUntil!.day);

    return !endDate.isBefore(today);
  }

  String get statusLabel => isActive ? 'Active' : 'Inactive';

  MasterUserData copyWith({
    String? id,
    String? userCode,
    String? userName,
    String? email,
    String? roleUser,
    DateTime? validAction,
    DateTime? endUntil,
    String? employeeId,
    String? password,
    bool clearEndUntil = false,
  }) {
    return MasterUserData(
      id: id ?? this.id,
      userCode: userCode ?? this.userCode,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      roleUser: roleUser ?? this.roleUser,
      validAction: validAction ?? this.validAction,
      endUntil: clearEndUntil ? null : (endUntil ?? this.endUntil),
      employeeId: employeeId ?? this.employeeId,
      password: password ?? this.password,
    );
  }
}
