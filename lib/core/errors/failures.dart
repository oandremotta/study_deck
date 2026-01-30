import 'package:equatable/equatable.dart';

/// Base class for all domain failures.
///
/// Failures represent expected error conditions that can occur during
/// business logic execution. They are returned via [Either.Left] rather
/// than thrown as exceptions.
sealed class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() => message;
}

/// Failure related to local storage operations.
class LocalStorageFailure extends Failure {
  const LocalStorageFailure({
    required super.message,
    super.code,
  });
}

/// Failure related to authentication operations.
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code,
  });

  /// User cancelled the authentication flow.
  factory AuthFailure.cancelled() => const AuthFailure(
        message: 'Authentication was cancelled',
        code: 'auth-cancelled',
      );

  /// Invalid credentials provided.
  factory AuthFailure.invalidCredentials() => const AuthFailure(
        message: 'Invalid email or password',
        code: 'invalid-credentials',
      );

  /// User not found.
  factory AuthFailure.userNotFound() => const AuthFailure(
        message: 'User not found',
        code: 'user-not-found',
      );

  /// Email already in use.
  factory AuthFailure.emailInUse() => const AuthFailure(
        message: 'Email is already in use',
        code: 'email-in-use',
      );

  /// Weak password.
  factory AuthFailure.weakPassword() => const AuthFailure(
        message: 'Password is too weak',
        code: 'weak-password',
      );

  /// Unknown authentication error.
  factory AuthFailure.unknown([String? message]) => AuthFailure(
        message: message ?? 'An unknown authentication error occurred',
        code: 'auth-unknown',
      );
}

/// Failure related to network operations.
class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.code,
  });

  /// No internet connection.
  factory NetworkFailure.noConnection() => const NetworkFailure(
        message: 'No internet connection',
        code: 'no-connection',
      );

  /// Request timeout.
  factory NetworkFailure.timeout() => const NetworkFailure(
        message: 'Request timed out',
        code: 'timeout',
      );

  /// Server error.
  factory NetworkFailure.serverError([String? message]) => NetworkFailure(
        message: message ?? 'Server error occurred',
        code: 'server-error',
      );
}

/// Failure related to data synchronization.
class SyncFailure extends Failure {
  const SyncFailure({
    required super.message,
    super.code,
  });

  /// Conflict during sync.
  factory SyncFailure.conflict() => const SyncFailure(
        message: 'Data conflict detected during synchronization',
        code: 'sync-conflict',
      );

  /// Merge failed.
  factory SyncFailure.mergeFailed([String? message]) => SyncFailure(
        message: message ?? 'Failed to merge data',
        code: 'merge-failed',
      );
}

/// Failure for validation errors.
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code,
  });

  /// Empty field.
  factory ValidationFailure.empty(String fieldName) => ValidationFailure(
        message: '$fieldName cannot be empty',
        code: 'empty-field',
      );

  /// Invalid format.
  factory ValidationFailure.invalidFormat(String fieldName) => ValidationFailure(
        message: '$fieldName has invalid format',
        code: 'invalid-format',
      );
}
