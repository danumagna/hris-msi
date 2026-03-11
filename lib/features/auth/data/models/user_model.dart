import 'dart:convert';

import '../../../auth/domain/entities/user.dart';

/// Data-transfer model for [User].
///
/// Handles JSON serialisation / deserialisation and
/// conversion to the domain entity.
class UserModel {
  final String id;
  final String employeeId;
  final String fullName;
  final String email;
  final String? avatarUrl;
  final String role;

  const UserModel({
    required this.id,
    required this.employeeId,
    required this.fullName,
    required this.email,
    this.avatarUrl,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      employeeId: json['employee_id'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] as String?,
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'full_name': fullName,
      'email': email,
      'avatar_url': avatarUrl,
      'role': role,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory UserModel.fromJsonString(String source) {
    return UserModel.fromJson(
      jsonDecode(source) as Map<String, dynamic>,
    );
  }

  User toEntity() {
    return User(
      id: id,
      employeeId: employeeId,
      fullName: fullName,
      email: email,
      avatarUrl: avatarUrl,
      role: role,
    );
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      employeeId: user.employeeId,
      fullName: user.fullName,
      email: user.email,
      avatarUrl: user.avatarUrl,
      role: user.role,
    );
  }
}
