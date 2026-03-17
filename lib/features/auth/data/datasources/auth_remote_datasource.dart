import 'package:dio/dio.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/login_position_model.dart';
import '../models/user_model.dart';

/// Contract for the remote authentication data-source.
abstract class AuthRemoteDataSource {
  Future<List<LoginPositionModel>> checkPositionLogin({
    required String username,
    required String password,
  });

  Future<UserModel> login({
    required String username,
    required String password,
    required int positionId,
    required String positionName,
    int? otp,
    bool remember,
  });

  Future<void> logout();

  Future<UserModel?> getCurrentUser();

  Future<bool> validatePermission({required String routePath});
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
  Future<List<LoginPositionModel>> checkPositionLogin({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/check-position-login',
        data: {'username': username, 'password': password},
      );

      final root = _asMap(response.data);
      final positions = _extractPositionList(root);

      return positions
          .map((item) => LoginPositionModel.fromJson(item))
          .where((item) => item.id > 0 && item.name.isNotEmpty)
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<UserModel> login({
    required String username,
    required String password,
    required int positionId,
    required String positionName,
    int? otp,
    bool remember = true,
  }) async {
    try {
      final payload = <String, dynamic>{
        'username': username,
        'password': password,
        'positionId': positionId,
        'positionName': positionName,
        'remember': remember,
      };
      if (otp != null) {
        payload['otp'] = otp;
      }

      final response = await _dio.post('/auth/login', data: payload);

      final data = _asMap(response.data);
      final userJson = _extractUserMap(data);
      if (userJson != null) {
        return UserModel.fromJson(userJson);
      }

      // Some backends only return auth status/cookies on login,
      // then expose user details via check-login.
      final currentUser = await getCurrentUser();
      if (currentUser != null) {
        return currentUser;
      }

      throw const ServerException('Data user tidak ditemukan setelah login');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final response = await _dio.post('/auth/check-login');
      final root = _asMap(response.data);

      final loggedIn = _readBool(root, ['loggedIn', 'isLoggedIn', 'success']);
      if (loggedIn == false) {
        throw const UnauthorizedException('Session expired');
      }

      final userMap = _extractUserMap(root);
      if (userMap == null) return null;
      return UserModel.fromJson(userMap);
    } on UnauthorizedException {
      rethrow;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<bool> validatePermission({required String routePath}) async {
    try {
      final response = await _dio.post(
        '/auth/validate-permission',
        data: {'path': routePath},
      );

      final root = _asMap(response.data);
      final allowed =
          _readBool(root, ['allowed', 'hasPermission', 'success']) ?? true;
      return allowed;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      return data.map((key, value) => MapEntry(key.toString(), value));
    }
    return <String, dynamic>{};
  }

  List<Map<String, dynamic>> _extractPositionList(Map<String, dynamic> root) {
    dynamic candidates = root['positions'];
    candidates ??= root['position'];
    candidates ??= root['data'];
    candidates ??= root['response'];
    candidates ??= root['result'];
    if (candidates is Map<String, dynamic>) {
      candidates =
          candidates['positions'] ??
          candidates['position'] ??
          candidates['list'] ??
          candidates['positionList'] ??
          candidates['items'];
    }
    if (candidates is Map) {
      final mapCandidate = candidates.map(
        (key, value) => MapEntry(key.toString(), value),
      );
      final positionId =
          mapCandidate['positionId'] ??
          mapCandidate['position_id'] ??
          mapCandidate['id'];
      if (positionId != null) {
        return [
          {
            'positionId': positionId,
            'positionName':
                mapCandidate['positionName'] ??
                mapCandidate['position_name'] ??
                mapCandidate['name'],
          },
        ];
      }
    }

    if (candidates is! List) {
      final single = _extractSinglePosition(root);
      return single == null ? <Map<String, dynamic>>[] : [single];
    }

    return candidates
        .whereType<Map>()
        .map(
          (item) => item.map((key, value) => MapEntry(key.toString(), value)),
        )
        .toList();
  }

  Map<String, dynamic>? _extractSinglePosition(Map<String, dynamic> root) {
    if ((root['positionId'] ?? root['position_id'] ?? root['id']) == null) {
      return null;
    }
    return {
      'positionId': root['positionId'] ?? root['position_id'] ?? root['id'],
      'positionName':
          root['positionName'] ?? root['position_name'] ?? root['name'],
    };
  }

  Map<String, dynamic>? _extractUserMap(Map<String, dynamic> root) {
    final direct =
        root['user'] ?? root['User'] ?? root['account'] ?? root['profile'];
    if (direct is Map<String, dynamic>) return direct;
    if (direct is Map) {
      return direct.map((key, value) => MapEntry(key.toString(), value));
    }

    final data = root['data'];
    if (data is Map<String, dynamic>) {
      final nestedUser =
          data['user'] ?? data['User'] ?? data['account'] ?? data['profile'];
      if (nestedUser is Map<String, dynamic>) return nestedUser;
      if (nestedUser is Map) {
        return nestedUser.map((key, value) => MapEntry(key.toString(), value));
      }
      if (_looksLikeUser(data)) return data;
    }
    if (data is Map) {
      final normalized = data.map(
        (key, value) => MapEntry(key.toString(), value),
      );
      if (_looksLikeUser(normalized)) return normalized;
    }

    final result = root['result'];
    if (result is Map<String, dynamic>) {
      final nestedUser =
          result['user'] ?? result['account'] ?? result['profile'];
      if (nestedUser is Map<String, dynamic>) return nestedUser;
      if (nestedUser is Map) {
        return nestedUser.map((key, value) => MapEntry(key.toString(), value));
      }
      if (_looksLikeUser(result)) return result;
    }
    if (result is Map) {
      final normalized = result.map(
        (key, value) => MapEntry(key.toString(), value),
      );
      final nestedUser =
          normalized['user'] ?? normalized['account'] ?? normalized['profile'];
      if (nestedUser is Map<String, dynamic>) return nestedUser;
      if (nestedUser is Map) {
        return nestedUser.map((key, value) => MapEntry(key.toString(), value));
      }
      if (_looksLikeUser(normalized)) return normalized;
    }

    final payload = root['payload'];
    if (payload is Map<String, dynamic>) {
      final nestedUser =
          payload['user'] ?? payload['account'] ?? payload['profile'];
      if (nestedUser is Map<String, dynamic>) return nestedUser;
      if (nestedUser is Map) {
        return nestedUser.map((key, value) => MapEntry(key.toString(), value));
      }
      if (_looksLikeUser(payload)) return payload;
    }
    if (payload is Map) {
      final normalized = payload.map(
        (key, value) => MapEntry(key.toString(), value),
      );
      final nestedUser =
          normalized['user'] ?? normalized['account'] ?? normalized['profile'];
      if (nestedUser is Map<String, dynamic>) return nestedUser;
      if (nestedUser is Map) {
        return nestedUser.map((key, value) => MapEntry(key.toString(), value));
      }
      if (_looksLikeUser(normalized)) return normalized;
    }

    final response = root['response'];
    if (response is Map<String, dynamic>) {
      final nestedUser =
          response['user'] ??
          response['User'] ??
          response['account'] ??
          response['profile'];
      if (nestedUser is Map<String, dynamic>) return nestedUser;
      if (nestedUser is Map) {
        return nestedUser.map((key, value) => MapEntry(key.toString(), value));
      }
      if (_looksLikeUser(response)) return response;
    }
    if (response is Map) {
      final normalized = response.map(
        (key, value) => MapEntry(key.toString(), value),
      );
      if (_looksLikeUser(normalized)) return normalized;
    }

    if (_looksLikeUser(root)) return root;
    return null;
  }

  bool _looksLikeUser(Map<String, dynamic> map) {
    return map.containsKey('id') ||
        map.containsKey('user_id') ||
        map.containsKey('employee_id') ||
        map.containsKey('employeeId') ||
        map.containsKey('userName') ||
        map.containsKey('user_name') ||
        map.containsKey('full_name') ||
        map.containsKey('fullName') ||
        map.containsKey('name') ||
        map.containsKey('email') ||
        map.containsKey('positionName') ||
        map.containsKey('username');
  }

  bool? _readBool(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value is bool) return value;
      if (value is String) {
        final lower = value.toLowerCase();
        if (lower == 'true') return true;
        if (lower == 'false') return false;
      }
      if (value is num) return value != 0;
    }
    return null;
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
        final message = _extractErrorMessage(e.response?.data);
        if (statusCode == 401) {
          return UnauthorizedException(message);
        }
        return ServerException(message, statusCode);
      default:
        return ServerException(e.message ?? 'Unexpected error');
    }
  }

