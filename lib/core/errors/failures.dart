/// Base class for all domain-layer failures.
///
/// Every feature's error paths should resolve to a [Failure]
/// subclass so the presentation layer can display user-friendly
/// messages without depending on low-level exception details.
sealed class Failure {
  final String message;
  final int? statusCode;

  const Failure(this.message, {this.statusCode});

  @override
  String toString() => '$runtimeType: $message';
}

class ServerFailure extends Failure {
  const ServerFailure([
    super.message = 'Server error occurred',
    int? statusCode,
  ]) : super(statusCode: statusCode);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error occurred']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

class AuthFailure extends Failure {
  const AuthFailure([
    super.message = 'Authentication failed',
  ]);
}

class ValidationFailure extends Failure {
  const ValidationFailure([
    super.message = 'Validation failed',
  ]);
}
