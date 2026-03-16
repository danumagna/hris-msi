import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/user_model.dart';

/// Local data-source that persists auth tokens and
/// cached user data via [FlutterSecureStorage].
abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> saveSessionCookie(String cookie);
  Future<String?> getSessionCookie();
  Future<bool> hasSessionCookie();
  Future<void> saveLoginStatus(bool isLoggedIn);
  Future<bool> getLoginStatus();
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
    await _storage.write(key: AppConstants.accessTokenKey, value: token);
  }

  @override
  Future<String?> getToken() async {
    return _storage.read(key: AppConstants.accessTokenKey);
  }

  @override
  Future<void> saveSessionCookie(String cookie) async {
    await _storage.write(key: AppConstants.hrisSecCookieKey, value: cookie);
  }

  @override
  Future<String?> getSessionCookie() async {
    return _storage.read(key: AppConstants.hrisSecCookieKey);
  }

  @override
  Future<bool> hasSessionCookie() async {
    final cookie = await getSessionCookie();
    return cookie != null && cookie.isNotEmpty;
  }

  @override
  Future<void> saveLoginStatus(bool isLoggedIn) async {
    await _storage.write(
      key: AppConstants.loginStatusKey,
      value: isLoggedIn ? 'true' : 'false',
    );
  }

  @override
  Future<bool> getLoginStatus() async {
    final value = await _storage.read(key: AppConstants.loginStatusKey);
    return value == 'true';
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
    final data = await _storage.read(key: AppConstants.userDataKey);
    if (data == null) return null;
    return UserModel.fromJsonString(data);
  }

  @override
  Future<void> clearAuthData() async {
    await _storage.delete(key: AppConstants.accessTokenKey);
    await _storage.delete(key: AppConstants.refreshTokenKey);
    await _storage.delete(key: AppConstants.userDataKey);
    await _storage.delete(key: AppConstants.hrisSecCookieKey);
    await _storage.delete(key: AppConstants.loginStatusKey);
  }

  @override
  Future<bool> hasToken() async {
    return hasSessionCookie();
  }
}
