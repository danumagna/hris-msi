import '../models/user_model.dart';

/// Contract for the remote authentication data-source.
abstract class AuthRemoteDataSource {
  Future<UserModel> login({
    required String username,
    required String password,
  });

  Future<void> logout();

  Future<UserModel> getCurrentUser();
}

/// Stub implementation that simulates API calls.
///
/// Replace this with real HTTP calls (via [Dio]) once
/// the backend API is available.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    // Simulate network latency
    await Future<void>.delayed(const Duration(seconds: 2));

    // Stub: accept any non-empty credentials
    if (username.isEmpty || password.isEmpty) {
      throw Exception('Username and password are required');
    }

    return const UserModel(
      id: '1',
      employeeId: 'EMP-001',
      fullName: 'Admin HRIS',
      email: 'admin@msi.com',
      avatarUrl: null,
      role: 'admin',
    );
  }

  @override
  Future<void> logout() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<UserModel> getCurrentUser() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    return const UserModel(
      id: '1',
      employeeId: 'EMP-001',
      fullName: 'Admin HRIS',
      email: 'admin@msi.com',
      avatarUrl: null,
      role: 'admin',
    );
  }
}
