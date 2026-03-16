import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/login_position.dart';
import '../entities/user.dart';

/// Contract for authentication operations.
///
/// Implemented in the data layer; consumed by use-cases.
abstract class AuthRepository {
  Future<Either<Failure, User>> login({
    required String username,
    required String password,
    required int positionId,
    required String positionName,
    int? otp,
    bool remember,
  });

  Future<Either<Failure, List<LoginPosition>>> checkLoginPositions({
    required String username,
    required String password,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, User>> getCurrentUser();

  Future<Either<Failure, bool>> validatePermission({required String routePath});

  Future<bool> isLoggedIn();
}
