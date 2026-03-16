import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/login_position.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

/// Concrete implementation of [AuthRepository].
///
/// Coordinates remote and local data-sources, converting
/// low-level exceptions into domain [Failure]s.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  const AuthRepositoryImpl(this._remote, this._local);

  @override
  Future<Either<Failure, User>> login({
    required String username,
    required String password,
    required int positionId,
    required String positionName,
    int? otp,
    bool remember = true,
  }) async {
    try {
      final userModel = await _remote.login(
        username: username,
        password: password,
        positionId: positionId,
        positionName: positionName,
        otp: otp,
        remember: remember,
      );
      await _local.saveUser(userModel);
      await _local.saveLoginStatus(true);
      return Right(userModel.toEntity());
    } on NetworkException {
      return const Left(NetworkFailure());
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LoginPosition>>> checkLoginPositions({
    required String username,
    required String password,
  }) async {
    try {
      final positions = await _remote.checkPositionLogin(
        username: username,
        password: password,
      );
      final mapped = positions.map((item) => item.toEntity()).toList();
      return Right(mapped);
    } on NetworkException {
      return const Left(NetworkFailure());
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _remote.logout();
    } on Exception {
      // Always clear local session even if remote logout fails.
    }

    try {
      await _local.clearAuthData();
      await _local.saveLoginStatus(false);
      return const Right(null);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final userModel = await _remote.getCurrentUser();
      if (userModel != null) {
        await _local.saveUser(userModel);
        return Right(userModel.toEntity());
      }

      final cached = await _local.getCachedUser();
      if (cached != null) return Right(cached.toEntity());

      return const Left(
        AuthFailure('Session tidak valid. Silakan login lagi.'),
      );
    } on UnauthorizedException catch (e) {
      await _local.clearAuthData();
      return Left(AuthFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> validatePermission({
    required String routePath,
  }) async {
    try {
      final allowed = await _remote.validatePermission(routePath: routePath);
      return Right(allowed);
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    return _local.getLoginStatus();
  }
}
