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
    String normalizeKey(String key) {
      return key.replaceAll('_', '').replaceAll('-', '').toLowerCase();
    }

    dynamic readValue(String key) {
      if (json.containsKey(key)) return json[key];

      final target = normalizeKey(key);
      for (final entry in json.entries) {
        if (normalizeKey(entry.key) == target) {
          return entry.value;
        }
      }

      return null;
    }

    String readString(List<String> keys, {String fallback = ''}) {
      for (final key in keys) {
        final value = readValue(key);
        if (value == null) continue;
        final parsed = value.toString().trim();
        if (parsed.isNotEmpty) return parsed;
      }
      return fallback;
    }

    final id = readString(['id', 'user_id']);
    final employeeId = readString([
      'employee_id',
      'employeeId',
      'nip',
      'nik',
      'userName',
      'user_name',
      'username',
    ]);
    final fullName = readString([
      'full_name',
      'fullName',
      'name',
      'employee_name',
      'nama',
      'userName',
      'username',
    ]);
    final email = readString(['email']);
    final role = readString(['role', 'positionName', 'position_name']);

    return UserModel(
      id: id,
      employeeId: employeeId,
      fullName: fullName,
      email: email,
      avatarUrl:
          json['avatar_url']?.toString() ?? json['avatarUrl']?.toString(),
      role: role,
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
