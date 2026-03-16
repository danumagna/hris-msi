import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Authenticates a user with username/password credentials.
class LoginUseCase {
  final AuthRepository _repository;

  const LoginUseCase(this._repository);

  Future<Either<Failure, User>> call({
    required String username,
    required String password,
    required int positionId,
    required String positionName,
    int? otp,
    bool remember = true,
  }) {
    return _repository.login(
      username: username,
      password: password,
      positionId: positionId,
      positionName: positionName,
      otp: otp,
      remember: remember,
    );
  }
}
