import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';

/// Provides a configured [Dio] instance for all API calls.
///
/// Includes:
/// - Base URL, timeouts from [AppConstants]
/// - Cookie manager interceptor (handles Set-Cookie/Cookie automatically)
/// - Logging interceptor (debug-only)
final cookieJarProvider = Provider<PersistCookieJar>((ref) {
  final cookieDirectory = Directory(
    '${Directory.systemTemp.path}${Platform.pathSeparator}hris_msi_cookies',
  );
  if (!cookieDirectory.existsSync()) {
    cookieDirectory.createSync(recursive: true);
  }

  return PersistCookieJar(
    ignoreExpires: false,
    storage: FileStorage(cookieDirectory.path),
  );
});

final dioProvider = Provider<Dio>((ref) {
  final cookieJar = ref.watch(cookieJarProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: AppConstants.connectionTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // ── Cookie Manager ────────────────────────────────
  dio.interceptors.add(CookieManager(cookieJar));

  // ── Logging (debug only) ──────────────────────────
  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (o) => debugPrint(o.toString()),
      ),
    );
  }

  return dio;
});
