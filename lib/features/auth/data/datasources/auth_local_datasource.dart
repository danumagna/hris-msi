import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/user_model.dart';

/// Local data-source that persists auth tokens and
/// cached user data via [FlutterSecureStorage].
abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearAuthData();
  Future<bool> hasToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage _storage;

  const AuthLocalDataSourceImpl(this._storage);

  @override
  Future<void> saveToken(String token) async {
    await _storage.write(
      key: AppConstants.accessTokenKey,
      value: token,
    );
  }

  @override
  Future<String?> getToken() async {
    return _storage.read(key: AppConstants.accessTokenKey);
  }

  @override
  Future<void> saveUser(UserModel user) async {
    await _storage.write(
      key: AppConstants.userDataKey,
      value: user.toJsonString(),
    );
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final data = await _storage.read(
      key: AppConstants.userDataKey,
    );
    if (data == null) return null;
    return UserModel.fromJsonString(data);
  }

  @override
  Future<void> clearAuthData() async {
    await _storage.delete(key: AppConstants.accessTokenKey);
    await _storage.delete(key: AppConstants.refreshTokenKey);
    await _storage.delete(key: AppConstants.userDataKey);
  }

  @override
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
