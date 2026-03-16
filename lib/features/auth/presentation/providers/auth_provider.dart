import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/login_position.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

// ── Data Sources ────────────────────────────────────────

final secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>(
  (ref) => AuthRemoteDataSourceImpl(ref.watch(dioProvider)),
);

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>(
  (ref) => AuthLocalDataSourceImpl(ref.watch(secureStorageProvider)),
);

// ── Repository ──────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(authLocalDataSourceProvider),
  ),
);

// ── Use Cases ───────────────────────────────────────────

final loginUseCaseProvider = Provider<LoginUseCase>(
  (ref) => LoginUseCase(ref.watch(authRepositoryProvider)),
);

final logoutUseCaseProvider = Provider<LogoutUseCase>(
  (ref) => LogoutUseCase(ref.watch(authRepositoryProvider)),
);

// ── Auth State ──────────────────────────────────────────

/// Represents every possible authentication state.
sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final User user;
  const AuthAuthenticated(this.user);
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

// ── Auth Notifier ───────────────────────────────────────

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthInitial();

  Future<void> checkAuthStatus() async {
    state = const AuthLoading();
    final isLoggedIn = await ref.read(authRepositoryProvider).isLoggedIn();
    if (isLoggedIn) {
      final result = await ref.read(authRepositoryProvider).getCurrentUser();
      result.fold(
        (failure) => state = const AuthUnauthenticated(),
        (user) => state = AuthAuthenticated(user),
      );
    } else {
      state = const AuthUnauthenticated();
    }
  }

  Future<void> login({
    required String username,
    required String password,
    required int positionId,
    required String positionName,
    int? otp,
    bool remember = true,
  }) async {
    state = const AuthLoading();
    final result = await ref
        .read(loginUseCaseProvider)
        .call(
          username: username,
          password: password,
          positionId: positionId,
          positionName: positionName,
          otp: otp,
          remember: remember,
        );
    result.fold(
      (failure) => state = AuthError(failure.message),
      (user) => state = AuthAuthenticated(user),
    );
  }

  Future<List<LoginPosition>> checkLoginPositions({
    required String username,
    required String password,
  }) async {
    state = const AuthLoading();
    final result = await ref
        .read(authRepositoryProvider)
        .checkLoginPositions(username: username, password: password);

    return result.fold(
      (failure) {
        state = AuthError(failure.message);
        return <LoginPosition>[];
      },
      (positions) {
        state = const AuthInitial();
        return positions;
      },
    );
  }

  Future<bool> validatePermission({required String routePath}) async {
    final result = await ref
        .read(authRepositoryProvider)
        .validatePermission(routePath: routePath);

    return result.fold((_) => false, (allowed) => allowed);
  }

  Future<void> loginAsGuest() async {
    state = const AuthLoading();
    await Future<void>.delayed(const Duration(milliseconds: 500));
    state = AuthAuthenticated(
      const User(
        id: 'guest',
        employeeId: 'GUEST',
        fullName: 'Guest User',
        email: 'guest@msi.com',
        role: 'guest',
      ),
    );
  }

  Future<void> logout() async {
    state = const AuthLoading();
    await ref.read(logoutUseCaseProvider).call();
    await ref.read(cookieJarProvider).deleteAll();
    state = const AuthUnauthenticated();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
