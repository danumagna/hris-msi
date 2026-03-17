import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/login_position.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

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
      final cached = await _local.getCachedUser();
      final userModel = await _remote.getCurrentUser();
      if (userModel != null) {
        final hydrated = _hydrateCurrentUser(userModel, cached);
        await _local.saveUser(hydrated);
        return Right(hydrated.toEntity());
      }

      if (cached != null) return Right(cached.toEntity());

      await _local.clearAuthData();

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

  UserModel _hydrateCurrentUser(UserModel remote, UserModel? cached) {
    if (cached == null) return remote;

    String sanitizeName(String value) {
      final trimmed = value.trim();
      if (trimmed.toLowerCase() == 'user') return '';
      return trimmed;
    }

    String sanitizeEmail(String value) {
      final trimmed = value.trim();
      if (trimmed.toLowerCase() == 'unknown@msi.com') return '';
      return trimmed;
    }

    String choose(String current, String fallback) {
      final currentTrimmed = current.trim();
      if (currentTrimmed.isNotEmpty) return currentTrimmed;
      return fallback.trim();
    }

    final remoteName = sanitizeName(remote.fullName);
    final cachedName = sanitizeName(cached.fullName);
    final remoteEmail = sanitizeEmail(remote.email);
    final cachedEmail = sanitizeEmail(cached.email);

    return UserModel(
      id: choose(remote.id, cached.id),
      employeeId: choose(remote.employeeId, cached.employeeId),
      fullName: choose(remoteName, cachedName),
      email: choose(remoteEmail, cachedEmail),
      avatarUrl: remote.avatarUrl ?? cached.avatarUrl,
      role: choose(remote.role, cached.role),
    );
  }
}
