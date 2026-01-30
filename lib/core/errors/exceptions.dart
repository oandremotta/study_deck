/// Base class for infrastructure exceptions.
///
/// Exceptions are thrown at the infrastructure layer (datasources)
/// and caught by repositories, which convert them to [Failure] objects.
sealed class AppException implements Exception {
  final String message;
  final String? code;
  final Object? originalError;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Exception for local storage operations.
class LocalStorageException extends AppException {
  const LocalStorageException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Exception for authentication operations.
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Exception for network operations.
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Exception for server errors.
class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.code,
    super.originalError,
  });
}