  String _extractErrorMessage(dynamic data) {
    if (data == null) return 'Server error';

    if (data is String && data.isNotEmpty) {
      return data;
    }

    if (data is Map) {
      final normalized = data.map(
        (key, value) => MapEntry(key.toString(), value),
      );

      final message = _extractMessageValue(normalized['message']);
      if (message != null && message.isNotEmpty) return message;

      final codeMessage = _extractMessageValue(normalized['code']);
      if (codeMessage != null && codeMessage.isNotEmpty) return codeMessage;

      final responseMessage = _extractMessageValue(normalized['response']);
      if (responseMessage != null && responseMessage.isNotEmpty) {
        return responseMessage;
      }

      return 'Server error';
    }

    if (data is List && data.isNotEmpty) {
      final message = _extractMessageValue(data.first);
      if (message != null && message.isNotEmpty) return message;
    }

    return 'Server error';
  }

  String? _extractMessageValue(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is num || value is bool) return value.toString();

    if (value is Map) {
      final normalized = value.map((key, val) => MapEntry(key.toString(), val));

      const keys = ['Message', 'message', 'error', 'detail', 'title'];
      for (final key in keys) {
        final nested = normalized[key];
        final parsed = _extractMessageValue(nested);
        if (parsed != null && parsed.isNotEmpty) return parsed;
      }

      return null;
    }

    if (value is List) {
      for (final item in value) {
        final parsed = _extractMessageValue(item);
        if (parsed != null && parsed.isNotEmpty) return parsed;
      }
      return null;
    }

    return value.toString();
  }
}
