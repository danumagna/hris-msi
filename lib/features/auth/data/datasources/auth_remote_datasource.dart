import 'package:dio/dio.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

/// Contract for the remote authentication data-source.
abstract class AuthRemoteDataSource {
  Future<(UserModel user, String token)> login({
    required String username,
    required String password,
  });

  Future<void> logout();

  Future<UserModel> getCurrentUser();
}

/// Real implementation that calls the backend API via [Dio].
///
/// API endpoints are configured in [AppConstants].
/// Adjust the request/response mapping below to match
/// your backend's JSON contract.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  const AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<(UserModel user, String token)> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login', // TODO: sesuaikan endpoint
        data: {'username': username, 'password': password},
      );

      final data = response.data as Map<String, dynamic>;

      // TODO: sesuaikan key response dari backend
      // Contoh response:
      // {
      //   "token": "eyJhbGci...",
      //   "user": {
      //     "id": "1",
      //     "employee_id": "EMP-001",
      //     "full_name": "Admin",
      //     "email": "admin@msi.com",
      //     "avatar_url": null,
      //     "role": "admin"
      //   }
      // }
      final token = data['token'] as String;
      final userJson = data['user'] as Map<String, dynamic>;
      final user = UserModel.fromJson(userJson);

      return (user, token);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout'); // TODO: sesuaikan endpoint
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _dio.get(
        '/auth/me', // TODO: sesuaikan endpoint
      );

      final data = response.data as Map<String, dynamic>;

      // TODO: sesuaikan key response dari backend
      // Jika response langsung user object:
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Converts [DioException] to typed app exceptions.
  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;
        final message = data is Map<String, dynamic>
            ? (data['message'] as String?) ?? 'Server error'
            : 'Server error';
        if (statusCode == 401) {
          return UnauthorizedException(message);
        }
        return ServerException(message, statusCode);
      default:
        return ServerException(e.message ?? 'Unexpected error');
    }
  }
}
