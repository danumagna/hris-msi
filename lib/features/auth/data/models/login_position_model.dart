import '../../domain/entities/login_position.dart';

class LoginPositionModel {
  const LoginPositionModel({required this.id, required this.name});

  final int id;
  final String name;

  factory LoginPositionModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['positionId'] ?? json['position_id'] ?? json['id'] ?? 0;
    final rawName =
        json['positionName'] ?? json['position_name'] ?? json['name'] ?? '';

    return LoginPositionModel(
      id: rawId is int ? rawId : int.tryParse(rawId.toString()) ?? 0,
      name: rawName.toString(),
    );
  }

  LoginPosition toEntity() => LoginPosition(id: id, name: name);
}
