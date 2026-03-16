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
    String readString(List<String> keys, {String fallback = ''}) {
      for (final key in keys) {
        final value = json[key];
        if (value == null) continue;
        final parsed = value.toString();
        if (parsed.isNotEmpty) return parsed;
      }
      return fallback;
    }

    return UserModel(
      id: readString(['id', 'user_id'], fallback: '0'),
      employeeId: readString(['employee_id', 'employeeId', 'username']),
      fullName: readString(['full_name', 'fullName', 'name', 'username']),
      email: readString(['email'], fallback: 'unknown@msi.com'),
      avatarUrl:
          json['avatar_url']?.toString() ?? json['avatarUrl']?.toString(),
      role: readString(['role', 'positionName'], fallback: 'user'),
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
    return UserModel.fromJson(jsonDecode(source) as Map<String, dynamic>);
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
