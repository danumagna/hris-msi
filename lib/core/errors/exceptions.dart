/// Low-level exceptions thrown by data sources.
///
/// These are caught in the repository implementations
/// and converted into [Failure] objects for the domain layer.
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException([
    this.message = 'Server error',
    this.statusCode,
  ]);
}

class CacheException implements Exception {
  final String message;

  const CacheException([this.message = 'Cache error']);
}

class NetworkException implements Exception {
  final String message;

  const NetworkException([
    this.message = 'No internet connection',
  ]);
}

class UnauthorizedException implements Exception {
  final String message;

  const UnauthorizedException([
    this.message = 'Unauthorized access',
  ]);
}
