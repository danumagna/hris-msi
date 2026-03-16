/// Application-wide constants for HRIS MSI.
///
/// All magic strings, numbers, and configuration values
/// should be declared here for easy maintenance.
class AppConstants {
  AppConstants._();

  // ── App Info ──────────────────────────────────────────
  static const String appName = 'HRIS MSI';
  static const String appVersion = '1.0.0';

  // ── API ───────────────────────────────────────────────
  static const String baseUrl = 'https://hris-api.magnaedu.id';
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ── Storage Keys ──────────────────────────────────────
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String hrisSecCookieKey = 'hris_sec_cookie';
  static const String loginStatusKey = 'is_logged_in';
  static const String isFirstLaunchKey = 'is_first_launch';

  // ── UI ────────────────────────────────────────────────
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 12.0;
  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration animationDuration = Duration(milliseconds: 300);
}
